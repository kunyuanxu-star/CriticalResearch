#!/usr/bin/env bash
# test-paper-entrypoint.sh — Verify paper workflow round creation (v2).
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
export CR_TEST_MODE=1

TEST_DIR=$(mktemp -d /tmp/cr-entry-XXXXXX)
cd "$TEST_DIR"

echo "══ Paper Entrypoint Tests (v2) ══"
echo "Test dir: $TEST_DIR"
echo ""

cr workspace init > /dev/null 2>&1

# ── Test 1: cr round start --workflow paper creates valid round ──
echo "── Test 1: cr round start --workflow paper ──"
cr project init test-proj --domain systems > /dev/null 2>&1
cd test-proj
cr document add test-proj paper --type paper --path documents/paper.md > /dev/null 2>&1
echo "# test paper" > documents/paper.md

cr round start test-proj --workflow paper --doc paper --mode deep --objective "test objective" > /dev/null 2>&1

ROUND_DIR=$(ls -d rounds/round-* | head -1)
WF_STATE="$ROUND_DIR/workflow-state.yaml"

# Check workflow-state.yaml exists.
if [ -f "$WF_STATE" ]; then
    pass "workflow-state.yaml exists"
else
    fail "workflow-state.yaml missing"
fi

# Check stage_order has stages (paper workflow has 10).
STAGE_COUNT=$(yq -r '.stage_order | length' "$WF_STATE" 2>/dev/null || echo "0")
if [ "${STAGE_COUNT:-0}" -ge 1 ]; then
    pass "stage_order has $STAGE_COUNT stages"
else
    fail "stage_order has 0 stages"
fi

# Check active_round is non-null.
ACTIVE_RND=$(jq -r '.active_round // "null"' state/project-state.json 2>/dev/null || echo "null")
if [ "$ACTIVE_RND" != "null" ] && [ "$ACTIVE_RND" != "0" ]; then
    pass "active_round is set"
else
    fail "active_round is $ACTIVE_RND"
fi

# Check current_stage is set.
CURRENT=$(yq -r '.current_stage // ""' "$WF_STATE" 2>/dev/null || echo "")
if [ -n "$CURRENT" ]; then
    pass "current_stage = $CURRENT"
else
    fail "current_stage is empty"
fi

# Check required_outputs are materialized.
RO_CHECK=$(yq -r ".stages.\"$CURRENT\".required_outputs | length" "$WF_STATE" 2>/dev/null || echo "0")
if [ "${RO_CHECK:-0}" -ge 1 ]; then
    pass "current stage materialized required_outputs ($RO_CHECK)"
else
    fail "current stage has no required_outputs"
fi

echo ""

# ── Test 2: Round start without objective fails ──
echo "── Test 2: Missing objective rejected ──"
TESTD2=$(mktemp -d /tmp/cr-entry2-XXXXXX)
cd "$TESTD2"
cr workspace init > /dev/null 2>&1
cr project init objtest --domain systems > /dev/null 2>&1
cd objtest
cr document add objtest paper --type paper --path documents/paper.md > /dev/null 2>&1
echo "# test" > documents/paper.md

NO_OBJ_OUT=$(cr round start objtest --workflow paper --doc paper --mode triage 2>&1 || true)
if echo "$NO_OBJ_OUT" | grep -qi "usage\|objective\|required"; then
    pass "Missing objective rejected"
else
    fail "Missing objective not rejected: ${NO_OBJ_OUT:0:200}"
fi
cd "$TEST_DIR"
rm -rf "$TESTD2"

echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
