#!/usr/bin/env bash
# test-review-structural-vs-semantic.sh — Verify structural/semantic review distinction.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-review-sem-XXXXXX)
cd "$TEST_DIR"

echo "══ Structural vs Semantic Review Tests ══"
echo ""

cr workspace init > /dev/null 2>&1
cr start e2e-review > /dev/null 2>&1
jq '.active_round = null' e2e-review/state/project-state.json > e2e-review/state/project-state.json.tmp && \
    mv e2e-review/state/project-state.json.tmp e2e-review/state/project-state.json

mkdir -p e2e-review/writing e2e-review/state
echo "# test paper" > e2e-review/writing/paper-draft.md
echo "schema_version: \"1.0.0\"" > e2e-review/state/claim-ledger.yaml

cr-start-paper-round e2e-review "test review" > /dev/null 2>&1
ROUND_DIR="e2e-review/rounds/round-002"
mkdir -p "$ROUND_DIR/phase-reviews"

# ── Test 1: new structural_review format passes ──
echo "── Test 1: structural_review status=pass -> checkpoint passes ──"
cat > "$ROUND_DIR/phase-reviews/M0-review.yaml" << 'RV'
schema_version: "1.0.0"
module: M0
structural_review:
  reviewer: module_checkpoint
  status: pass
  checked_phases:
    - snapshot_paper_state
  blocking_findings: []
  findings: []
semantic_review:
  required: false
  status: not_configured
  reviewer: null
  findings: []
RV

if cr-validate-module-checkpoint "$TEST_DIR/e2e-review" "$ROUND_DIR" > /tmp/rv1.out 2>&1; then
    pass "Checkpoint passes with structural_review.status=pass"
else
    fail "Checkpoint should pass with structural_review.status=pass"
    cat /tmp/rv1.out
fi
echo ""

# ── Test 2: structural_review status=pending -> checkpoint fails ──
echo "── Test 2: structural_review status=pending -> checkpoint fails ──"
# Mark M0 boundary phase complete so checkpoint will check the review.
yq -i '.phases.freeze_full_paper_coverage.status = "complete"' "$ROUND_DIR/state.yaml" 2>/dev/null || true
cat > "$ROUND_DIR/phase-reviews/M0-review.yaml" << 'RV2'
schema_version: "1.0.0"
module: M0
structural_review:
  reviewer: module_checkpoint
  status: pending
  checked_phases: []
  blocking_findings: []
semantic_review:
  required: false
  status: not_configured
  reviewer: null
  findings: []
RV2

if cr-validate-module-checkpoint "$TEST_DIR/e2e-review" "$ROUND_DIR" > /tmp/rv2.out 2>&1; then
    fail "Checkpoint should fail when structural_review is pending"
else
    if grep -q "structural review status='pending'" /tmp/rv2.out; then
        pass "Checkpoint detects pending structural_review"
    else
        fail "Wrong error message"
        cat /tmp/rv2.out
    fi
fi
echo ""

# ── Test 3: legacy format still works ──
echo "── Test 3: legacy review format still recognized ──"
cat > "$ROUND_DIR/phase-reviews/M0-review.yaml" << 'RV3'
schema_version: "1.0.0"
module: M0
status: pass
blocking_findings: []
findings: []
RV3

if cr-validate-module-checkpoint "$TEST_DIR/e2e-review" "$ROUND_DIR" > /tmp/rv3.out 2>&1; then
    pass "Checkpoint passes with legacy review format"
else
    fail "Checkpoint should pass with legacy format"
    cat /tmp/rv3.out
fi
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
