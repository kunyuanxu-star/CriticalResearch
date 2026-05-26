#!/usr/bin/env bash
# test-scoped-run-log-io.sh — Verify scoped IO hash completeness.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-scoped-XXXXXX)
cd "$TEST_DIR"

echo "══ Scoped Run-Log IO Tests ══"
echo ""

cr workspace init > /dev/null 2>&1
cr start e2e-scoped > /dev/null 2>&1
jq '.active_round = null' e2e-scoped/state/project-state.json > e2e-scoped/state/project-state.json.tmp && \
    mv e2e-scoped/state/project-state.json.tmp e2e-scoped/state/project-state.json

mkdir -p e2e-scoped/writing e2e-scoped/state
echo "# test paper" > e2e-scoped/writing/paper-draft.md
echo "schema_version: \"1.0.0\"" > e2e-scoped/state/claim-ledger.yaml

cr-start-paper-round e2e-scoped "test scoped io" > /dev/null 2>&1
ROUND_DIR="e2e-scoped/rounds/round-002"
mkdir -p "$ROUND_DIR/_cr/knowledge"

echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/paper-state.yaml"
echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/round-objective.yaml"

# Compute real hashes.
H_IN1=$(cr-hash-artifact "$TEST_DIR/e2e-scoped" "$ROUND_DIR" "project:writing/paper-draft.md" 2>/dev/null || echo "")
H_IN2=$(cr-hash-artifact "$TEST_DIR/e2e-scoped" "$ROUND_DIR" "project:state/claim-ledger.yaml" 2>/dev/null || echo "")
H_OUT=$(cr-hash-artifact "$TEST_DIR/e2e-scoped" "$ROUND_DIR" "round:paper-state.yaml" 2>/dev/null || echo "")

# ── Test 1: scoped output key -> pass ──
echo "── Test 1: scoped output key -> pass ──"
cat > "$ROUND_DIR/phase-run-log.yaml" << RL
schema_version: "1.0.0"
events:
  - event: phase_started
    phase: snapshot_paper_state
    order: 1
    at: "2026-01-01T00:00:00Z"
    input_hashes:
      "project:writing/paper-draft.md": "$H_IN1"
      "project:state/claim-ledger.yaml": "$H_IN2"
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
      "round:paper-state.yaml": "$H_OUT"
RL

yq -i '.phases.snapshot_paper_state.status = "complete"' "$ROUND_DIR/state.yaml" 2>/dev/null || true

if cr-validate-phase-run-log "$TEST_DIR/e2e-scoped" "$ROUND_DIR" > /tmp/sc1.out 2>&1; then
    pass "Scoped output hash key accepted"
else
    fail "Scoped output hash key should be accepted"
    cat /tmp/sc1.out
fi
echo ""

# ── Test 2: artifact modified after hash recorded -> fail ──
echo "── Test 2: artifact modified -> hash mismatch -> fail ──"
echo "# MODIFIED" > "$ROUND_DIR/paper-state.yaml"

OUT=$(cr-validate-phase-run-log "$TEST_DIR/e2e-scoped" "$ROUND_DIR" 2>&1 || true)
if echo "$OUT" | grep -q "hash mismatch"; then
    pass "Validator detects artifact modification"
else
    fail "Validator should detect hash mismatch after artifact modified"
    echo "$OUT" | head -5
fi
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
