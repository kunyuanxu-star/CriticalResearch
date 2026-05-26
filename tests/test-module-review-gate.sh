#!/usr/bin/env bash
# test-module-review-gate.sh — Verify module review gates in state machine.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-mod-gate-XXXXXX)
cd "$TEST_DIR"

echo "══ Module Review Gate Tests ══"
echo "Test dir: $TEST_DIR"
echo ""

# ── Setup ──
cr workspace init > /dev/null 2>&1
cr start e2e-gate > /dev/null 2>&1
jq '.active_round = null' e2e-gate/state/project-state.json > e2e-gate/state/project-state.json.tmp && \
    mv e2e-gate/state/project-state.json.tmp e2e-gate/state/project-state.json

mkdir -p e2e-gate/writing e2e-gate/state
echo "# test paper" > e2e-gate/writing/paper-draft.md
echo "schema_version: \"1.0.0\"" > e2e-gate/state/claim-ledger.yaml

cr-start-paper-round e2e-gate "test module gate" > /dev/null 2>&1
ROUND_DIR="e2e-gate/rounds/round-002"
mkdir -p "$ROUND_DIR/_cr/knowledge"

# Create M0 boundary artifacts.
echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/paper-state.yaml"
echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/round-objective.yaml"
echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/full-paper-coverage-plan.yaml"
echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/loaded-knowledge.yaml"

# ── Helper: advance phase via direct state manipulation ──
# We manually advance to freeze_full_paper_coverage and mark it complete
# to test the module review gate behavior.
mark_phase_complete() {
    local phase="$1"
    yq -i ".phases.\"$phase\".status = \"complete\"" "$ROUND_DIR/state.yaml" 2>/dev/null || true
}

# ── Test 1: M0 complete, no review, next phase blocked ──
echo "── Test 1: M0 complete + no review → next phase blocked ──"
mark_phase_complete snapshot_paper_state
mark_phase_complete load_project_knowledge
mark_phase_complete define_round_objective
mark_phase_complete freeze_full_paper_coverage

# Set current_phase to the boundary phase.
yq -i '.current_phase = "freeze_full_paper_coverage"' "$ROUND_DIR/state.yaml" 2>/dev/null || true

# Verify state.yaml has review_required.
M0_STATE=$(yq -r '.module_reviews.M0.status // ""' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
if [ "$M0_STATE" = "review_required" ] || [ "$M0_STATE" = "pending" ]; then
    pass "state.yaml reflects M0 review pending/required"
else
    fail "state.yaml M0 status='$M0_STATE' (expected review_required or pending)"
fi

# Try to complete the boundary phase again — should exit 3.
if cr-complete-phase "$TEST_DIR/e2e-gate" "$ROUND_DIR" freeze_full_paper_coverage >/tmp/mg1.out 2>&1; then
    fail "cr-complete-phase should exit 3 when review missing"
else
    MG1_CODE=$?
    if [ "$MG1_CODE" -eq 3 ]; then
        pass "cr-complete-phase exits 3 when M0 review missing"
    else
        fail "cr-complete-phase exited $MG1_CODE (expected 3)"
    fi
fi
echo ""

# ── Test 2: cr step advance returns code 3 when review missing ──
echo "── Test 2: cr step advance returns code 3 when review missing ──"
if cr step e2e-gate advance >/tmp/mg2.out 2>&1; then
    fail "cr step advance should exit 3 when review missing"
else
    MG2_CODE=$?
    if [ "$MG2_CODE" -eq 3 ]; then
        pass "cr step advance exits 3 when M0 review missing"
    else
        fail "cr step advance exited $MG2_CODE (expected 3)"
    fi
fi
echo ""

# ── Test 3: M0 review status=pass → auto-unblock ──
echo "── Test 3: M0 review pass → next phase unblocked ──"
mkdir -p "$ROUND_DIR/phase-reviews"
cat > "$ROUND_DIR/phase-reviews/M0-review.yaml" << 'RV'
schema_version: "1.0.0"
module: M0
status: pass
blocking_findings: []
minor_findings: []
RV

# Run cr-complete-phase again — should pass and unblock.
if cr-complete-phase "$TEST_DIR/e2e-gate" "$ROUND_DIR" freeze_full_paper_coverage >/tmp/mg3.out 2>&1; then
    # Check that next phase is now current.
    NEXT_PHASE=$(yq -r '.current_phase // ""' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
    if [ "$NEXT_PHASE" = "plan_research_questions" ]; then
        pass "M0 review pass unblocks next phase (current=$NEXT_PHASE)"
    else
        fail "Next phase is '$NEXT_PHASE' (expected plan_research_questions)"
    fi
    # Check state.yaml module_reviews.M0.status = pass.
    M0_PASS=$(yq -r '.module_reviews.M0.status // ""' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
    if [ "$M0_PASS" = "pass" ]; then
        pass "state.yaml M0.status=pass after review"
    else
        fail "state.yaml M0.status='$M0_PASS' (expected pass)"
    fi
else
    fail "cr-complete-phase should pass after M0 review"
fi
echo ""

# ── Test 4: Stop hook blocks with module review missing ──
echo "── Test 4: Stop hook blocks with module review context ──"
# Reset to M0 boundary without review.
rm -f "$ROUND_DIR/phase-reviews/M0-review.yaml"
yq -i '.current_phase = "freeze_full_paper_coverage"' "$ROUND_DIR/state.yaml" 2>/dev/null || true
yq -i '.module_reviews.M0.status = "review_required"' "$ROUND_DIR/state.yaml" 2>/dev/null || true

OUTPUT=$(cr-stop-gate "$TEST_DIR/e2e-gate" 2>/dev/null || true)
if echo "$OUTPUT" | grep -q '"decision":"block"'; then
    if echo "$OUTPUT" | grep -q "M0 review is required"; then
        pass "Stop gate returns JSON block for missing M0 review"
    else
        fail "Stop gate JSON missing expected reason"
        echo "$OUTPUT"
    fi
else
    fail "Stop gate should return decision:block"
    echo "$OUTPUT"
fi
echo ""

# ── Test 5: M0 review status=block → cannot advance ──
echo "── Test 5: M0 review status=block → cannot advance ──"
cat > "$ROUND_DIR/phase-reviews/M0-review.yaml" << 'RV2'
schema_version: "1.0.0"
module: M0
status: block
blocking_findings:
  - "Critical issue found"
minor_findings: []
RV2

# Reset current phase to boundary.
yq -i '.current_phase = "freeze_full_paper_coverage"' "$ROUND_DIR/state.yaml" 2>/dev/null || true
# Mark boundary phases complete again.
for p in snapshot_paper_state load_project_knowledge define_round_objective freeze_full_paper_coverage; do
    yq -i ".phases.\"$p\".status = \"complete\"" "$ROUND_DIR/state.yaml" 2>/dev/null || true
done

if cr-complete-phase "$TEST_DIR/e2e-gate" "$ROUND_DIR" freeze_full_paper_coverage >/tmp/mg5.out 2>&1; then
    fail "cr-complete-phase should fail when M0 review is block"
else
    MG5_CODE=$?
    if [ "$MG5_CODE" -eq 3 ]; then
        pass "cr-complete-phase exits 3 when M0 review is block"
    else
        fail "cr-complete-phase exited $MG5_CODE (expected 3)"
    fi
fi
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
