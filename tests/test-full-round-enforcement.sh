#!/usr/bin/env bash
# test-full-round-enforcement.sh — E2E enforcement verification.
# Tests: 8-stage init, stop gate, skip prevention, coverage, transaction chain,
# no legacy stages, stage write guard.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-e2e-XXXXXX)
cd "$TEST_DIR"

echo "══ CriticalResearch E2E Enforcement Tests ══"
echo "Test dir: $TEST_DIR"
echo ""

# ── Test 1: 8-stage initialization ──
echo "── Test 1: 8-stage round initialization ──"
cr workspace init > /dev/null 2>&1
cr start e2e-test > /dev/null 2>&1

# Paper rounds require prerequisite files.
mkdir -p e2e-test/writing e2e-test/state
echo "# test paper" > e2e-test/documents/paper.md
echo "schema_version: \"1.0.0\"" > e2e-test/state/claim-ledger.yaml

# Clear any active round from cr start so cr-start-paper-round can create a new one.
jq '.active_round = null' e2e-test/state/project-state.json > e2e-test/state/project-state.json.tmp && \
    mv e2e-test/state/project-state.json.tmp e2e-test/state/project-state.json

cr round e2e-test --mode paper "test objective" > /dev/null 2>&1

STAGE_COUNT=$(yq -r '.stage_order | length' e2e-test/rounds/round-002/state.yaml 2>/dev/null || echo "0")
[ "$STAGE_COUNT" = "8" ] && pass "Stage count = 8" || fail "Stage count = $STAGE_COUNT (expected 8)"

WF=$(yq -r '.workflow_mode' e2e-test/rounds/round-002/state.yaml 2>/dev/null || echo "")
[ "$WF" = "paper" ] && pass "Workflow mode = paper" || fail "Workflow mode = $WF"

CURRENT=$(yq -r '.current_stage' e2e-test/rounds/round-002/state.yaml 2>/dev/null || echo "")
[ "$CURRENT" = "s1_round_contract" ] && pass "Current stage = s1_round_contract" || fail "Current stage = $CURRENT"

EXEC_FULL=$(yq -r '.execution_policy.full_round_required // false' e2e-test/rounds/round-002/state.yaml 2>/dev/null || echo "false")
[ "$EXEC_FULL" = "true" ] && pass "execution_policy.full_round_required = true" || fail "execution_policy.full_round_required = $EXEC_FULL"

EXEC_PARTIAL=$(yq -r '.execution_policy.allow_partial_stop' e2e-test/rounds/round-002/state.yaml 2>/dev/null || echo "true")
[ "$EXEC_PARTIAL" = "false" ] && pass "execution_policy.allow_partial_stop = false" || fail "execution_policy.allow_partial_stop = $EXEC_PARTIAL"

echo ""

# ── Test 2: Cannot skip stages ──
echo "── Test 2: Skip prevention ──"
SKIP_OUT=$(cr-complete-stage e2e-test e2e-test/rounds/round-002 s2_evidence_grounding 2>&1 || true)
echo "$SKIP_OUT" | grep -qE "Cannot complete|current_stage" && pass "Skip blocked: s2_evidence_grounding" || fail "Skip NOT blocked for s2_evidence_grounding"
echo ""

# ── Test 3: Stop gate blocks incomplete round ──
echo "── Test 3: Stop gate blocking ──"
STOP_OUT=$(cr-validate-stop e2e-test 2>&1 || true)
if echo "$STOP_OUT" | grep -q "block\|BLOCKED"; then
    pass "Stop gate blocks incomplete round"
else
    fail "Stop gate did NOT block (output: ${STOP_OUT:0:80})"
fi
echo ""

# ── Test 4: No legacy stage names in codebase ──
echo "── Test 4: No legacy stage names ──"
LEGACY=$(grep -r "reconstruct_paper_state\|define_round_target\|plan_research\b\|run_retrieval\|adversarial_critique\|apply_patches_to_draft\|distill_knowledge\b" "$SCRIPT_DIR/../scripts/" "$SCRIPT_DIR/../templates/" "$SCRIPT_DIR/../schemas/" 2>/dev/null | grep -v '.git/' | grep -v 'Non-executable' || true)
[ -z "$LEGACY" ] && pass "No legacy stage names in scripts/templates/schemas" || fail "Legacy stage names found: $(echo "$LEGACY" | head -3)"
echo ""

# ── Test 5: Stage validator blocks empty artifacts ──
echo "── Test 5: Stage validator semantic checks ──"
# s1_round_contract needs round-contract.yaml with target >= 10 chars
echo "schema_version: '1.0.0'" > e2e-test/rounds/round-002/round-contract.yaml
echo "round_id: 2" >> e2e-test/rounds/round-002/round-contract.yaml
echo "contract:" >> e2e-test/rounds/round-002/round-contract.yaml
echo "  target: \"\"" >> e2e-test/rounds/round-002/round-contract.yaml
echo "  scope:" >> e2e-test/rounds/round-002/round-contract.yaml
echo "    sections: []" >> e2e-test/rounds/round-002/round-contract.yaml
echo "    claims: []" >> e2e-test/rounds/round-002/round-contract.yaml
echo "    forbidden_scope: []" >> e2e-test/rounds/round-002/round-contract.yaml
echo "  intensity: standard" >> e2e-test/rounds/round-002/round-contract.yaml
echo "  required_outputs: []" >> e2e-test/rounds/round-002/round-contract.yaml
echo "  success_criteria: []" >> e2e-test/rounds/round-002/round-contract.yaml
VAL_OUT=$(cr-validate-stage e2e-test e2e-test/rounds/round-002 s1_round_contract 2>&1 || true)
echo "$VAL_OUT" | grep -q "BLOCKED\|target\|success_criteria" && pass "Validator blocks empty round-contract" || fail "Validator did NOT block empty round-contract"
echo ""

# ── Test 6: Transaction chain detects broken links ──
echo "── Test 6: Transaction chain broken-link detection ──"
mkdir -p e2e-test/rounds/round-002/patches
# Create a writing-diff referencing a non-existent patch
cat > e2e-test/rounds/round-002/writing-diff.yaml << 'YAML'
schema_version: "1.0.0"
round_id: 2
draft_before_sha256: "abc"
draft_after_sha256: "def"
changes:
  - patch_id: "PP-NONEXISTENT"
    section_anchor: "introduction"
    before_text: "old"
    after_text: "new"
    status: "applied"
YAML
# Create a valid patch so patch ID checking is triggered
cat > e2e-test/rounds/round-002/patches/PP-001.yaml << 'PATCH'
schema_version: "1.0.0"
patch_id: PP-001
lifecycle_status: proposed
PATCH
# Create minimal chain files so file-existence passes
for f in source-index.yaml evidence-ledger.yaml critique-ledger.yaml review-disposition.yaml knowledge-delta.yaml knowledge-apply-log.yaml; do
  echo "schema_version: '1.0.0'" > "e2e-test/rounds/round-002/$f"
done
CHAIN_OUT=$(cr-validate-transaction-chain e2e-test e2e-test/rounds/round-002 2>&1 || true)
echo "$CHAIN_OUT" | grep -qE "unknown patch|BLOCKED" && pass "Chain detects broken patch reference" || fail "Chain did NOT detect broken patch reference"
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
