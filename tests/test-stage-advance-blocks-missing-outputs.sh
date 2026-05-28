#!/usr/bin/env bash
# test-stage-advance-blocks-missing-outputs.sh — Verify cr stage advance
# fails when required_outputs are absent from the round directory.
set -euo pipefail

FAILS=0; PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'
pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
export CR_TEST_MODE=1

TEST_DIR=$(mktemp -d /tmp/cr-block-XXXXXX)
trap "rm -rf $TEST_DIR" EXIT
cd "$TEST_DIR"

echo "══ Stage Advance Blocks Missing Outputs Test ══"
echo ""

cr workspace init > /dev/null 2>&1
cr project init btest --domain systems > /dev/null 2>&1
cd btest
cr document add btest paper --type paper --path documents/paper.md > /dev/null 2>&1
echo "# Test Paper" > documents/paper.md

cr round start btest --workflow paper --doc paper --mode triage --objective "block test" > /dev/null 2>&1

ROUND_DIR=$(ls -d rounds/round-* | head -1)

# Stage 1 (contract) has required_outputs including contract.yaml
# Without creating contract.yaml, advance should fail
ADV_OUT=$(cr stage advance btest 2>&1 || true)

if echo "$ADV_OUT" | grep -qi "BLOCKED\|could not be completed\|missing\|fail"; then
    pass "stage advance blocked when required_outputs missing"
else
    fail "stage advance should have been blocked but was not (output: ${ADV_OUT:0:120})"
fi

echo ""
echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
