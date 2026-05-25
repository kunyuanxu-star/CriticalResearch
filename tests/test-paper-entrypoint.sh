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
echo "# test paper" > test-proj/writing/paper-draft.md

# Close round-001 so we can start a new paper round.
jq '.active_round = null' test-proj/state/project-state.json > test-proj/state/project-state.json.tmp && \
    mv test-proj/state/project-state.json.tmp test-proj/state/project-state.json

ROUND_OUT=$(cr round test-proj --mode paper "test objective" 2>&1 || true)
if echo "$ROUND_OUT" | grep -qi "round-002\|paper round.*started\|Paper Round 002"; then
    pass "cr round --mode paper starts a paper round"
else
    fail "cr round --mode paper failed: ${ROUND_OUT:0:200}"
fi

ROUND_DIR="test-proj/rounds/round-002"

# Check manifest snapshot exists.
if [ -f "$ROUND_DIR/phase-manifest.snapshot.yaml" ]; then
    pass "phase-manifest.snapshot.yaml exists"
else
    fail "phase-manifest.snapshot.yaml missing"
fi

# Check phase_order has 37 phases.
PHASE_COUNT=$(yq -r '.phase_order | length' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "0")
if [ "$PHASE_COUNT" -eq 37 ]; then
    pass "state.yaml phase_order has 37 phases"
else
    fail "phase_order has $PHASE_COUNT phases (expected 37)"
fi

# Check active_round is non-null.
ACTIVE_RND=$(jq -r '.active_round // "null"' test-proj/state/project-state.json 2>/dev/null || echo "null")
if [ "$ACTIVE_RND" != "null" ] && [ "$ACTIVE_RND" != "0" ]; then
    pass "active_round is non-null ($ACTIVE_RND)"
else
    fail "active_round is $ACTIVE_RND"
fi

# Check current_phase is snapshot_paper_state.
CURRENT=$(yq -r '.current_phase // ""' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
if [ "$CURRENT" = "snapshot_paper_state" ]; then
    pass "current_phase is snapshot_paper_state"
else
    fail "current_phase is '$CURRENT' (expected snapshot_paper_state)"
fi

echo ""

# ── Test 2: cr-new-round --mode paper is rejected ──
echo "── Test 2: cr-new-round --mode paper is rejected ──"
REJECT_OUT=$(cr-new-round test-proj discovery --mode paper 2>&1 || true)
if echo "$REJECT_OUT" | grep -qi "must be started via cr-start-paper-round\|paper mode must be started"; then
    pass "cr-new-round --mode paper is rejected"
else
    fail "cr-new-round --mode paper was not rejected: ${REJECT_OUT:0:200}"
fi
echo ""

# ── Test 3: cr round --mode paper without objective fails ──
echo "── Test 3: cr round --mode paper without objective fails ──"
# Reset active_round so we can start another round.
jq '.active_round = null' test-proj/state/project-state.json > test-proj/state/project-state.json.tmp && \
    mv test-proj/state/project-state.json.tmp test-proj/state/project-state.json

NO_OBJ_OUT=$(cr round test-proj --mode paper 2>&1 || true)
if echo "$NO_OBJ_OUT" | grep -qi "usage\|objective\|required"; then
    pass "cr round --mode paper without objective fails"
else
    fail "cr round --mode paper without objective did not fail: ${NO_OBJ_OUT:0:200}"
fi
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
