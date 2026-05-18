#!/usr/bin/env bash
# Checkpoint A+B validator — Pass 1: Discovery
# Validates: Problem Framing, Claim Decomposition, One-Sentence Thesis
set -euo pipefail

OUTPUT_DIR="${CRITICAL_RESEARCH_OUTPUT:-$(pwd)/research-output}"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
errors=0; warnings=0

pass()  { echo -e "  ${GREEN}[PASS]${NC} $1"; }
fail()  { echo -e "  ${RED}[FAIL]${NC} $1"; errors=$((errors + 1)); }
warn()  { echo -e "  ${YELLOW}[WARN]${NC} $1"; warnings=$((warnings + 1)); }

echo ""
echo "══ Checkpoint A+B: Pass 1 Discovery ══"

# Problem Object (research-trace.md)
echo "── Problem Framing ──"
if [ -f "$OUTPUT_DIR/research-trace.md" ]; then
    pass "research-trace.md exists"
    for field in "problem_id" "normalized_problem" "cs_area" "target_output" "must_prove" "must_not_assume"; do
        if grep -q "$field" "$OUTPUT_DIR/research-trace.md" 2>/dev/null; then
            pass "  Field: $field"
        else
            fail "  Field '$field' missing from Problem Object"
        fi
    done

    # One-Sentence Thesis check
    if grep -q '问题句\|洞见句\|系统句' "$OUTPUT_DIR/research-trace.md" 2>/dev/null; then
        pass "One-Sentence Thesis (问题句/洞见句/系统句) present"
    else
        fail "One-Sentence Thesis missing from research-trace.md"
    fi
else
    fail "research-trace.md not found — Pass 1 must write Problem Object"
fi

# Claim Ledger
echo "── Claim Decomposition ──"
if [ -f "$OUTPUT_DIR/claim-ledger.md" ]; then
    pass "claim-ledger.md exists"
    # Check required columns
    for col in "Claim" "Type" "Importance" "Evidence Needed" "Status"; do
        if grep -q "$col" "$OUTPUT_DIR/claim-ledger.md" 2>/dev/null; then
            pass "  Column: $col"
        else
            fail "  Column '$col' missing from Claim Ledger"
        fi
    done
    # Strawman for limitation claims
    if grep -qi 'limitation\|causal' "$OUTPUT_DIR/claim-ledger.md" 2>/dev/null; then
        if grep -q 'Strawman S1' "$OUTPUT_DIR/claim-ledger.md" 2>/dev/null; then
            pass "Strawman analysis present for limitation/causal claims"
        else
            fail "Limitation/causal claims lack Strawman analysis (S1/S2/Root cause)"
        fi
    fi
else
    fail "claim-ledger.md not found"
fi

# Assumption Ledger
echo "── Assumptions ──"
if [ -f "$OUTPUT_DIR/assumption-ledger.md" ]; then
    pass "assumption-ledger.md exists"
    for col in "Related Claim" "Assumption" "Why It Matters" "Status"; do
        if grep -q "$col" "$OUTPUT_DIR/assumption-ledger.md" 2>/dev/null; then
            pass "  Column: $col"
        else
            fail "  Column '$col' missing from Assumption Ledger"
        fi
    done
else
    fail "assumption-ledger.md not found"
fi

# Related Work Dossier
echo "── Related Work ──"
if [ -f "$OUTPUT_DIR/related-work-dossier.md" ]; then
    pass "related-work-dossier.md exists"
    if grep -q 'Scene & Context' "$OUTPUT_DIR/related-work-dossier.md" 2>/dev/null; then
        pass "Dossier: Scene & Context filled"
    else
        fail "Dossier: Scene & Context missing"
    fi
    if grep -q 'Motivation' "$OUTPUT_DIR/related-work-dossier.md" 2>/dev/null; then
        pass "Dossier: Motivation filled"
    else
        fail "Dossier: Motivation missing"
    fi
else
    warn "related-work-dossier.md not found — create initial entries"
fi

echo ""
if [ "$errors" -gt 0 ]; then
    echo "══ BLOCKED: $errors failures, $warnings warnings ══"
    exit 2
else
    echo "══ PASSED: Checkpoints A+B ready ($warnings warnings) ══"
    exit 0
fi
