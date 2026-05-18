#!/usr/bin/env bash
# Checkpoint D validator — Rebuttal Phase
# Validates: Rebuttal Ledger entries, rebuttal type classification, resolution status
set -euo pipefail

OUTPUT_DIR="${CRITICAL_RESEARCH_OUTPUT:-$(pwd)/research-output}"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
errors=0; warnings=0

pass()  { echo -e "  ${GREEN}[PASS]${NC} $1"; }
fail()  { echo -e "  ${RED}[FAIL]${NC} $1"; errors=$((errors + 1)); }
warn()  { echo -e "  ${YELLOW}[WARN]${NC} $1"; warnings=$((warnings + 1)); }

echo ""
echo "══ Checkpoint D: Rebuttal Phase ══"

if [ ! -f "$OUTPUT_DIR/research-trace.md" ]; then
    fail "research-trace.md not found — cannot check Rebuttal Ledger"
    exit 2
fi

echo "── Rebuttal Ledger ──"

# Check Rebuttal Ledger section exists
if grep -q 'Rebuttal Ledger\|Rebuttal ID' "$OUTPUT_DIR/research-trace.md" 2>/dev/null; then
    pass "Rebuttal Ledger section exists"
else
    fail "Rebuttal Ledger section missing from research-trace.md"
    echo ""
    echo "══ BLOCKED ══"
    exit 2
fi

# Required columns
for col in "Rebuttal ID" "Target Critique" "Rebuttal Content" "Rebuttal Type" "Resolution"; do
    if grep -q "$col" "$OUTPUT_DIR/research-trace.md" 2>/dev/null; then
        pass "  Column: $col"
    else
        fail "  Column '$col' missing from Rebuttal Ledger"
    fi
done

# Rebuttal type must be one of the three valid types
echo "── Rebuttal Types ──"
local found_types=0
for rtype in "clarification" "new_evidence" "scope_redefinition"; do
    if grep -q "$rtype" "$OUTPUT_DIR/research-trace.md" 2>/dev/null; then
        pass "Rebuttal type '$rtype' used"
        found_types=$((found_types + 1))
    fi
done
if [ "$found_types" -eq 0 ]; then
    fail "No valid rebuttal types found — must classify as clarification / new_evidence / scope_redefinition"
fi

# Resolution status
echo "── Resolution Status ──"
local found_resolutions=0
for res in "confirmed" "applied" "rejected" "pending"; do
    if grep -q "$res" "$OUTPUT_DIR/research-trace.md" 2>/dev/null; then
        found_resolutions=$((found_resolutions + 1))
    fi
done
if [ "$found_resolutions" -ge 1 ]; then
    pass "Rebuttal resolution statuses recorded"
else
    warn "No resolution statuses found (confirmed/applied/rejected/pending)"
fi

# Check for insufficient rebuttal markings
if grep -qi 'insufficient' "$OUTPUT_DIR/research-trace.md" 2>/dev/null; then
    warn "Some rebuttals marked as 'insufficient' — verify D.5 rejection criteria were applied"
fi

# Post-rebuttal: check that affected ledgers were updated
echo "── Post-Rebuttal Ledger Sync ──"
if grep -q 'resolved_by_rebuttal\|resolved_by_clarification\|closed_by_rebuttal' "$OUTPUT_DIR/research-trace.md" 2>/dev/null; then
    pass "Post-rebuttal ledger updates recorded"
else
    warn "No 'resolved_by_rebuttal' / 'closed_by_rebuttal' markings — verify D.3 re-refinement was executed"
fi

# Check that saturation was recalculated after rebuttal
if grep -q 'rebuttal.*saturation\|saturation.*rebuttal\|饱和度.*%' "$OUTPUT_DIR/research-trace.md" 2>/dev/null; then
    pass "Post-rebuttal saturation recalculation noted"
else
    warn "Post-rebuttal saturation not recorded — D.3 step 5 (recalculate saturation) may be incomplete"
fi

echo ""
if [ "$errors" -gt 0 ]; then
    echo "══ BLOCKED: $errors failures ══"
    exit 2
else
    echo "══ PASSED: Checkpoint D complete ($warnings warnings) ══"
    echo "  Present D.4 decision options to user (Pass 3 / Re-search / Rebuttal again)."
    exit 0
fi
