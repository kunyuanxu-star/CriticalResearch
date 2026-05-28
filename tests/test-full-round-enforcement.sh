#!/usr/bin/env bash
# test-full-round-enforcement.sh — V2 E2E enforcement verification.
# Tests: workflow-state structure, skip prevention, stop gate, no legacy stages,
# stage validator semantic checks.
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

TEST_DIR=$(mktemp -d /tmp/cr-e2e-XXXXXX)
cd "$TEST_DIR"

echo "══ CriticalResearch V2 E2E Enforcement Tests ══"
echo "Test dir: $TEST_DIR"
echo ""

# ── Test 1: Workflow-state initialization ──
echo "── Test 1: Workflow-state round initialization ──"
cr workspace init > /dev/null 2>&1
cr project init e2e-test --domain systems > /dev/null 2>&1
cd e2e-test
cr document add e2e-test paper --type paper --path documents/paper.md > /dev/null 2>&1
echo "# test paper" > documents/paper.md

cr round start e2e-test --workflow paper --doc paper --mode deep --objective "e2e test" > /dev/null 2>&1

ROUND_DIR=$(ls -d rounds/round-* | head -1)
WF_STATE="$ROUND_DIR/workflow-state.yaml"

STAGE_COUNT=$(yq -r '.stage_order | length' "$WF_STATE" 2>/dev/null || echo "0")
if [ "${STAGE_COUNT:-0}" -ge 1 ]; then
    pass "Stage count = $STAGE_COUNT"
else
    fail "Stage count = $STAGE_COUNT (expected >= 1)"
fi

WF_ID=$(yq -r '.workflow_id' "$WF_STATE" 2>/dev/null || echo "")
[ "$WF_ID" = "paper" ] && pass "Workflow id = paper" || fail "Workflow id = $WF_ID"

CURRENT=$(yq -r '.current_stage' "$WF_STATE" 2>/dev/null || echo "")
[ -n "$CURRENT" ] && pass "current_stage = $CURRENT" || fail "current_stage is empty"

# Verify contracts are materialized: required_outputs exist
RO_CHECK=$(yq -r ".stages.\"$CURRENT\".required_outputs | length" "$WF_STATE" 2>/dev/null || echo "0")
if [ "${RO_CHECK:-0}" -ge 1 ]; then
    pass "current stage has required_outputs"
else
    fail "current stage missing required_outputs"
fi

# Verify workflow-state has depends_on
DEP_CHECK=$(yq -r ".stages.\"$CURRENT\".depends_on // \"missing\"" "$WF_STATE" 2>/dev/null || echo "missing")
if [ "$DEP_CHECK" != "missing" ]; then
    pass "current stage has depends_on field"
else
    fail "current stage missing depends_on field"
fi

echo ""

# ── Test 2: No legacy stage names in codebase ──
echo "── Test 2: No legacy stage names ──"
LEGACY=$(grep -r "reconstruct_paper_state\|define_round_target\|plan_research\b\|run_retrieval\|adversarial_critique\|apply_patches_to_draft\|distill_knowledge\b" "$SCRIPT_DIR/../scripts/" "$SCRIPT_DIR/../templates/" "$SCRIPT_DIR/../schemas/" 2>/dev/null | grep -v '.git/' | grep -v 'Non-executable' || true)
[ -z "$LEGACY" ] && pass "No legacy stage names in scripts/templates/schemas" || fail "Legacy stage names found: $(echo "$LEGACY" | head -3)"
echo ""

# ── Test 3: Stage validator requires real data ──
echo "── Test 3: Stage validator semantic checks ──"
# Run validator on current stage without any outputs — should fail
VAL_OUT=$(cr-validate-stage "$PWD" "$ROUND_DIR" "$CURRENT" 2>&1 || true)
if echo "$VAL_OUT" | grep -q "FAIL\|missing"; then
    pass "Validator catches missing outputs"
else
    fail "Validator did NOT catch missing outputs (output: ${VAL_OUT:0:80})"
fi
echo ""

# ── Test 4: Stop gate works with v2 round ──
echo "── Test 4: Stop gate with v2 round ──"
STOP_OUT=$(cr-validate-stop "$PWD" 2>&1 || true)
if echo "$STOP_OUT" | grep -q "block\|BLOCKED\|incomplete"; then
    pass "Stop gate detects incomplete v2 round"
else
    fail "Stop gate did NOT block (output: ${STOP_OUT:0:80})"
fi
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
