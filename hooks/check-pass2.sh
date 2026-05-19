#!/usr/bin/env bash
# Checkpoint C validator — Pass 2: Validation
# Validates: Evidence Ledger, Critique Ledger, Gap Backlog, evidence saturation
set -euo pipefail

OUTPUT_DIR="${CRITICAL_RESEARCH_OUTPUT:-$(pwd)/research-output}"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
errors=0; warnings=0

pass()  { echo -e "  ${GREEN}[PASS]${NC} $1"; }
fail()  { echo -e "  ${RED}[FAIL]${NC} $1"; errors=$((errors + 1)); }
warn()  { echo -e "  ${YELLOW}[WARN]${NC} $1"; warnings=$((warnings + 1)); }

echo ""
echo "══ Checkpoint C: Pass 2 Validation ══"

# Evidence Ledger
echo "── Evidence ──"
if [ -f "$OUTPUT_DIR/evidence-ledger.md" ]; then
    pass "evidence-ledger.md exists"
    for col in "Source" "Type" "Level" "Related Claims" "Relation" "Allowed Wording" "Forbidden Wording"; do
        if grep -q "$col" "$OUTPUT_DIR/evidence-ledger.md" 2>/dev/null; then
            pass "  Column: $col"
        else
            fail "  Column '$col' missing from Evidence Ledger"
        fi
    done
    # Evidence levels
    s_count=$(grep -cE '\bS\b' "$OUTPUT_DIR/evidence-ledger.md" 2>/dev/null || echo 0)
    a_count=$(grep -cE '\bA\b' "$OUTPUT_DIR/evidence-ledger.md" 2>/dev/null || echo 0)
    echo "  Evidence: S=$s_count A=$a_count"
    if [ "$((s_count + a_count))" -ge 1 ]; then
        pass "At least one S/A level evidence present"
    else
        fail "No S or A level evidence — main-line claims require S/A evidence"
    fi
else
    fail "evidence-ledger.md not found"
fi

# Critique Ledger
echo "── Critique ──"
if [ -f "$OUTPUT_DIR/critique-ledger.md" ]; then
    pass "critique-ledger.md exists"
    for col in "Target Claim" "Critique Type" "Severity" "Critique" "Linked Gap"; do
        if grep -q "$col" "$OUTPUT_DIR/critique-ledger.md" 2>/dev/null; then
            pass "  Column: $col"
        else
            fail "  Column '$col' missing from Critique Ledger"
        fi
    done
    # Severity coverage: must have at least medium+ critiques
    fatal_high=$(grep -cE '\b(fatal|high)\b' "$OUTPUT_DIR/critique-ledger.md" 2>/dev/null || echo 0)
    if [ "$fatal_high" -ge 1 ]; then
        pass "At least one fatal/high critique present"
    else
        warn "No fatal/high critiques — critique may be insufficiently deep (D.3 requires ≥3 medium+)"
    fi
    # Critiques must link to Gap IDs
    linked=$(grep -cE 'G[0-9]' "$OUTPUT_DIR/critique-ledger.md" 2>/dev/null || echo 0)
    if [ "$linked" -ge 1 ]; then
        pass "Critique-to-Gap links present ($linked)"
    else
        fail "No Gap IDs found in Critique Ledger — bidirectional linking required"
    fi
else
    fail "critique-ledger.md not found"
fi

# Gap Backlog
echo "── Gap Backlog ──"
if [ -f "$OUTPUT_DIR/gap-backlog.md" ]; then
    pass "gap-backlog.md exists"
    for col in "From Critique" "Missing Information" "Research Question" "Priority" "Closure Condition"; do
        if grep -q "$col" "$OUTPUT_DIR/gap-backlog.md" 2>/dev/null; then
            pass "  Column: $col"
        else
            fail "  Column '$col' missing from Gap Backlog"
        fi
    done
    # Gaps must link back to critiques
    if grep -qE 'A[0-9]' "$OUTPUT_DIR/gap-backlog.md" 2>/dev/null; then
        pass "Gap-to-Critique backlinks present"
    else
        fail "No Critique IDs (A1, A2, ...) found in Gap Backlog — bidirectional linking required"
    fi
else
    fail "gap-backlog.md not found"
fi

# Evidence saturation estimate
echo "── Saturation ──"
if [ -f "$OUTPUT_DIR/claim-ledger.md" ] && [ -f "$OUTPUT_DIR/evidence-ledger.md" ]; then
    core_claims=$(grep -c '| C[0-9]' "$OUTPUT_DIR/claim-ledger.md" 2>/dev/null || echo "?")
    evidence_entries=$(grep -c '| E[0-9]' "$OUTPUT_DIR/evidence-ledger.md" 2>/dev/null || echo "?")
    echo "  Core claims (approx): $core_claims"
    echo "  Evidence entries:     $evidence_entries"
fi

echo ""
if [ "$errors" -gt 0 ]; then
    echo "══ BLOCKED: $errors failures, $warnings warnings ══"
    echo "  Fix failures before presenting Checkpoint C to user."
    exit 2
else
    echo "══ PASSED: Checkpoint C ready ($warnings warnings) ══"
    echo "  Present evidence summary + top critiques + gap backlog to user."
    exit 0
fi
