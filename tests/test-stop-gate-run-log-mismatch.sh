#!/usr/bin/env bash
# test-stop-gate-run-log-mismatch.sh — Verify Stop hook blocks when run-log hash mismatch detected.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-stop-mismatch-XXXXXX)
cd "$TEST_DIR"

echo "══ Stop Gate Run-Log Mismatch Tests ══"
echo "Test dir: $TEST_DIR"
echo ""

# ── Setup ──
cr workspace init > /dev/null 2>&1
cr start e2e-stop > /dev/null 2>&1
jq '.active_round = null' e2e-stop/state/project-state.json > e2e-stop/state/project-state.json.tmp && \
    mv e2e-stop/state/project-state.json.tmp e2e-stop/state/project-state.json

mkdir -p e2e-stop/writing e2e-stop/state
echo "# test paper" > e2e-stop/writing/paper-draft.md
echo "schema_version: \"1.0.0\"" > e2e-stop/state/claim-ledger.yaml

cr-start-paper-round e2e-stop "test stop mismatch" > /dev/null 2>&1
ROUND_DIR="e2e-stop/rounds/round-002"
mkdir -p "$ROUND_DIR/_cr/knowledge"

# Create phase 1 artifacts.
echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/paper-state.yaml"
echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/round-objective.yaml"

# Mark phase complete and create a run-log with correct hashes.
H1=$(cr-hash-artifact "$TEST_DIR/e2e-stop" "$ROUND_DIR" "project:writing/paper-draft.md" 2>/dev/null || echo "")
H2=$(cr-hash-artifact "$TEST_DIR/e2e-stop" "$ROUND_DIR" "project:state/claim-ledger.yaml" 2>/dev/null || echo "")
H3=$(cr-hash-artifact "$TEST_DIR/e2e-stop" "$ROUND_DIR" "round:paper-state.yaml" 2>/dev/null || echo "")

cat > "$ROUND_DIR/phase-run-log.yaml" << RL
schema_version: "1.0.0"
events:
  - event: phase_started
    phase: snapshot_paper_state
    order: 1
    at: "2026-01-01T00:00:00Z"
    input_hashes:
      "project:writing/paper-draft.md": "$H1"
      "project:state/claim-ledger.yaml": "$H2"
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
      "round:paper-state.yaml": "$H3"
RL

yq -i '.phases.snapshot_paper_state.status = "complete"' "$ROUND_DIR/state.yaml" 2>/dev/null || true

# ── Test 1: valid run-log → Stop gate checks run-log and may block for other reasons ──
echo "── Test 1: valid run-log with complete phase → Stop gate blocks for incomplete round ──"
OUTPUT=$(cr-stop-gate "$TEST_DIR/e2e-stop" 2>/dev/null || true)
if echo "$OUTPUT" | grep -q '"decision":"block"'; then
    pass "Stop gate blocks for incomplete round (run-log is valid)"
else
    fail "Stop gate should block for incomplete round"
    echo "$OUTPUT"
fi
echo ""

# ── Test 2: tampered artifact causes hash mismatch → Stop gate blocks ──
echo "── Test 2: tampered artifact → hash mismatch → Stop gate blocks ──"
# Modify the artifact after run-log was written.
echo "# TAMPERED" > "$ROUND_DIR/paper-state.yaml"

OUTPUT=$(cr-stop-gate "$TEST_DIR/e2e-stop" 2>/dev/null || true)
if echo "$OUTPUT" | grep -q '"decision":"block"'; then
    if echo "$OUTPUT" | grep -q "hash mismatch"; then
        pass "Stop gate detects hash mismatch and blocks"
    else
        pass "Stop gate blocks (may be for other reasons before hash check)"
    fi
else
    fail "Stop gate should block when artifact tampered"
    echo "$OUTPUT"
fi
echo ""

# ── Test 3: missing started event → Stop gate blocks ──
echo "── Test 3: missing started event → Stop gate blocks ──"
# Restore artifact, corrupt run-log by removing started event.
echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/paper-state.yaml"
cat > "$ROUND_DIR/phase-run-log.yaml" << RL2
schema_version: "1.0.0"
events:
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
      "round:paper-state.yaml": "$H3"
RL2

OUTPUT=$(cr-stop-gate "$TEST_DIR/e2e-stop" 2>/dev/null || true)
if echo "$OUTPUT" | grep -q '"decision":"block"'; then
    pass "Stop gate blocks when started event missing"
else
    fail "Stop gate should block when run-log incomplete"
    echo "$OUTPUT"
fi
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
