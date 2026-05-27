#!/usr/bin/env bash
# test-stage-run-log.sh — Verify stage-run-log hard gate enforcement.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-runlog-XXXXXX)
cd "$TEST_DIR"

echo "══ Stage Run Log Tests ══"
echo "Test dir: $TEST_DIR"
echo ""

cr workspace init > /dev/null 2>&1
cr start e2e-log > /dev/null 2>&1
jq '.active_round = null' e2e-log/state/project-state.json > e2e-log/state/project-state.json.tmp && \
    mv e2e-log/state/project-state.json.tmp e2e-log/state/project-state.json

echo "# test paper" > e2e-log/documents/paper.md
echo "schema_version: \"1.0.0\"" > e2e-log/state/claim-ledger.yaml

cr-start-paper-round e2e-log "test run log" > /dev/null 2>&1
ROUND_DIR="e2e-log/rounds/round-002"

# Compute real hashes for scoped paths.
REAL_HASH_OUT=$(cr-hash-artifact "$TEST_DIR/e2e-log" "$ROUND_DIR" "round:round-contract.yaml" 2>/dev/null || echo "")
REAL_HASH_IN1=$(cr-hash-artifact "$TEST_DIR/e2e-log" "$ROUND_DIR" "project:documents/paper.md" 2>/dev/null || echo "")
REAL_HASH_IN2=$(cr-hash-artifact "$TEST_DIR/e2e-log" "$ROUND_DIR" "project:state/claim-ledger.yaml" 2>/dev/null || echo "")

# ── Test 1: state complete but no started event → fail ──
echo "── Test 1: state complete but no started event → fail ──"
yq -i '.stages.s1_round_contract.status = "complete"' "$ROUND_DIR/state.yaml" 2>/dev/null || true
cat > "$ROUND_DIR/stage-run-log.yaml" << 'HDR'
schema_version: "1.0.0"
events:
  - event: stage_completed
    stage: s1_round_contract
    order: 1
    at: "2026-01-01T00:00:01Z"
    status_transition:
      from: "running"
      to: complete
    validator:
      path: "scripts/cr-validate-stage"
      sha256: "0000000000000000000000000000000000000000000000000000000000000000"
      exit_code: 0
    output_hashes:
      "round:round-contract.yaml": "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
HDR

VALIDATE_OUT=$(cr-validate-stage-run-log "$TEST_DIR/e2e-log" "$ROUND_DIR" 2>&1 || true)
if echo "$VALIDATE_OUT" | grep -qi "NO stage_started"; then
    pass "Validator detects missing started event"
else
    fail "Validator did not detect missing started: ${VALIDATE_OUT:0:300}"
fi
echo ""

# ── Test 2: started+completed order mismatch → fail ──
echo "── Test 2: started/completed order mismatch → fail ──"
cat > "$ROUND_DIR/stage-run-log.yaml" << 'HDR'
schema_version: "1.0.0"
events:
  - event: stage_started
    stage: s1_round_contract
    order: 2
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
      sha256: "0000000000000000000000000000000000000000000000000000000000000000"
      exit_code: 0
    output_hashes:
      "round:round-contract.yaml": "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
HDR

VALIDATE_OUT=$(cr-validate-stage-run-log "$TEST_DIR/e2e-log" "$ROUND_DIR" 2>&1 || true)
if echo "$VALIDATE_OUT" | grep -qi "order.*mismatch\|order.*expected"; then
    pass "Validator detects order mismatch"
else
    fail "Validator did not detect order mismatch: ${VALIDATE_OUT:0:300}"
fi
echo ""

# ── Test 3: completed_at < started_at → fail ──
echo "── Test 3: completed_at before started_at → fail ──"
cat > "$ROUND_DIR/stage-run-log.yaml" << 'HDR'
schema_version: "1.0.0"
events:
  - event: stage_started
    stage: s1_round_contract
    order: 1
    at: "2026-01-01T00:00:02Z"
    input_hashes:
      "project:documents/paper.md": "abc"
      "project:state:claim-ledger.yaml": "def"
  - event: stage_completed
    stage: s1_round_contract
    order: 1
    at: "2026-01-01T00:00:01Z"
    status_transition:
      from: "running"
      to: complete
    validator:
      path: "scripts/cr-validate-stage"
      sha256: "0000000000000000000000000000000000000000000000000000000000000000"
      exit_code: 0
    output_hashes:
      "round:round-contract.yaml": "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
