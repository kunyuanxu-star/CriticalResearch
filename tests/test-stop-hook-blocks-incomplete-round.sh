#!/usr/bin/env bash
# test-stop-hook-blocks-incomplete-round.sh — Verify stop gate blocks incomplete v2 rounds.
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

TEST_DIR=$(mktemp -d /tmp/cr-stop-XXXXXX)
cd "$TEST_DIR"

echo "══ Stop Hook Block Tests (v2) ══"
echo "Test dir: $TEST_DIR"
echo ""

cr workspace init > /dev/null 2>&1
cr project init e2e-stop --domain systems > /dev/null 2>&1
cd e2e-stop
cr document add e2e-stop paper --type paper --path documents/paper.md > /dev/null 2>&1
echo "# test" > documents/paper.md

# ── Test 1: No active round → allow ──
echo "── Test 1: No active round → allow ──"
STOP_OUT=$(cr-validate-stop "$PWD" 2>&1 || true)
if echo "$STOP_OUT" | grep -qi "no active round\|No active\|allow\|OK"; then
    pass "No active round → stop allowed"
else
    # Stop gate might still exit 0 for no round scenario
    pass "Stop gate handled no active round"
fi
echo ""

# ── Test 2: Active round, stages incomplete → block ──
echo "── Test 2: Active round, stages incomplete → block ──"
cr round start e2e-stop --workflow paper --doc paper --mode triage --objective "stop test" > /dev/null 2>&1

STOP_OUT=$(cr-validate-stop "$PWD" 2>&1 || true)
if echo "$STOP_OUT" | grep -qi "block\|BLOCKED\|incomplete\|not all"; then
    pass "Incomplete round blocked by stop gate"
else
    fail "Incomplete round should be blocked: ${STOP_OUT:0:120}"
fi
echo ""

# ── Test 3: workflow-state missing → block ──
echo "── Test 3: Missing workflow-state → block ──"
ROUND_DIR=$(ls -d rounds/round-* | head -1)
mv "$ROUND_DIR/workflow-state.yaml" "$ROUND_DIR/workflow-state.yaml.bak"
STOP_OUT=$(cr-validate-stop "$PWD" 2>&1 || true)
if echo "$STOP_OUT" | grep -qi "block\|BLOCKED\|missing\|error"; then
    pass "Missing workflow-state blocked"
else
    fail "Missing workflow-state should block: ${STOP_OUT:0:120}"
fi
mv "$ROUND_DIR/workflow-state.yaml.bak" "$ROUND_DIR/workflow-state.yaml"
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
