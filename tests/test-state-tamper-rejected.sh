#!/usr/bin/env bash
# test-state-tamper-rejected.sh — Verify manual state tampering is detected.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-tamper-XXXXXX)
cd "$TEST_DIR"

echo "══ State Tamper Rejection Tests ══"
echo "Test dir: $TEST_DIR"
echo ""

cr workspace init > /dev/null 2>&1
cr start e2e-tamper > /dev/null 2>&1
jq '.active_round = null' e2e-tamper/state/project-state.json > e2e-tamper/state/project-state.json.tmp && \
    mv e2e-tamper/state/project-state.json.tmp e2e-tamper/state/project-state.json

cr-start-paper-round e2e-tamper "test tamper" > /dev/null 2>&1

ROUND_DIR="e2e-tamper/rounds/round-002"

# ── Test 1: Manual state edit without run-log → detected ──
echo "── Test 1: Manual state.yaml edit without run-log → detected ──"
# Mark a stage complete without recording in stage-run-log.
yq -i '.stages.s1_round_contract.status = "complete"' "$ROUND_DIR/state.yaml" 2>/dev/null || true
yq -i '.stages.s1_round_contract.completed_at = "2026-01-01T00:00:00Z"' "$ROUND_DIR/state.yaml" 2>/dev/null || true

# Create a run-log with only a started event (no completed) so validator doesn't early-exit.
cat > "$ROUND_DIR/stage-run-log.yaml" << 'HDR'
schema_version: "1.0.0"
events:
  - event: stage_started
    stage: s1_round_contract
    order: 1
    at: "2026-01-01T00:00:00Z"
    input_hashes:
      "project:documents/paper.md": "abc"
      "project:state/claim-ledger.yaml": "def"
HDR

VALIDATE_OUT=$(cr-validate-stage-run-log "$TEST_DIR/e2e-tamper" "$ROUND_DIR" 2>&1 || true)
if echo "$VALIDATE_OUT" | grep -qi "NO stage_completed event"; then
    pass "Validator detects missing completed event"
else
    fail "Validator did not detect tampered state: ${VALIDATE_OUT:0:200}"
fi
echo ""

# ── Test 2: Manual stage-run-log edit → hash mismatch detected ──
echo "── Test 2: Manual stage-run-log edit → hash mismatch detected ──"
# Keep s1_round_contract complete so count matches, but use wrong hash in run-log.
yq -i '.stages.s1_round_contract.status = "complete"' "$ROUND_DIR/state.yaml" 2>/dev/null || true
yq -i '.stages.s1_round_contract.completed_at = "2026-01-01T00:00:00Z"' "$ROUND_DIR/state.yaml" 2>/dev/null || true

# Create the output file with real content.
echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/round-contract.yaml"
echo "thesis: \"test thesis\"" >> "$ROUND_DIR/round-contract.yaml"
REAL_HASH=$(shasum -a 256 "$ROUND_DIR/round-contract.yaml" | cut -d' ' -f1)

# Create a valid-looking run-log entry but with WRONG hash.
cat > "$ROUND_DIR/stage-run-log.yaml" << FAKE
schema_version: "1.0.0"
events:
  - event: stage_started
    stage: s1_round_contract
    order: 1
    at: "2026-01-01T00:00:00Z"
    input_hashes:
      "project:documents/paper.md": "abc"
      "project:state/claim-ledger.yaml": "def"
  - event: stage_completed
    stage: s1_round_contract
    order: 1
    at: "2026-01-01T00:00:01Z"
    status_transition:
      from: "running"
      to: complete
    validator:
      path: "scripts/cr-validate-stage"
      sha256: "test"
      exit_code: 0
    output_hashes:
      "round:round-contract.yaml": "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
FAKE

VALIDATE_OUT=$(cr-validate-stage-run-log "$TEST_DIR/e2e-tamper" "$ROUND_DIR" 2>&1 || true)
if echo "$VALIDATE_OUT" | grep -qi "hash mismatch"; then
    pass "Validator detects hash mismatch in run-log"
else
    fail "Validator did not detect hash mismatch: ${VALIDATE_OUT:0:200}"
fi
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
