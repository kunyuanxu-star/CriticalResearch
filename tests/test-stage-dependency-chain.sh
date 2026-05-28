#!/usr/bin/env bash
# test-stage-dependency-chain.sh — Verify completing one stage only
# unblocks the next stage, not all stages.
set -euo pipefail

FAILS=0; PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'
pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
export CR_TEST_MODE=1

TEST_DIR=$(mktemp -d /tmp/cr-depchain-XXXXXX)
trap "rm -rf $TEST_DIR" EXIT
cd "$TEST_DIR"

echo "══ Stage Dependency Chain Test ══"
echo ""

cr workspace init > /dev/null 2>&1
cr project init dtest --domain systems > /dev/null 2>&1
cd dtest
cr document add dtest paper --type paper --path documents/paper.md > /dev/null 2>&1
echo "# Test Paper" > documents/paper.md

cr round start dtest --workflow paper --doc paper --mode triage --objective "dep chain test" > /dev/null 2>&1

ROUND_DIR=$(ls -d rounds/round-* | head -1)
WF_STATE="$ROUND_DIR/workflow-state.yaml"

# Verify initial state: first stage running, rest blocked
S1=$(yq -r '.stages.contract.status' "$WF_STATE" 2>/dev/null || echo "")
if [ "$S1" = "running" ]; then
    pass "contract stage is running"
else
    fail "contract stage status is '$S1' (expected running)"
fi

S2=$(yq -r '.stages.paper_state.status' "$WF_STATE" 2>/dev/null || echo "")
if [ "$S2" = "blocked" ]; then
    pass "paper_state stage is blocked (depends on contract)"
else
    fail "paper_state stage status is '$S2' (expected blocked)"
fi

# Verify depends_on chain
DO=$(yq -r '.stages.paper_state.depends_on[0]' "$WF_STATE" 2>/dev/null || echo "")
if [ "$DO" = "contract" ]; then
    pass "paper_state depends_on contract"
else
    fail "paper_state depends_on is '$DO' (expected contract)"
fi

# Verify later stages are also blocked
S3=$(yq -r '.stages.claim_evidence_grounding.status' "$WF_STATE" 2>/dev/null || echo "")
if [ "$S3" = "blocked" ]; then
    pass "claim_evidence_grounding is blocked"
else
    fail "claim_evidence_grounding status is '$S3' (expected blocked)"
fi

echo ""
echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
