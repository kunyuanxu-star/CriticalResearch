#!/usr/bin/env bash
# Master checkpoint validator for critical-cs-research
# Runs the appropriate validation based on what files exist.
# Exit 0 = all checks pass. Exit 1 = warnings. Exit 2 = blockers.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="${CRITICAL_RESEARCH_OUTPUT:-$(pwd)/research-output}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass_count=0
fail_count=0
warn_count=0

pass()  { echo -e "  ${GREEN}[PASS]${NC} $1"; pass_count=$((pass_count + 1)); }
fail()  { echo -e "  ${RED}[FAIL]${NC} $1"; fail_count=$((fail_count + 1)); }
warn()  { echo -e "  ${YELLOW}[WARN]${NC} $1"; warn_count=$((warn_count + 1)); }

check_file_exists() {
    local file="$1" label="$2"
    if [ -f "$OUTPUT_DIR/$file" ]; then
        pass "$label ($file)"
        return 0
    else
        fail "$label — file missing: $OUTPUT_DIR/$file"
        return 1
    fi
}

check_file_has_section() {
    local file="$1" pattern="$2" label="$3"
    if [ -f "$OUTPUT_DIR/$file" ] && grep -q "$pattern" "$OUTPUT_DIR/$file" 2>/dev/null; then
        pass "$label"
        return 0
    else
        fail "$label — section '$pattern' not found in $file"
        return 1
    fi
}

check_file_not_empty() {
    local file="$1" label="$2"
    if [ -f "$OUTPUT_DIR/$file" ] && [ -s "$OUTPUT_DIR/$file" ]; then
        local lines=$(wc -l < "$OUTPUT_DIR/$file" | tr -d ' ')
        if [ "$lines" -gt 5 ]; then
            pass "$label ($lines lines)"
            return 0
        else
            warn "$label — too short ($lines lines, expected >5)"
            return 1
        fi
    else
        fail "$label — file missing or empty"
        return 1
    fi
}

# ── Determine which stage to validate ──────────────────────────

echo ""
echo "══════════════════════════════════════════════"
echo "  critical-cs-research — Checkpoint Validator"
echo "══════════════════════════════════════════════"
echo "  Output dir: $OUTPUT_DIR"
echo ""

# ── Pass 1: Discovery Checks ──────────────────────────────────

HAS_CLAIM=$( [ -f "$OUTPUT_DIR/claim-ledger.md" ] && echo 1 || echo 0 )
HAS_ASSUMPTION=$( [ -f "$OUTPUT_DIR/assumption-ledger.md" ] && echo 1 || echo 0 )
HAS_TRACE=$( [ -f "$OUTPUT_DIR/research-trace.md" ] && echo 1 || echo 0 )
HAS_DOSSIER=$( [ -f "$OUTPUT_DIR/related-work-dossier.md" ] && echo 1 || echo 0 )

if [ "$HAS_CLAIM" -eq 1 ] || [ "$HAS_ASSUMPTION" -eq 1 ] || [ "$HAS_TRACE" -eq 1 ]; then
    echo "── Pass 1: Discovery ──────────────────────────"

    if [ "$HAS_TRACE" -eq 1 ]; then
        check_file_has_section "research-trace.md" "problem_id" "Problem Object defined"
        check_file_has_section "research-trace.md" "normalized_problem" "Problem normalized"
    else
        fail "research-trace.md not found (Pass 1 required output)"
    fi

    if [ "$HAS_CLAIM" -eq 1 ]; then
        check_file_not_empty "claim-ledger.md" "Claim Ledger"
        # Check for strawman analysis on limitation/causal claims
        if grep -q 'limitation\|causal' "$OUTPUT_DIR/claim-ledger.md" 2>/dev/null; then
            if grep -q 'Strawman S1' "$OUTPUT_DIR/claim-ledger.md" 2>/dev/null; then
                pass "Strawman analysis present for limitation/causal claims"
            else
                fail "Strawman analysis missing — limitation/causal claims require S1/S2/Root cause"
            fi
        fi
    else
        fail "claim-ledger.md not found (Pass 1 required output)"
    fi

    if [ "$HAS_ASSUMPTION" -eq 1 ]; then
        check_file_not_empty "assumption-ledger.md" "Assumption Ledger"
    fi

    if [ "$HAS_DOSSIER" -eq 1 ]; then
        check_file_not_empty "related-work-dossier.md" "Related Work Dossier"
        check_file_has_section "related-work-dossier.md" "Scene & Context" "Dossier: Scene & Context"
        check_file_has_section "related-work-dossier.md" "Motivation" "Dossier: Motivation"
    else
        warn "related-work-dossier.md not found (create during Problem Framing)"
    fi
fi

# ── Pass 2: Validation Checks ──────────────────────────────────

HAS_EVIDENCE=$( [ -f "$OUTPUT_DIR/evidence-ledger.md" ] && echo 1 || echo 0 )
HAS_CRITIQUE=$( [ -f "$OUTPUT_DIR/critique-ledger.md" ] && echo 1 || echo 0 )
HAS_GAP=$( [ -f "$OUTPUT_DIR/gap-backlog.md" ] && echo 1 || echo 0 )

