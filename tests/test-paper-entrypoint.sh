#!/usr/bin/env bash
# test-paper-entrypoint.sh — Verify paper round can ONLY be started via cr-start-paper-round.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-entry-XXXXXX)
cd "$TEST_DIR"

echo "══ Paper Entrypoint Tests ══"
echo "Test dir: $TEST_DIR"
echo ""

cr workspace init > /dev/null 2>&1

# ── Test 1: cr round --mode paper creates valid round ──
echo "── Test 1: cr round <project> --mode paper \"<obj>\" ──"
cr start test-proj > /dev/null 2>&1
echo "# test paper" > test-proj/documents/paper.md

# Close round-001 so we can start a new paper round.
jq '.active_round = null' test-proj/state/project-state.json > test-proj/state/project-state.json.tmp && \
    mv test-proj/state/project-state.json.tmp test-proj/state/project-state.json

ROUND_OUT=$(cr round test-proj --mode paper "test objective" 2>&1 || true)
if echo "$ROUND_OUT" | grep -qi "round-002\|paper round.*started\|Paper Round 002"; then
    pass "Paper round started via cr round"
else
    fail "Paper round not started: ${ROUND_OUT:0:200}"
fi

ROUND_DIR="test-proj/rounds/round-002"

# Check manifest snapshot exists.
if [ -f "$ROUND_DIR/stage-manifest.snapshot.yaml" ]; then
    pass "stage-manifest.snapshot.yaml exists"
else
    fail "stage-manifest.snapshot.yaml missing"
fi

# Check stage_order has 8 stages.
STAGE_COUNT=$(yq -r '.stage_order | length' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "0")
if [ "$STAGE_COUNT" -eq 8 ]; then
    pass "stage_order has 8 stages"
else
    fail "stage_order has $STAGE_COUNT stages (expected 8)"
fi

# Check active_round is non-null.
ACTIVE_RND=$(jq -r '.active_round // "null"' test-proj/state/project-state.json 2>/dev/null || echo "null")
if [ "$ACTIVE_RND" != "null" ] && [ "$ACTIVE_RND" != "0" ]; then
    pass "active_round is set"
else
    fail "active_round is $ACTIVE_RND"
fi

# Check current_stage is s1_round_contract.
CURRENT=$(yq -r '.current_stage // ""' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
if [ "$CURRENT" = "s1_round_contract" ]; then
    pass "current_stage = s1_round_contract"
else
    fail "current_stage = $CURRENT"
fi

echo ""

# ── Test 2: cr-new-round --mode paper is rejected ──
echo "── Test 2: cr-new-round --mode paper is rejected ──"
REJECT_OUT=$(cr-new-round test-proj discovery --mode paper 2>&1 || true)
if echo "$REJECT_OUT" | grep -qi "must be started via cr-start-paper-round\|paper mode must be started"; then
    pass "cr-new-round --mode paper rejected"
else
    fail "cr-new-round --mode paper not rejected: ${REJECT_OUT:0:200}"
fi
echo ""

# ── Test 3: cr round --mode paper without objective fails ──
echo "── Test 3: cr round --mode paper without objective fails ──"
# Reset active_round so we can start another round.
jq '.active_round = null' test-proj/state/project-state.json > test-proj/state/project-state.json.tmp && \
    mv test-proj/state/project-state.json.tmp test-proj/state/project-state.json

NO_OBJ_OUT=$(cr round test-proj --mode paper 2>&1 || true)
if echo "$NO_OBJ_OUT" | grep -qi "usage\|objective\|required"; then
    pass "Missing objective rejected"
else
    fail "Missing objective not rejected: ${NO_OBJ_OUT:0:200}"
fi
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
