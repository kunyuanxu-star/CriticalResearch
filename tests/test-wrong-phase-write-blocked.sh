#!/usr/bin/env bash
# test-wrong-phase-write-blocked.sh — Verify wrong-phase writes are blocked.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-write-XXXXXX)
cd "$TEST_DIR"

echo "══ Wrong-Phase Write Block Tests ══"
echo "Test dir: $TEST_DIR"
echo ""

cr workspace init > /dev/null 2>&1
cr start e2e-write > /dev/null 2>&1
jq '.active_round = null' e2e-write/state/project-state.json > e2e-write/state/project-state.json.tmp && \
    mv e2e-write/state/project-state.json.tmp e2e-write/state/project-state.json

cr-start-paper-round e2e-write "test write blocks" > /dev/null 2>&1

ROUND_DIR="e2e-write/rounds/round-002"

# Set active project for scope.
echo "e2e-write" > "$TEST_DIR/_cr/active-project"

# ── Test 1: phase-check blocks write to non-allowed file ──
echo "── Test 1: phase-check blocks write to non-allowed scope ──"
# In snapshot_paper_state, allowed_write_scopes is only round:paper-state.yaml.
# Writing to patches/foo.yaml should be blocked.
PHASE_OUT=$(cr-scope phase-check "$TEST_DIR/e2e-write/rounds/round-002/patches/foo.yaml" 2>&1 || true)
if echo "$PHASE_OUT" | grep -qi "DENY\|allowed_write_scopes"; then
    pass "phase-check blocks write to patches in snapshot_paper_state phase"
else
    fail "phase-check did not block: ${PHASE_OUT:0:200}"
fi
echo ""

# ── Test 2: phase-check allows write to allowed file ──
echo "── Test 2: phase-check allows write to allowed scope ──"
PHASE_OUT=$(cr-scope phase-check "$TEST_DIR/e2e-write/rounds/round-002/paper-state.yaml" 2>&1 || true)
if echo "$PHASE_OUT" | grep -q "ALLOW"; then
    pass "phase-check allows write to paper-state.yaml in snapshot_paper_state phase"
else
    fail "phase-check did not allow: ${PHASE_OUT:0:200}"
fi
echo ""

# ── Test 3: protected files always blocked ──
echo "── Test 3: protected runtime files always blocked ──"
for protected in state.yaml phase-run-log.yaml round.yaml; do
    PHASE_OUT=$(cr-scope phase-check "$TEST_DIR/e2e-write/rounds/round-002/$protected" 2>&1 || true)
    if echo "$PHASE_OUT" | grep -qi "DENY.*protected\|protected.*DENY"; then
        pass "phase-check blocks write to $protected"
    else
        fail "phase-check did not block $protected: ${PHASE_OUT:0:200}"
    fi
done
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
