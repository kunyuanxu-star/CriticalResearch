#!/usr/bin/env bash
# test-no-bare-hash-key.sh — Verify bare path hash keys are rejected.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-bare-XXXXXX)
cd "$TEST_DIR"

echo "══ No Bare Hash Key Tests ══"
echo ""

cr workspace init > /dev/null 2>&1
cr start e2e-bare > /dev/null 2>&1
jq '.active_round = null' e2e-bare/state/project-state.json > e2e-bare/state/project-state.json.tmp && \
    mv e2e-bare/state/project-state.json.tmp e2e-bare/state/project-state.json

mkdir -p e2e-bare/writing e2e-bare/state
echo "# test paper" > e2e-bare/writing/paper-draft.md
echo "schema_version: \"1.0.0\"" > e2e-bare/state/claim-ledger.yaml

cr-start-paper-round e2e-bare "test bare key" > /dev/null 2>&1
ROUND_DIR="e2e-bare/rounds/round-002"
mkdir -p "$ROUND_DIR/_cr/knowledge"

echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/paper-state.yaml"

# ── Test 1: bare output hash key -> fail ──
echo "── Test 1: bare output hash key -> fail ──"
cat > "$ROUND_DIR/phase-run-log.yaml" << 'RL'
schema_version: "1.0.0"
events:
  - event: phase_started
    phase: snapshot_paper_state
    order: 1
    at: "2026-01-01T00:00:00Z"
    input_hashes:
      "project:writing/paper-draft.md": "abc"
      "project:state/claim-ledger.yaml": "def"
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
      "paper-state.yaml": "fff"
RL

yq -i '.phases.snapshot_paper_state.status = "complete"' "$ROUND_DIR/state.yaml" 2>/dev/null || true

OUT=$(cr-validate-phase-run-log "$TEST_DIR/e2e-bare" "$ROUND_DIR" 2>&1 || true)
if echo "$OUT" | grep -q "bare key"; then
    pass "Validator rejects bare output hash key"
else
    fail "Validator should reject bare output hash key"
    echo "$OUT" | head -5
fi
echo ""

# ── Test 2: bare input hash key -> fail ──
echo "── Test 2: bare input hash key -> fail ──"
cat > "$ROUND_DIR/phase-run-log.yaml" << 'RL2'
schema_version: "1.0.0"
events:
  - event: phase_started
    phase: snapshot_paper_state
    order: 1
    at: "2026-01-01T00:00:00Z"
    input_hashes:
      "writing/paper-draft.md": "abc"
      "project:state/claim-ledger.yaml": "def"
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
      "round:paper-state.yaml": "fff"
RL2

OUT=$(cr-validate-phase-run-log "$TEST_DIR/e2e-bare" "$ROUND_DIR" 2>&1 || true)
if echo "$OUT" | grep -q "bare key"; then
    pass "Validator rejects bare input hash key"
else
    fail "Validator should reject bare input hash key"
    echo "$OUT" | head -5
fi
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
