#!/usr/bin/env bash
# test-project-knowledge-shared.sh — Verify project knowledge persists across document-targeting rounds.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-knowledge-XXXXXX)
cd "$TEST_DIR"

echo "══ Project Knowledge Shared Tests ══"
echo "Test dir: $TEST_DIR"
echo ""

cr workspace init > /dev/null 2>&1
cr start test-kn > /dev/null 2>&1
cr document add test-kn proposal > /dev/null 2>&1

# Close round-001 from cr start.
jq '.active_round = null' test-kn/state/project-state.json > test-kn/state/project-state.json.tmp && \
    mv test-kn/state/project-state.json.tmp test-kn/state/project-state.json

# ── Test 1: knowledge directory exists ──
echo "── Test 1: knowledge directory exists ──"
if [ -d "test-kn/knowledge" ]; then
    pass "knowledge/ directory exists"
else
    fail "knowledge/ directory missing"
fi

# ── Test 2: round targeting paper updates state ──
echo ""
echo "── Test 2: round targeting paper updates state ──"
cr round test-kn --doc paper "test paper round" > /dev/null 2>&1
ROUND_DIR="test-kn/rounds/round-002"

DOC_TARGET=$(yq -r '.document_target // ""' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
if [ "$DOC_TARGET" = "paper" ]; then
    pass "First round targets paper"
else
    fail "First round document_target is '$DOC_TARGET'"
fi

# Close the paper round.
jq '.active_round = null' test-kn/state/project-state.json > test-kn/state/project-state.json.tmp && \
    mv test-kn/state/project-state.json.tmp test-kn/state/project-state.json

# ── Test 3: round targeting proposal updates state ──
echo ""
echo "── Test 3: round targeting proposal updates state ──"
cr round test-kn --doc proposal "test proposal round" > /dev/null 2>&1
ROUND_DIR="test-kn/rounds/round-003"

DOC_TARGET=$(yq -r '.document_target // ""' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
if [ "$DOC_TARGET" = "proposal" ]; then
    pass "Second round targets proposal"
else
    fail "Second round document_target is '$DOC_TARGET'"
fi

# ── Test 4: project documents registry intact ──
echo ""
echo "── Test 4: project documents registry intact ──"
DOC_COUNT=$(yq -r '.documents | length // 0' test-kn/project.yaml 2>/dev/null || echo "0")
if [ "$DOC_COUNT" -ge 2 ]; then
    pass "Project registry has >= 2 documents"
else
    fail "Project registry has $DOC_COUNT documents"
fi

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo ""
echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
