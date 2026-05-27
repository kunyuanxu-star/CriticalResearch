#!/usr/bin/env bash
# test-document-adapter-design-doc.sh — Verify design-doc adapter loads and validators run.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-adp-design-XXXXXX)
cd "$TEST_DIR"

echo "══ Design-Doc Adapter Tests ══"
echo "Test dir: $TEST_DIR"
echo ""

cr workspace init > /dev/null 2>&1
cr start test-adp > /dev/null 2>&1
cr document add test-adp design-doc > /dev/null 2>&1
jq '.active_round = null' test-adp/state/project-state.json > test-adp/state/project-state.json.tmp && \
    mv test-adp/state/project-state.json.tmp test-adp/state/project-state.json

# ── Test 1+2: round --doc design-doc sets document_target and loads adapter ──
echo "── Test 1: round --doc design-doc sets document_target ──"
START_OUT=$(cr round test-adp --doc design-doc "test design adapter" 2>&1 || true)
ROUND_DIR="test-adp/rounds/round-002"

DOC_TARGET=$(yq -r '.document_target // ""' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
if [ "$DOC_TARGET" = "design-doc" ]; then
    pass "document_target is design-doc"
else
    fail "document_target is '$DOC_TARGET'"
fi

DOC_TYPE=$(yq -r '.document_type // ""' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
if [ "$DOC_TYPE" = "design-doc" ]; then
    pass "document_type is design-doc"
else
    fail "document_type is '$DOC_TYPE'"
fi

if echo "$START_OUT" | grep -q "Document Adapter (design-doc)"; then
    pass "Design-doc adapter overlay loaded"
else
    fail "Design-doc adapter overlay not found"
fi

# ── Test 3: validator applies design-doc checks ──
echo ""
echo "── Test 3: validator applies design-doc checks ──"
cat > "$ROUND_DIR/critique-ledger.yaml" << 'CL'
schema_version: "1.0.0"
critiques:
  - critique_id: CRT-001
    severity: medium
    target_type: claim
    attack_statement: "test"
    why_damaging: "test"
    evidence_refs: [E1]
CL

VAL_OUT=$(cr-validate-stage "$TEST_DIR/test-adp" "$ROUND_DIR" s3_critical_review 2>&1 || true)
if echo "$VAL_OUT" | grep -q "Critiques"; then
    pass "Design-doc validator checks critiques >= 1"
else
    fail "Design-doc validator did not check critiques"
fi

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo ""
echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
