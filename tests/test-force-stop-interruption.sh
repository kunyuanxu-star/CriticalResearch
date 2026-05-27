#!/usr/bin/env bash
# test-force-stop-interruption.sh — Verify force stop only interrupts, never completes.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-force-XXXXXX)
cd "$TEST_DIR"

echo "══ Force Stop Interruption Tests ══"
echo "Test dir: $TEST_DIR"
echo ""

cr workspace init > /dev/null 2>&1
cr start e2e-force > /dev/null 2>&1
jq '.active_round = null' e2e-force/state/project-state.json > e2e-force/state/project-state.json.tmp && \
    mv e2e-force/state/project-state.json.tmp e2e-force/state/project-state.json

echo "# test paper" > e2e-force/documents/paper.md
echo "schema_version: \"1.0.0\"" > e2e-force/state/claim-ledger.yaml

cr-start-paper-round e2e-force "test force stop" > /dev/null 2>&1
ROUND_DIR="e2e-force/rounds/round-002"

# ── Test 1: force stop → active_round preserved ──
echo "── Test 1: force stop preserves active_round ──"
ACTIVE_BEFORE=$(jq -r '.active_round // "null"' e2e-force/state/project-state.json)
STOP_OUT=$(cr-stop-gate "$TEST_DIR/e2e-force" --force 2>&1 || true)
ACTIVE_AFTER=$(jq -r '.active_round // "null"' e2e-force/state/project-state.json)

if [ "$ACTIVE_BEFORE" = "$ACTIVE_AFTER" ] && [ "$ACTIVE_AFTER" != "null" ]; then
    pass "active_round preserved ($ACTIVE_AFTER)"
else
    fail "active_round changed: before=$ACTIVE_BEFORE after=$ACTIVE_AFTER"
fi
echo ""

# ── Test 2: force stop → round.yaml still open ──
echo "── Test 2: force stop keeps round.yaml open ──"
ROUND_STATUS=$(grep -E '^status:' "$ROUND_DIR/round.yaml" 2>/dev/null | sed 's/^status:\s*//' | xargs || echo "")
if [ "$ROUND_STATUS" = "open" ]; then
    pass "round.yaml status remains open"
else
    fail "round.yaml status=$ROUND_STATUS"
fi
echo ""

# ── Test 3: force stop → interruption-log.yaml created ──
echo "── Test 3: force stop creates interruption-log.yaml ──"
if [ -f "$ROUND_DIR/interruption-log.yaml" ]; then
    pass "interruption-log.yaml exists"
else
    fail "interruption-log.yaml missing"
fi

INT_STAGE=$(yq -r '.current_stage // ""' "$ROUND_DIR/interruption-log.yaml" 2>/dev/null || echo "")
INT_REASON=$(yq -r '.reason // ""' "$ROUND_DIR/interruption-log.yaml" 2>/dev/null || echo "")
if [ "$INT_REASON" = "user_forced_stop" ]; then
    pass "interruption-log has reason=user_forced_stop"
else
    fail "interruption-log reason=$INT_REASON"
fi
if [ "$INT_STAGE" = "s1_round_contract" ]; then
    pass "interruption-log current_stage=s1_round_contract"
else
    fail "interruption-log current_stage='$INT_STAGE'"
fi
echo ""

# ── Test 4: force stop → state.yaml current_stage unchanged ──
echo "── Test 4: force stop preserves current_stage ──"
CURRENT=$(yq -r '.current_stage // ""' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
if [ "$CURRENT" = "s1_round_contract" ]; then
    pass "current_stage preserved as s1_round_contract"
else
    fail "current_stage=$CURRENT"
fi
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