if [ "$HAS_EVIDENCE" -eq 1 ] || [ "$HAS_CRITIQUE" -eq 1 ] || [ "$HAS_GAP" -eq 1 ]; then
    echo ""
    echo "── Pass 2: Validation ─────────────────────────"

    if [ "$HAS_EVIDENCE" -eq 1 ]; then
        check_file_not_empty "evidence-ledger.md" "Evidence Ledger"
        # Evidence levels must be used
        if grep -qE '\b[SABCD]\b' "$OUTPUT_DIR/evidence-ledger.md" 2>/dev/null; then
            pass "Evidence levels (S/A/B/C/D) assigned"
        else
            warn "No evidence levels (S/A/B/C/D) found in ledger"
        fi
        # Allowed/Forbidden wording
        if grep -q 'Allowed Wording\|Forbidden Wording' "$OUTPUT_DIR/evidence-ledger.md" 2>/dev/null; then
            pass "Allowed/Forbidden wording defined"
        else
            warn "Allowed/Forbidden wording not defined for evidence"
        fi
    else
        fail "evidence-ledger.md not found (Pass 2 required output)"
    fi

    if [ "$HAS_CRITIQUE" -eq 1 ]; then
        check_file_not_empty "critique-ledger.md" "Critique Ledger"
        # Severity levels
        sev_count=$(grep -cE '\b(fatal|high|medium|low)\b' "$OUTPUT_DIR/critique-ledger.md" 2>/dev/null || true)
        if [ "$sev_count" -ge 3 ]; then
            pass "Critique severity levels used ($sev_count occurrences)"
        else
            warn "Few critique severity levels found (<3)"
        fi
        # Check for at least one fatal or high
        if grep -qE '\b(fatal|high)\b' "$OUTPUT_DIR/critique-ledger.md" 2>/dev/null; then
            pass "At least one fatal or high severity critique"
        else
            warn "No fatal/high critiques found — critique may be insufficient"
        fi
        # Bidirectional linking: severity ≥ medium must link to Gap
        if grep -qE '\b(medium|high|fatal)\b' "$OUTPUT_DIR/critique-ledger.md" 2>/dev/null; then
            if grep -qE 'G[0-9]' "$OUTPUT_DIR/critique-ledger.md" 2>/dev/null; then
                pass "Critique-to-Gap bidirectional links present"
            else
                fail "Severity ≥ medium critiques lack Gap Backlog links (G1, G2, ...)"
            fi
        fi
    else
        fail "critique-ledger.md not found (Pass 2 required output)"
    fi

    if [ "$HAS_GAP" -eq 1 ]; then
        check_file_not_empty "gap-backlog.md" "Gap Backlog"
        check_file_has_section "gap-backlog.md" "Closure Condition" "Gap: Closure Conditions defined"
    else
        fail "gap-backlog.md not found (Pass 2 required output)"
    fi

    # Evidence saturation
    if [ "$HAS_CLAIM" -eq 1 ] && [ "$HAS_EVIDENCE" -eq 1 ]; then
        echo ""
        echo "  ── Evidence Saturation Estimate ──"
        total_claims=$(grep -c '| C[0-9]' "$OUTPUT_DIR/claim-ledger.md" 2>/dev/null || true)
        evidence_entries=$(grep -c '| E[0-9]' "$OUTPUT_DIR/evidence-ledger.md" 2>/dev/null || true)
        echo "  Total claims (approx): $total_claims"
        echo "  Evidence entries:       $evidence_entries"
        if [ "$evidence_entries" != "?" ] && [ "$evidence_entries" -lt "$total_claims" ] 2>/dev/null; then
            warn "Fewer evidence entries than claims — saturation likely < required"
        fi
    fi
fi

# ── Checkpoint D: Rebuttal ────────────────────────────────────

if [ "$HAS_TRACE" -eq 1 ]; then
    if grep -q 'Rebuttal Ledger\|Rebuttal ID' "$OUTPUT_DIR/research-trace.md" 2>/dev/null; then
        echo ""
        echo "── Checkpoint D: Rebuttal ─────────────────────"
        pass "Rebuttal Ledger exists"
        if grep -q 'clarification\|new_evidence\|scope_redefinition' "$OUTPUT_DIR/research-trace.md" 2>/dev/null; then
            pass "Rebuttal types assigned (clarification/new_evidence/scope_redefinition)"
        fi
        if grep -q 'confirmed\|applied\|rejected' "$OUTPUT_DIR/research-trace.md" 2>/dev/null; then
            pass "Rebuttal resolutions recorded"
        fi
    fi
fi

# ── Pass 3: Convergence & Final Output ─────────────────────────

HAS_FINAL=$( [ -f "$OUTPUT_DIR/final-report.md" ] && echo 1 || echo 0 )

