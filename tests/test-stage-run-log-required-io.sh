#!/usr/bin/env bash
# test-stage-run-log-required-io.sh — Verify manifest-driven required IO hash completeness with scoped paths.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-runlog-io-XXXXXX)
cd "$TEST_DIR"

echo "══ Stage Run Log Scoped IO Tests ══"
echo "Test dir: $TEST_DIR"
echo ""

# ── Setup ──
cr workspace init > /dev/null 2>&1
cr start e2e-io > /dev/null 2>&1
jq '.active_round = null' e2e-io/state/project-state.json > e2e-io/state/project-state.json.tmp && \
    mv e2e-io/state/project-state.json.tmp e2e-io/state/project-state.json

mkdir -p e2e-io/writing e2e-io/state
echo "# test paper" > e2e-io/writing/paper-draft.md
echo "schema_version: \"1.0.0\"" > e2e-io/state/claim-ledger.yaml

cr-start-paper-round e2e-io "test runlog io" > /dev/null 2>&1
ROUND_DIR="e2e-io/rounds/round-002"
mkdir -p "$ROUND_DIR/_cr/knowledge"

# Create stage 1 artifacts.
echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/round-contract.yaml"

# Compute actual hashes.
H1=$(cr-hash-artifact "$TEST_DIR/e2e-io" "$ROUND_DIR" "project:writing/paper-draft.md" 2>/dev/null || shasum -a 256 "$TEST_DIR/e2e-io/writing/paper-draft.md" | cut -d' ' -f1)
H2=$(cr-hash-artifact "$TEST_DIR/e2e-io" "$ROUND_DIR" "project:state/claim-ledger.yaml" 2>/dev/null || shasum -a 256 "$TEST_DIR/e2e-io/state/claim-ledger.yaml" | cut -d' ' -f1)
H3=$(cr-hash-artifact "$TEST_DIR/e2e-io" "$ROUND_DIR" "round:round-contract.yaml" 2>/dev/null || shasum -a 256 "$ROUND_DIR/round-contract.yaml" | cut -d' ' -f1)

# ── Test 1: required input missing from input_hashes → fail ──
echo "── Test 1: required input missing from input_hashes → fail ──"
cat > "$ROUND_DIR/stage-run-log.yaml" << 'RL'
schema_version: "1.0.0"
events:
  - event: stage_started
    stage: s1_round_contract
    order: 1
    at: "2026-01-01T00:00:00Z"
    input_hashes:
      "project:writing/paper-draft.md": "abc"
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
      "round:round-contract.yaml": "$H3"
RL

# Mark stage complete in state.
yq -i '.stages.s1_round_contract.status = "complete"' "$ROUND_DIR/state.yaml" 2>/dev/null || true

if cr-validate-stage-run-log "$TEST_DIR/e2e-io" "$ROUND_DIR" > /tmp/io1.out 2>&1; then
    fail "Validator did not detect missing input hash"
else
    if grep -q "missing from input_hashes" /tmp/io1.out; then
        pass "Validator detects missing input hash"
    else
        fail "Unexpected output: $(head -n 3 /tmp/io1.out)"
    fi
fi
echo ""

# ── Test 2: required output missing from output_hashes → fail ──
echo "── Test 2: required output missing from output_hashes → fail ──"
cat > "$ROUND_DIR/stage-run-log.yaml" << 'RL2'
schema_version: "1.0.0"
events:
  - event: stage_started
    stage: s1_round_contract
    order: 1
    at: "2026-01-01T00:00:00Z"
    input_hashes:
      "project:writing/paper-draft.md": "$H1"
      "project:state/claim-ledger.yaml": "$H2"
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
RL2

if cr-validate-stage-run-log "$TEST_DIR/e2e-io" "$ROUND_DIR" > /tmp/io2.out 2>&1; then
    fail "Validator did not detect missing output hash"
else
    if grep -q "missing from output_hashes\|output_hashes is empty" /tmp/io2.out; then
        pass "Validator detects missing output hash"
    else
        fail "Unexpected output: $(head -n 3 /tmp/io2.out)"
    fi
fi
echo ""

# ── Test 3: extra key in output_hashes → fail ──
echo "── Test 3: extra key in output_hashes → fail ──"
cat > "$ROUND_DIR/stage-run-log.yaml" << 'RL3'
schema_version: "1.0.0"
events:
  - event: stage_started
    stage: s1_round_contract
    order: 1
    at: "2026-01-01T00:00:00Z"
    input_hashes:
      "project:writing/paper-draft.md": "$H1"
      "project:state/claim-ledger.yaml": "$H2"
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
      "round:round-contract.yaml": "$H3"
      "round:extra-file.yaml": "0000000000000000000000000000000000000000000000000000000000000000"
RL3

echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/extra-file.yaml"

if cr-validate-stage-run-log "$TEST_DIR/e2e-io" "$ROUND_DIR" > /tmp/io3.out 2>&1; then
    fail "Validator did not detect extra output hash key"
else
    if grep -q "extra key" /tmp/io3.out; then
        pass "Validator detects extra output hash key"
    else
        fail "Unexpected output: $(head -n 3 /tmp/io3.out)"
    fi
fi
echo ""

# ── Test 4: bare path hash key → fail ──
echo "── Test 4: bare path hash key → fail ──"
cat > "$ROUND_DIR/stage-run-log.yaml" << 'RL4'
schema_version: "1.0.0"
events:
  - event: stage_started
    stage: s1_round_contract
    order: 1
    at: "2026-01-01T00:00:00Z"
    input_hashes:
      "project:writing/paper-draft.md": "$H1"
      "project:state/claim-ledger.yaml": "$H2"
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
      "round-contract.yaml": "$H3"
RL4

if cr-validate-stage-run-log "$TEST_DIR/e2e-io" "$ROUND_DIR" > /tmp/io4.out 2>&1; then
    fail "Validator did not detect bare path hash key"
else
    if grep -q "bare path\|bare key" /tmp/io4.out; then
        pass "Validator detects bare path hash key"
    else
        fail "Unexpected output: $(head -n 3 /tmp/io4.out)"
    fi
fi
echo ""

# ── Test 5: all manifest required IO have hashes → pass ──
echo "── Test 5: all manifest required IO have hashes → pass ──"
cat > "$ROUND_DIR/stage-run-log.yaml" << RL5
schema_version: "1.0.0"
events:
  - event: stage_started
    stage: s1_round_contract
    order: 1
    at: "2026-01-01T00:00:00Z"
    input_hashes:
      "project:writing/paper-draft.md": "$H1"
      "project:state/claim-ledger.yaml": "$H2"
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
      "round:round-contract.yaml": "$H3"
RL5

if cr-validate-stage-run-log "$TEST_DIR/e2e-io" "$ROUND_DIR" > /tmp/io5.out 2>&1; then
    pass "Validator passes with all required IO hashed"
else
    fail "Validator failed unexpectedly: $(head -n 3 /tmp/io5.out)"
fi
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
