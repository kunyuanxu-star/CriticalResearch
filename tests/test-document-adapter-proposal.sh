#!/usr/bin/env bash
# test-document-adapter-proposal.sh — Verify proposal adapter loads and validators run.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-adp-proposal-XXXXXX)
cd "$TEST_DIR"

echo "══ Proposal Adapter Tests ══"
echo "Test dir: $TEST_DIR"
echo ""

cr workspace init > /dev/null 2>&1
cr start test-adp > /dev/null 2>&1
cr document add test-adp proposal > /dev/null 2>&1
jq '.active_round = null' test-adp/state/project-state.json > test-adp/state/project-state.json.tmp && \
    mv test-adp/state/project-state.json.tmp test-adp/state/project-state.json

# ── Test 1+2: round --doc proposal sets document_target and loads adapter ──
echo "── Test 1: round --doc proposal sets document_target ──"
START_OUT=$(cr round test-adp --doc proposal "test proposal adapter" 2>&1 || true)
ROUND_DIR="test-adp/rounds/round-002"

DOC_TARGET=$(yq -r '.document_target // ""' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
if [ "$DOC_TARGET" = "proposal" ]; then
    pass "document_target is proposal"
else
    fail "document_target is '$DOC_TARGET'"
fi

DOC_TYPE=$(yq -r '.document_type // ""' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
if [ "$DOC_TYPE" = "proposal" ]; then
    pass "document_type is proposal"
else
    fail "document_type is '$DOC_TYPE'"
fi

if echo "$START_OUT" | grep -q "Document Adapter (proposal)"; then
    pass "Proposal adapter overlay loaded"
else
    fail "Proposal adapter overlay not found"
fi

# ── Test 3: validator applies proposal-specific checks ──
echo ""
echo "── Test 3: validator applies proposal-specific checks ──"
cat > "$ROUND_DIR/round-contract.yaml" << 'RC'
schema_version: "1.0.0"
contract:
  target: "test target"
  problem_statement: "test problem"
  scope:
    sections: []
    claims: []
    forbidden_scope: []
  intensity: standard
  milestones:
    - id: M1
      title: "m1"
    - id: M2
      title: "m2"
    - id: M3
      title: "m3"
  success_criteria:
    - criterion_id: SC-001
      statement: "test criterion"
RC

VAL_OUT=$(cr-validate-stage "$TEST_DIR/test-adp" "$ROUND_DIR" s1_round_contract 2>&1 || true)
if echo "$VAL_OUT" | grep -q "Milestones"; then
    pass "Proposal validator checks milestones >= 3"
else
    fail "Proposal validator did not check milestones"
fi

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo ""
echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
