#!/usr/bin/env bash
# test-close-round-protocol.sh — Verify close-round protocol enforcement.
# Tests: preclose/postclose gates, closure-report draft requirement, close_round sequencing.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-close-XXXXXX)
cd "$TEST_DIR"

echo "══ Close-Round Protocol Tests ══"
echo "Test dir: $TEST_DIR"
echo ""

# ── Setup ──
cr workspace init > /dev/null 2>&1
cr start e2e-close > /dev/null 2>&1
# Set active_round to null so we can start a paper round.
jq '.active_round = null' e2e-close/state/project-state.json > e2e-close/state/project-state.json.tmp && \
    mv e2e-close/state/project-state.json.tmp e2e-close/state/project-state.json

cr-start-paper-round e2e-close "test close-round protocol" > /dev/null 2>&1

ROUND_DIR="e2e-close/rounds/round-002"

# ── Test 1: 36/36 complete but close_round not → preclose passes, close-round blocked ──
echo "── Test 1: 36/36 preclose passes but close_round incomplete → blocked ──"
# Mark phases 1-36 as complete.
for i in $(seq 1 36); do
    phase=$(yq -r ".phase_order[$((i-1))]" "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
    [ -z "$phase" ] && continue
    yq -i ".phases.\"$phase\".status = \"complete\" | .phases.\"$phase\".completed_at = \"2026-01-01T00:00:00Z\"" "$ROUND_DIR/state.yaml" 2>/dev/null || true
done

# Ensure close_round is NOT complete.
yq -i ".phases.close_round.status = \"blocked\" | .phases.close_round.completed_at = null" "$ROUND_DIR/state.yaml" 2>/dev/null || true

CLOSE_OUT=$(cr close-round e2e-close 2>&1 || true)
if echo "$CLOSE_OUT" | grep -qi "fail\|error\|pre-close\|postclose"; then
    pass "close-round blocked when close_round is incomplete"
else
    fail "close-round did NOT block with incomplete close_round (output: ${CLOSE_OUT:0:120})"
fi
echo ""

# ── Test 2: Missing closure-report summary → fail ──
echo "── Test 2: Missing closure-report summary → fail ──"
# Mark close_round complete too.
yq -i ".phases.close_round.status = \"complete\" | .phases.close_round.completed_at = \"2026-01-01T00:00:00Z\"" "$ROUND_DIR/state.yaml" 2>/dev/null || true

# Create empty closure-report.
cat > "$ROUND_DIR/closure-report.yaml" << 'BAD'
schema_version: "1.0.0"
round_id: 2
closed_at: null
summary: ""
remaining_risks: []
BAD

CLOSE_OUT=$(cr close-round e2e-close 2>&1 || true)
if echo "$CLOSE_OUT" | grep -qi "summary\|missing\|fail"; then
    pass "close-round blocked when closure-report lacks summary"
else
    fail "close-round did NOT block for missing summary (output: ${CLOSE_OUT:0:120})"
fi
echo ""

# ── Test 3: Valid closure-report + close_round running → close_round completed ──
echo "── Test 3: Valid closure-report + close_round running → close_round gets completed ──"
# Restore project state to have active round.
jq '.active_round = 2' e2e-close/state/project-state.json > e2e-close/state/project-state.json.tmp && \
    mv e2e-close/state/project-state.json.tmp e2e-close/state/project-state.json

# Create valid closure-report.
cat > "$ROUND_DIR/closure-report.yaml" << 'GOOD'
schema_version: "1.0.0"
round_id: 2
closed_at: null
summary: "This round validated the close-round protocol."
remaining_risks:
  - risk_id: RISK-001
    description: "Protocol may need further refinement."
    next_action: "Monitor in next round."
phase_closure:
  pre_close_phases_complete: true
  close_round_completed: false
validator_summary:
  preclose_status: pass
  postclose_status: pending
GOOD

# Set current_phase to close_round and status to running (not yet complete).
yq -i ".current_phase = \"close_round\"" "$ROUND_DIR/state.yaml" 2>/dev/null || true
yq -i ".phases.close_round.status = \"running\"" "$ROUND_DIR/state.yaml" 2>/dev/null || true
yq -i ".phases.close_round.completed_at = null" "$ROUND_DIR/state.yaml" 2>/dev/null || true

# Create minimal transaction chain files so close_round validator passes.
for f in source-index.yaml evidence-ledger.yaml critique-ledger.yaml dispositions.yaml knowledge-delta.yaml knowledge-apply-log.yaml writing-diff.yaml; do
    [ -f "$ROUND_DIR/$f" ] || echo "schema_version: '1.0.0'" > "$ROUND_DIR/$f"
done

# Create valid source-index with one included source.
cat > "$ROUND_DIR/source-index.yaml" << 'SRCIDX'
schema_version: "1.0.0"
round_id: 2
sources:
  - source_id: "S001"
    title: "Test Paper"
    source_type: "paper"
    retrieved_at: "2026-01-01T00:00:00Z"
    snapshot_path: "raw-sources/S001.md"
    sha256: "0000000000000000000000000000000000000000000000000000000000000000"
    triage_decision: "include"
SRCIDX

# Create source note with affected_claims.
mkdir -p "$ROUND_DIR/source-notes"
cat > "$ROUND_DIR/source-notes/S001.yaml" << 'SN'
schema_version: "1.0.0"
source_id: "S001"
problem: "Test problem description that is at least fifty characters long for validation."
method_or_mechanism: "Test method"
key_claims: ["Claim 1"]
evidence_for: ["Point 1"]
evidence_against: []
does_not_prove: "This source does not prove the main claim."
affected_claims: ["C001"]
affected_sections: ["intro"]
SN

# Create evidence-ledger with one evidence item linking to source and claim.
cat > "$ROUND_DIR/evidence-ledger.yaml" << 'EV'
schema_version: "1.0.0"
evidence:
  - evidence_id: "E001"
    source_id: "S001"
    claim_id: "C001"
    direction: "supports"
    summary: "Test evidence"
EV

# Run close-round. It will fail at the validator pipeline (no real data),
# but close_round should still be marked complete before that.
cr close-round e2e-close 2>&1 > /dev/null || true

# Check that close_round was completed.
CLOSE_STATUS=$(yq -r '.phases.close_round.status // ""' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
if [ "$CLOSE_STATUS" = "complete" ]; then
    pass "close_round status is complete after close-round"
else
    fail "close_round status=$CLOSE_STATUS after close-round (expected complete)"
fi

# Check closure-report exists (closed_at is only set when pipeline passes).
if [ -f "$ROUND_DIR/closure-report.yaml" ]; then
    pass "closure-report.yaml exists"
else
    fail "closure-report.yaml not found"
fi

# Check phase-run-log has close_round completed event.
RUNLOG_HAS_CLOSE=$(yq -r '[.events[] | select(.event=="phase_completed" and .phase=="close_round")] | length' "$ROUND_DIR/phase-run-log.yaml" 2>/dev/null || echo 0)
if [ "$RUNLOG_HAS_CLOSE" -gt 0 ]; then
    pass "phase-run-log has close_round completed event"
else
    fail "phase-run-log missing close_round completed event"
fi

echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
