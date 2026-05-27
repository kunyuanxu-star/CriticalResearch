#!/usr/bin/env bash
# test-document-adapter-survey.sh — Verify survey adapter loads and validators run.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-adp-survey-XXXXXX)
cd "$TEST_DIR"

echo "══ Survey Adapter Tests ══"
echo "Test dir: $TEST_DIR"
echo ""

cr workspace init > /dev/null 2>&1
cr start test-adp > /dev/null 2>&1
cr document add test-adp survey > /dev/null 2>&1
jq '.active_round = null' test-adp/state/project-state.json > test-adp/state/project-state.json.tmp && \
    mv test-adp/state/project-state.json.tmp test-adp/state/project-state.json

# ── Test 1+2: round --doc survey sets document_target and loads adapter ──
echo "── Test 1: round --doc survey sets document_target ──"
START_OUT=$(cr round test-adp --doc survey "test survey adapter" 2>&1 || true)
ROUND_DIR="test-adp/rounds/round-002"

DOC_TARGET=$(yq -r '.document_target // ""' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
if [ "$DOC_TARGET" = "survey" ]; then
    pass "document_target is survey"
else
    fail "document_target is '$DOC_TARGET'"
fi

DOC_TYPE=$(yq -r '.document_type // ""' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
if [ "$DOC_TYPE" = "survey" ]; then
    pass "document_type is survey"
else
    fail "document_type is '$DOC_TYPE'"
fi

if echo "$START_OUT" | grep -q "Document Adapter (survey)"; then
    pass "Survey adapter overlay loaded"
else
    fail "Survey adapter overlay not found"
fi

# ── Test 3: validator applies survey-specific checks ──
echo ""
echo "── Test 3: validator applies survey-specific checks ──"
cat > "$ROUND_DIR/evidence-ledger.yaml" << 'EV'
schema_version: "1.0.0"
evidence:
  - id: E1
    source: S1
    category: supporting
sources_reviewed:
  - id: S1
  - id: S2
  - id: S3
  - id: S4
  - id: S5
EV

VAL_OUT=$(cr-validate-stage "$TEST_DIR/test-adp" "$ROUND_DIR" s2_evidence_grounding 2>&1 || true)
if echo "$VAL_OUT" | grep -q "Sources reviewed"; then
    pass "Survey validator checks sources_reviewed >= 5"
else
    fail "Survey validator did not check sources_reviewed"
fi

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo ""
echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
