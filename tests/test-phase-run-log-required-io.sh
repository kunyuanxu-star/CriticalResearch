#!/usr/bin/env bash
# test-phase-run-log-required-io.sh — Verify manifest-driven required IO hash completeness.
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

echo "══ Phase Run Log Required IO Tests ══"
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

# Create phase 1 artifacts.
echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/paper-state.yaml"
echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/round-objective.yaml"

# ── Test 1: required input missing from input_hashes → fail ──
echo "── Test 1: required input missing from input_hashes → fail ──"
cat > "$ROUND_DIR/phase-run-log.yaml" << 'RL'
schema_version: "1.0.0"
events:
  - event: phase_started
    phase: snapshot_paper_state
    order: 1
    at: "2026-01-01T00:00:00Z"
    input_hashes:
      "writing/paper-draft.md": "abc123"
  - event: phase_completed
    phase: snapshot_paper_state
    order: 1
    at: "2026-01-01T00:01:00Z"
    status_transition:
      from: "running"
      to: complete
    validator:
      path: "scripts/cr-validate-phase"
      sha256: "test"
      exit_code: 0
    output_hashes:
      "paper-state.yaml": "def456"
RL

# Mark phase complete in state.
yq -i '.phases.snapshot_paper_state.status = "complete"' "$ROUND_DIR/state.yaml" 2>/dev/null || true

if cr-validate-phase-run-log "$TEST_DIR/e2e-io" "$ROUND_DIR" > /tmp/io1.out 2>&1; then
    fail "Validator should fail when required input missing from input_hashes"
else
    if grep -q "required input 'state/claim-ledger.yaml' missing from input_hashes" /tmp/io1.out; then
        pass "Validator detects missing required input in input_hashes"
    else
        fail "Wrong error message"
        cat /tmp/io1.out
    fi
fi
echo ""

# ── Test 2: required output missing from output_hashes → fail ──
echo "── Test 2: required output missing from output_hashes → fail ──"
cat > "$ROUND_DIR/phase-run-log.yaml" << 'RL2'
schema_version: "1.0.0"
events:
  - event: phase_started
    phase: snapshot_paper_state
    order: 1
    at: "2026-01-01T00:00:00Z"
    input_hashes:
      "writing/paper-draft.md": "abc123"
      "state/claim-ledger.yaml": "ghi789"
  - event: phase_completed
    phase: snapshot_paper_state
    order: 1
    at: "2026-01-01T00:01:00Z"
    status_transition:
      from: "running"
      to: complete
    validator:
      path: "scripts/cr-validate-phase"
      sha256: "test"
      exit_code: 0
    output_hashes: {}
RL2

if cr-validate-phase-run-log "$TEST_DIR/e2e-io" "$ROUND_DIR" > /tmp/io2.out 2>&1; then
    fail "Validator should fail when required output missing from output_hashes"
else
    if grep -q "required output 'paper-state.yaml' missing from output_hashes" /tmp/io2.out; then
        pass "Validator detects missing required output in output_hashes"
    else
        fail "Wrong error message"
        cat /tmp/io2.out
    fi
fi
echo ""

# ── Test 3: extra key in output_hashes → fail ──
echo "── Test 3: extra key in output_hashes → fail ──"
cat > "$ROUND_DIR/phase-run-log.yaml" << 'RL3'
schema_version: "1.0.0"
events:
  - event: phase_started
    phase: snapshot_paper_state
    order: 1
    at: "2026-01-01T00:00:00Z"
    input_hashes:
      "writing/paper-draft.md": "abc123"
      "state/claim-ledger.yaml": "ghi789"
  - event: phase_completed
    phase: snapshot_paper_state
    order: 1
    at: "2026-01-01T00:01:00Z"
    status_transition:
      from: "running"
      to: complete
    validator:
      path: "scripts/cr-validate-phase"
      sha256: "test"
      exit_code: 0
    output_hashes:
      "paper-state.yaml": "def456"
      "extra-file.yaml": "zzz999"
RL3

echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/extra-file.yaml"

if cr-validate-phase-run-log "$TEST_DIR/e2e-io" "$ROUND_DIR" > /tmp/io3.out 2>&1; then
    fail "Validator should fail when extra key in output_hashes"
else
    if grep -q "extra key 'extra-file.yaml'" /tmp/io3.out; then
        pass "Validator detects extra key in output_hashes"
    else
        fail "Wrong error message"
        cat /tmp/io3.out
    fi
fi
echo ""

# ── Test 4: all manifest required IO have hashes → pass ──
echo "── Test 4: all manifest required IO have hashes → pass ──"
H1=$(shasum -a 256 "$TEST_DIR/e2e-io/writing/paper-draft.md" | cut -d' ' -f1)
H2=$(shasum -a 256 "$TEST_DIR/e2e-io/state/claim-ledger.yaml" | cut -d' ' -f1)
H3=$(shasum -a 256 "$ROUND_DIR/paper-state.yaml" | cut -d' ' -f1)

cat > "$ROUND_DIR/phase-run-log.yaml" << RL4
schema_version: "1.0.0"
events:
  - event: phase_started
    phase: snapshot_paper_state
    order: 1
    at: "2026-01-01T00:00:00Z"
    input_hashes:
      "writing/paper-draft.md": "$H1"
      "state/claim-ledger.yaml": "$H2"
  - event: phase_completed
    phase: snapshot_paper_state
    order: 1
    at: "2026-01-01T00:01:00Z"
    status_transition:
      from: "running"
      to: complete
    validator:
      path: "scripts/cr-validate-phase"
      sha256: "test"
      exit_code: 0
    output_hashes:
      "paper-state.yaml": "$H3"
RL4

if cr-validate-phase-run-log "$TEST_DIR/e2e-io" "$ROUND_DIR" > /tmp/io4.out 2>&1; then
    pass "Validator passes when all required IO hashes present"
else
    fail "Validator should pass"
    cat /tmp/io4.out
fi
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
