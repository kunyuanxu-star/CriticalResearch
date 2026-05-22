#!/usr/bin/env bash
# test-full-round-enforcement.sh — E2E enforcement verification.
# Tests: 37-phase init, stop gate, skip prevention, coverage, transaction chain,
# no legacy phases, phase write guard.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
TEST_DIR=$(mktemp -d /tmp/cr-e2e-XXXXXX)
cd "$TEST_DIR"

echo "══ CriticalResearch E2E Enforcement Tests ══"
echo "Test dir: $TEST_DIR"
echo ""

# ── Test 1: 37-phase initialization ──
echo "── Test 1: 37-phase round initialization ──"
cr workspace init > /dev/null 2>&1
cr start e2e-test > /dev/null 2>&1
cr round e2e-test --mode paper > /dev/null 2>&1

PHASE_COUNT=$(yq -r '.phase_order | length' e2e-test/rounds/round-002/state.yaml 2>/dev/null || echo "0")
[ "$PHASE_COUNT" = "37" ] && pass "Phase count = 37" || fail "Phase count = $PHASE_COUNT (expected 37)"

WF=$(yq -r '.workflow_mode' e2e-test/rounds/round-002/state.yaml 2>/dev/null || echo "")
[ "$WF" = "paper" ] && pass "Workflow mode = paper" || fail "Workflow mode = $WF"

CURRENT=$(yq -r '.current_phase' e2e-test/rounds/round-002/state.yaml 2>/dev/null || echo "")
[ "$CURRENT" = "snapshot_paper_state" ] && pass "Current phase = snapshot_paper_state" || fail "Current phase = $CURRENT"

EXEC_FULL=$(yq -r '.execution_policy.full_round_required // false' e2e-test/rounds/round-002/state.yaml 2>/dev/null || echo "false")
[ "$EXEC_FULL" = "true" ] && pass "execution_policy.full_round_required = true" || fail "execution_policy.full_round_required = $EXEC_FULL"

EXEC_PARTIAL=$(yq -r '.execution_policy.allow_partial_stop // true' e2e-test/rounds/round-002/state.yaml 2>/dev/null || echo "true")
[ "$EXEC_PARTIAL" = "false" ] && pass "execution_policy.allow_partial_stop = false" || fail "execution_policy.allow_partial_stop = $EXEC_PARTIAL"

echo ""

# ── Test 2: Cannot skip phases ──
echo "── Test 2: Skip prevention ──"
cr-complete-phase e2e-test e2e-test/rounds/round-002 read_sources 2>&1 | grep -q "Cannot complete\|current_phase" && pass "Skip blocked: read_sources" || fail "Skip NOT blocked for read_sources"
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

# ── Test 4: No legacy phase names in codebase ──
echo "── Test 4: No legacy phase names ──"
LEGACY=$(grep -r "reconstruct_paper_state\|define_round_target\|plan_research\b\|run_retrieval\|adversarial_critique\|apply_patches_to_draft\|distill_knowledge\b" "$SCRIPT_DIR/../scripts/" "$SCRIPT_DIR/../templates/" "$SCRIPT_DIR/../schemas/" 2>/dev/null | grep -v '.git/' | grep -v 'Non-executable' || true)
[ -z "$LEGACY" ] && pass "No legacy phase names in scripts/templates/schemas" || fail "Legacy phase names found: $(echo "$LEGACY" | head -3)"
echo ""

# ── Test 5: Phase validator blocks empty artifacts ──
echo "── Test 5: Phase validator semantic checks ──"
# snapshot_paper_state needs core_claims > 0
echo "schema_version: '1.0.0'" > e2e-test/rounds/round-002/paper-state.yaml
echo "round_id: 2" >> e2e-test/rounds/round-002/paper-state.yaml
echo "thesis: {statement: ''}" >> e2e-test/rounds/round-002/paper-state.yaml
echo "core_claims: []" >> e2e-test/rounds/round-002/paper-state.yaml
echo "fragile_claims: []" >> e2e-test/rounds/round-002/paper-state.yaml
VAL_OUT=$(cr-validate-phase e2e-test e2e-test/rounds/round-002 snapshot_paper_state 2>&1 || true)
echo "$VAL_OUT" | grep -q "BLOCKED\|No core claims" && pass "Validator blocks empty paper-state" || fail "Validator did NOT block empty paper-state"
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
# Create minimal chain files so file-existence passes
for f in source-index.yaml evidence-ledger.yaml critique-ledger.yaml dispositions.yaml knowledge-delta.yaml knowledge-apply-log.yaml; do
  echo "schema_version: '1.0.0'" > "e2e-test/rounds/round-002/$f"
done
CHAIN_OUT=$(cr-validate-transaction-chain e2e-test e2e-test/rounds/round-002 2>&1 || true)
echo "$CHAIN_OUT" | grep -q "unknown patch\|BLOCKED" && pass "Chain detects broken patch reference" || fail "Chain did NOT detect broken patch reference"
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
