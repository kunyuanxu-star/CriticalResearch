#!/usr/bin/env bash
# test-document-adapter-paper.sh — Verify paper adapter loads and validators run.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-adp-paper-XXXXXX)
cd "$TEST_DIR"

echo "══ Paper Adapter Tests ══"
echo "Test dir: $TEST_DIR"
echo ""

cr workspace init > /dev/null 2>&1
cr start test-adp > /dev/null 2>&1
jq '.active_round = null' test-adp/state/project-state.json > test-adp/state/project-state.json.tmp && \
    mv test-adp/state/project-state.json.tmp test-adp/state/project-state.json

# ── Test 1: round --doc paper sets document_target ──
# ── Test 1+2: round --doc paper sets document_target and loads adapter ──
echo "── Test 1: round --doc paper sets document_target ──"
START_OUT=$(cr round test-adp --doc paper "test paper adapter" 2>&1 || true)
ROUND_DIR="test-adp/rounds/round-002"

DOC_TARGET=$(yq -r '.document_target // ""' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
if [ "$DOC_TARGET" = "paper" ]; then
    pass "document_target is paper"
else
    fail "document_target is '$DOC_TARGET'"
fi

DOC_TYPE=$(yq -r '.document_type // ""' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
if [ "$DOC_TYPE" = "paper" ]; then
    pass "document_type is paper"
else
    fail "document_type is '$DOC_TYPE'"
fi

if echo "$START_OUT" | grep -q "Document Adapter (paper)"; then
    pass "Paper adapter overlay loaded"
else
    fail "Paper adapter overlay not found"
fi

# ── Test 3: validator applies paper checks ──
echo ""
echo "── Test 3: validator applies paper checks ──"
cat > "$ROUND_DIR/round-contract.yaml" << 'RC'
schema_version: "1.0.0"
contract:
  target: "test target"
  scope:
    sections: []
    claims: []
    forbidden_scope: []
  intensity: standard
  success_criteria:
    - criterion_id: SC-001
      statement: "test criterion"
RC

VAL_OUT=$(cr-validate-stage "$TEST_DIR/test-adp" "$ROUND_DIR" s1_round_contract 2>&1 || true)
if echo "$VAL_OUT" | grep -q "Success criteria"; then
    pass "Paper validator checks success criteria"
else
    fail "Paper validator did not check success criteria"
fi

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo ""
echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