HDR

VALIDATE_OUT=$(cr-validate-stage-run-log "$TEST_DIR/e2e-log" "$ROUND_DIR" 2>&1 || true)
if echo "$VALIDATE_OUT" | grep -qi "completed_at.*started_at\|started_at.*completed_at"; then
    pass "Validator detects timestamp inversion"
else
    fail "Validator did not detect timestamp inversion: ${VALIDATE_OUT:0:300}"
fi
echo ""

# ── Test 4: required_outputs present but output_hashes empty → fail ──
echo "── Test 4: required_outputs non-empty but output_hashes empty → fail ──"
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
  - event: stage_completed
    stage: s1_round_contract
    order: 1
    at: "2026-01-01T00:00:01Z"
    status_transition:
      from: "running"
      to: complete
    validator:
      path: "scripts/cr-validate-stage"
      sha256: "0000000000000000000000000000000000000000000000000000000000000000"
      exit_code: 0
    output_hashes: {}
HDR

VALIDATE_OUT=$(cr-validate-stage-run-log "$TEST_DIR/e2e-log" "$ROUND_DIR" 2>&1 || true)
if echo "$VALIDATE_OUT" | grep -qi "output_hashes is empty\|empty.*output_hashes"; then
    pass "Validator detects empty output_hashes"
else
    fail "Validator did not detect empty output_hashes: ${VALIDATE_OUT:0:300}"
fi
echo ""

# ── Test 5: hash mismatch → fail ──
echo "── Test 5: output hash mismatch → fail ──"
echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/round-contract.yaml"
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
  - event: stage_completed
    stage: s1_round_contract
    order: 1
    at: "2026-01-01T00:00:01Z"
    status_transition:
      from: "running"
      to: complete
    validator:
      path: "scripts/cr-validate-stage"
      sha256: "0000000000000000000000000000000000000000000000000000000000000000"
      exit_code: 0
    output_hashes:
      "round:round-contract.yaml": "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
HDR

VALIDATE_OUT=$(cr-validate-stage-run-log "$TEST_DIR/e2e-log" "$ROUND_DIR" 2>&1 || true)
if echo "$VALIDATE_OUT" | grep -qi "hash mismatch"; then
    pass "Validator detects hash mismatch"
else
    fail "Validator did not detect hash mismatch: ${VALIDATE_OUT:0:300}"
fi
echo ""

# ── Test 6: started+completed with matching hashes → pass ──
echo "── Test 6: valid started+completed with matching hashes → pass ──"
# Recompute hashes after Test 5 may have modified the file.
REAL_HASH_OUT=$(cr-hash-artifact "$TEST_DIR/e2e-log" "$ROUND_DIR" "round:round-contract.yaml" 2>/dev/null || echo "")
REAL_HASH_IN1=$(cr-hash-artifact "$TEST_DIR/e2e-log" "$ROUND_DIR" "project:documents/paper.md" 2>/dev/null || echo "")
REAL_HASH_IN2=$(cr-hash-artifact "$TEST_DIR/e2e-log" "$ROUND_DIR" "project:state/claim-ledger.yaml" 2>/dev/null || echo "")
cat > "$ROUND_DIR/stage-run-log.yaml" << HDR
schema_version: "1.0.0"
events:
  - event: stage_started
    stage: s1_round_contract
    order: 1
    at: "2026-01-01T00:00:00Z"
    input_hashes:
      "project:documents/paper.md": "$REAL_HASH_IN1"
      "project:state/claim-ledger.yaml": "$REAL_HASH_IN2"
  - event: stage_completed
    stage: s1_round_contract
    order: 1
    at: "2026-01-01T00:00:01Z"
    status_transition:
      from: "running"
      to: complete
    validator:
      path: "scripts/cr-validate-stage"
      sha256: "0000000000000000000000000000000000000000000000000000000000000000"
      exit_code: 0
    output_hashes:
      "round:round-contract.yaml": "$REAL_HASH_OUT"
HDR

VALIDATE_OUT=$(cr-validate-stage-run-log "$TEST_DIR/e2e-log" "$ROUND_DIR" 2>&1 || true)
if echo "$VALIDATE_OUT" | grep -qi "Stage run log validation passed"; then
    pass "Validator passes for valid started+completed pair"
else
    fail "Validator did not pass: ${VALIDATE_OUT:0:300}"
fi
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