if [ "$HAS_FINAL" -eq 1 ]; then
    echo ""
    echo "── Pass 3: Convergence ────────────────────────"

    check_file_not_empty "final-report.md" "Final Report"

    # One-Sentence Thesis
    check_file_has_section "final-report.md" "One-Sentence Thesis" "One-Sentence Thesis section"
    if grep -q '问题句\|洞见句\|系统句' "$OUTPUT_DIR/final-report.md" 2>/dev/null; then
        pass "Three-sentence thesis (问题句/洞见句/系统句) present"
    else
        fail "One-Sentence Thesis incomplete — must have 问题句 + 洞见句 + 系统句"
    fi

    # Basic System Definition
    check_file_has_section "final-report.md" "Problem Framing" "Problem Framing section"
    check_file_has_section "final-report.md" "Core Object\|Key Constraint" "Basic system: Object & Constraint defined"

    # Strawman Analysis
    if grep -q 'Strawman S1\|Strawman S2\|Root cause' "$OUTPUT_DIR/final-report.md" 2>/dev/null; then
        pass "Strawman analysis (S1/S2/Root cause) present"
    else
        warn "Strawman analysis not found in Final Report"
    fi

    # Evidence Map
    check_file_has_section "final-report.md" "Evidence Map" "Evidence Map section"

    # Reviewer Defence Table
    if grep -q '这个问题真实存在吗\|Reviewer Attack Defence\|12.*Attack' "$OUTPUT_DIR/final-report.md" 2>/dev/null; then
        pass "Reviewer Defence Table present"
    else
        warn "Reviewer Defence Table (12 attacks) not found"
    fi

    # Story Closure Table
    if grep -q 'Story Closure Table\|Challenge.*Insight.*Design.*Experiment' "$OUTPUT_DIR/final-report.md" 2>/dev/null; then
        pass "Story Closure Table present"
    else
        fail "Story Closure Table missing — challenge-design-evaluation mapping required"
    fi

    # Logic Audit
    if grep -q 'LOGIC-GAP\|Logic Consistency\|Logic Audit' "$OUTPUT_DIR/final-report.md" 2>/dev/null; then
        pass "Logic Audit section present"
        logic_gaps=$(grep -c 'LOGIC-GAP' "$OUTPUT_DIR/final-report.md" 2>/dev/null || true)
        if [ "$logic_gaps" -eq 0 ]; then
            pass "Zero LOGIC-GAP entries"
        else
            fail "$logic_gaps LOGIC-GAP entries remain — must fix before finalizing"
        fi
    else
        fail "Logic Audit section missing from Final Report"
    fi

    # Story Quality Audit
    if grep -q 'STORY-GAP\|Story Quality Audit\|17.*Point\|17-Point' "$OUTPUT_DIR/final-report.md" 2>/dev/null; then
        pass "Story Quality Audit section present"
        story_gaps=$(grep -c 'STORY-GAP' "$OUTPUT_DIR/final-report.md" 2>/dev/null || true)
        if [ "$story_gaps" -eq 0 ]; then
            pass "Zero STORY-GAP entries"
        elif [ "$story_gaps" -le 3 ]; then
            warn "$story_gaps STORY-GAP entries (≤3 allowed, should review)"
        else
            fail "$story_gaps STORY-GAP entries (>3 — must fix before finalizing)"
        fi
    else
        fail "Story Quality Audit section missing from Final Report"
    fi

    # Writing quality: check for banned terms
    echo ""
    echo "  ── Writing Quality Scan ──"
    banned_terms="obviously\|clearly\|fundamentally\|many systems\|industry needs"
    banned_count=$(grep -ci "$banned_terms" "$OUTPUT_DIR/final-report.md" 2>/dev/null || true)
    if [ "$banned_count" -eq 0 ]; then
        pass "No banned absolute terms (obviously/clearly/fundamentally/etc.)"
    else
        fail "$banned_count banned absolute terms found — remove or qualify"
    fi

    # Check for slogan adjectives without metrics
    if grep -qiE '高效|轻量|灵活|安全|自动化' "$OUTPUT_DIR/final-report.md" 2>/dev/null; then
        warn "Slogan adjectives (高效/轻量/灵活/安全/自动化) found — ensure each has a metric"
    fi
fi

# ── Summary ────────────────────────────────────────────────────

echo ""
echo "══════════════════════════════════════════════"
echo -e "  Results: ${GREEN}$pass_count passed${NC} / ${RED}$fail_count failed${NC} / ${YELLOW}$warn_count warnings${NC}"
echo "══════════════════════════════════════════════"

if [ "$fail_count" -gt 0 ]; then
    echo ""
    echo "  BLOCKED: $fail_count checks failed. Fix before proceeding."
    exit 2
elif [ "$warn_count" -gt 0 ]; then
    echo ""
    echo "  PROCEED WITH CAUTION: $warn_count warnings. Review before user handoff."
    exit 1
else
    echo ""
    echo "  ALL CHECKS PASSED. Ready for User Satisfaction Gate."
    exit 0
fi
