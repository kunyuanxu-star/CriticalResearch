#!/usr/bin/env bash
# test-stop-hook-blocks-incomplete-round.sh — Verify stop gate blocks incomplete rounds.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-stop-XXXXXX)
cd "$TEST_DIR"

echo "══ Stop Hook Block Tests ══"
echo "Test dir: $TEST_DIR"
echo ""

cr workspace init > /dev/null 2>&1
cr start e2e-stop > /dev/null 2>&1
jq '.active_round = null' e2e-stop/state/project-state.json > e2e-stop/state/project-state.json.tmp && \
    mv e2e-stop/state/project-state.json.tmp e2e-stop/state/project-state.json

cr-start-paper-round e2e-stop "test stop hook" > /dev/null 2>&1

ROUND_DIR="e2e-stop/rounds/round-002"

# ── Test 1: No active round → allow ──
echo "── Test 1: No active round → allow ──"
# Set active_round to null.
jq '.active_round = null' e2e-stop/state/project-state.json > e2e-stop/state/project-state.json.tmp && \
    mv e2e-stop/state/project-state.json.tmp e2e-stop/state/project-state.json

STOP_OUT=$(cr-stop-gate "$TEST_DIR/e2e-stop" 2>&1 || true)
if echo "$STOP_OUT" | jq -e '.decision == "approve"' >/dev/null 2>&1; then
    pass "No active round → stop approved"
else
    fail "No active round should allow stop: $STOP_OUT"
fi
echo ""

# ── Test 2: Active round, stage incomplete → block ──
echo "── Test 2: Active round, current stage incomplete → block ──"
# Restore active_round.
jq '.active_round = 2' e2e-stop/state/project-state.json > e2e-stop/state/project-state.json.tmp && \
    mv e2e-stop/state/project-state.json.tmp e2e-stop/state/project-state.json
# Mark only stage 1 complete, leave stage 2 open.
yq -i '.stages.s1_round_contract.status = "complete"' "$ROUND_DIR/state.yaml" 2>/dev/null || true
yq -i '.stages.s1_round_contract.completed_at = "2026-01-01T00:00:00Z"' "$ROUND_DIR/state.yaml" 2>/dev/null || true

STOP_OUT=$(cr-stop-gate "$TEST_DIR/e2e-stop" 2>&1 || true)
if echo "$STOP_OUT" | grep '"decision"' | grep -q '"block"'; then
    pass "Incomplete round blocked"
else
    fail "Incomplete round should be blocked: $STOP_OUT"
fi
echo ""

# ── Test 3: Active round, manifest snapshot missing → block ──
echo "── Test 3: Missing manifest snapshot → block ──"
# Temporarily rename manifest.
mv "$ROUND_DIR/stage-manifest.snapshot.yaml" "$ROUND_DIR/stage-manifest.snapshot.yaml.bak"
STOP_OUT=$(cr-stop-gate "$TEST_DIR/e2e-stop" 2>&1 || true)
if echo "$STOP_OUT" | jq -e '.decision == "block"' >/dev/null 2>&1; then
    pass "Missing manifest snapshot blocked"
else
    fail "Missing manifest should block: $STOP_OUT"
fi
mv "$ROUND_DIR/stage-manifest.snapshot.yaml.bak" "$ROUND_DIR/stage-manifest.snapshot.yaml"
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
