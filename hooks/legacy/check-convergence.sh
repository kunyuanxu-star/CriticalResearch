#!/usr/bin/env bash
# Pass 3 Convergence & User Satisfaction Gate validator
# Validates: Internal quality bar, Logic Audit, Story Quality Audit, Story Closure
# This is the FINAL gate before user handoff.
set -euo pipefail

OUTPUT_DIR="${CRITICAL_RESEARCH_OUTPUT:-$(pwd)/research-output}"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
errors=0; warnings=0

pass()  { echo -e "  ${GREEN}[PASS]${NC} $1"; }
fail()  { echo -e "  ${RED}[FAIL]${NC} $1"; errors=$((errors + 1)); }
warn()  { echo -e "  ${YELLOW}[WARN]${NC} $1"; warnings=$((warnings + 1)); }

echo ""
echo "══ Pass 3 Convergence: User Satisfaction Gate ══"
echo "  (Internal quality bar — must pass before presenting to user)"
echo ""

if [ ! -f "$OUTPUT_DIR/final-report.md" ]; then
    fail "final-report.md not found — cannot run Convergence check"
    exit 2
fi

# ── Internal Quality Bar (§3.5) ──────────────────────────────
echo "── Internal Quality Bar ──"

# 1. All core claims have evidence or are marked as risk
if grep -qE '\brisk\b.*\|.*\brisk\b' "$OUTPUT_DIR/final-report.md" 2>/dev/null || \
   grep -qE '\bsupported\b' "$OUTPUT_DIR/final-report.md" 2>/dev/null; then
    pass "Claims have evidence or are marked as risk"
else
    fail "Claims lack evidence — internal quality bar requires all core claims have evidence or risk marking"
fi

# 2. High-severity critiques addressed
if grep -qE 'resolved|resolved_by_rebuttal|resolved_by_clarification|accepted as risk' "$OUTPUT_DIR/final-report.md" 2>/dev/null; then
    pass "High-severity critiques addressed"
else
    warn "No resolved critique markings found"
fi

# 3. Comparative claims have baselines
if grep -qE '[Bb]aseline' "$OUTPUT_DIR/final-report.md" 2>/dev/null; then
    pass "Baselines referenced"
else
    fail "Comparative claims lack baselines"
fi

# 4. Performance/security/correctness claims have evaluation obligations
if grep -qE 'Evaluation Obligation|Required Evaluation|Falsification' "$OUTPUT_DIR/final-report.md" 2>/dev/null; then
    pass "Evaluation obligations defined"
else
    fail "Evaluation obligations missing"
fi

# 5. Key terms defined
if grep -qE '定义|Definition|defined as' "$OUTPUT_DIR/final-report.md" 2>/dev/null; then
    pass "Key terms appear to be defined"
else
    warn "Key term definitions not explicitly found"
fi

# 6. Weak claims downgraded or deleted
if grep -qE '[Ww]eaken[ed]*.*[Cc]laim|[Dd]eleted.*[Cc]laim' "$OUTPUT_DIR/final-report.md" 2>/dev/null; then
    pass "Weakened/Deleted claims section present"
else
    warn "Weakened/Deleted claims section not found"
fi

# 7. Contribution is not incremental
if grep -qE '不是.*增量|不是.*incremental|contribution.*not.*incremental' "$OUTPUT_DIR/final-report.md" 2>/dev/null; then
    pass "Non-incremental contribution explanation found"
else
    warn "Non-incremental contribution not explicitly argued"
fi

# ── Logic Audit ───────────────────────────────────────────────
echo ""
echo "── Logic Audit (§3.6) ──"

logic_gaps=$(grep -c '\[LOGIC-GAP' "$OUTPUT_DIR/final-report.md" 2>/dev/null || true)
if [ "$logic_gaps" -eq 0 ]; then
    pass "Zero LOGIC-GAP entries"
else
    fail "$logic_gaps LOGIC-GAP entries remain"
fi

# Banned terms
banned=$(grep -ciE '\bobviously\b|\bclearly\b.*\bfundamentally\b|\bmany systems\b|\bindustry needs\b' "$OUTPUT_DIR/final-report.md" 2>/dev/null || true)
if [ "$banned" -eq 0 ]; then
    pass "No banned absolute terms"
else
    fail "$banned banned terms found (obviously/clearly/fundamentally/etc.)"
fi

# ── Story Quality Audit ───────────────────────────────────────
echo ""
echo "── Story Quality Audit (§3.6) ──"

story_gaps=$(grep -c '\[STORY-GAP' "$OUTPUT_DIR/final-report.md" 2>/dev/null || true)
if [ "$story_gaps" -eq 0 ]; then
    pass "Zero STORY-GAP entries"
elif [ "$story_gaps" -le 3 ]; then
    warn "$story_gaps STORY-GAP entries (≤3 — review before final)"
else
    fail "$story_gaps STORY-GAP entries (>3 — must fix before finalizing)"
fi

# ── Story Closure Check ───────────────────────────────────────
echo ""
echo "── Story Closure (§3.7) ──"

if grep -qE 'Challenge.*Insight.*Design.*Experiment.*Metric' "$OUTPUT_DIR/final-report.md" 2>/dev/null; then
    pass "Story Closure Table header found"

    # Check for closure gaps
    closure_gaps=$(grep -cE '\bgap\b' "$OUTPUT_DIR/final-report.md" 2>/dev/null || true)
    if [ "$closure_gaps" -eq 0 ]; then
        pass "All closure entries marked 'closed' (no gaps)"
    else
        warn "$closure_gaps closure gaps detected — verify each is intentional"
    fi
else
    fail "Story Closure Table missing — challenge-design-evaluation mapping required"
fi

# ── One-Sentence Thesis Final Check ───────────────────────────
echo ""
echo "── One-Sentence Thesis ──"
thesis_count=$(grep -cE '问题句|洞见句|系统句' "$OUTPUT_DIR/final-report.md" 2>/dev/null || true)
if [ "$thesis_count" -ge 3 ]; then
    pass "Three-sentence thesis complete"
elif [ "$thesis_count" -ge 1 ]; then
    fail "One-Sentence Thesis incomplete (found $thesis_count/3 sentences)"
else
    fail "One-Sentence Thesis missing entirely"
fi

# ── Summary ───────────────────────────────────────────────────
echo ""
if [ "$errors" -gt 0 ]; then
    echo "══ INTERNAL BAR NOT MET: $errors failures ══"
    echo "  DO NOT present Final Report to user."
    echo "  Auto-continue iteration until fixes applied."
    exit 2
else
    echo "══ INTERNAL BAR PASSED ($warnings warnings) ══"
    echo "  Ready to present Final Report draft to user."
    echo "  Execute User Satisfaction Gate: ask if user is convinced."
    exit 0
fi
