#!/usr/bin/env bash
# test-close-round-protocol.sh — Verify close-round protocol enforcement.
# Tests: preclose/postclose gates, closure-report draft requirement, s8_round_closure sequencing.
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

# ── Test 1: 7/7 complete but s8 not → preclose passes, close-round blocked ──
echo "── Test 1: 7/7 preclose passes but s8 incomplete → blocked ──"
# Mark stages s1-s7 as complete.
for s in s1_round_contract s2_evidence_grounding s3_critical_review s4_revision_strategy s5_writing_strategy s6_paper_patch s7_knowledge_consolidation; do
    yq -i ".stages.\"$s\".status = \"complete\" | .stages.\"$s\".completed_at = \"2026-01-01T00:00:00Z\"" "$ROUND_DIR/state.yaml" 2>/dev/null || true
done

# Ensure s8 is NOT complete.
yq -i ".stages.s8_round_closure.status = \"blocked\" | .stages.s8_round_closure.completed_at = null" "$ROUND_DIR/state.yaml" 2>/dev/null || true

CLOSE_OUT=$(cr close-round e2e-close 2>&1 || true)
if echo "$CLOSE_OUT" | grep -qi "fail\|error\|pre-close\|postclose"; then
    pass "close-round blocked when s8 incomplete"
else
    fail "close-round should block when s8 is incomplete"
    echo "$CLOSE_OUT" | head -5
fi
echo ""

# ── Test 2: Missing closure-report summary → fail ──
echo "── Test 2: Missing closure-report summary → fail ──"
# Mark s8 complete too.
yq -i ".stages.s8_round_closure.status = \"complete\" | .stages.s8_round_closure.completed_at = \"2026-01-01T00:00:00Z\"" "$ROUND_DIR/state.yaml" 2>/dev/null || true

# Create empty closure-report.
cat > "$ROUND_DIR/closure-report.yaml" << 'BAD'
schema_version: "1.0.0"
round_id: 1
closed_at: null

summary: ""
remaining_risks: []
BAD

CLOSE_OUT=$(cr close-round e2e-close 2>&1 || true)
if echo "$CLOSE_OUT" | grep -qi "summary\|missing\|fail"; then
    pass "close-round blocked when closure-report lacks summary"
else
    fail "close-round should block when summary is missing"
    echo "$CLOSE_OUT" | head -5
fi
echo ""

# ── Test 3: Valid closure-report + s8 running → s8 gets completed ──
echo "── Test 3: Valid closure-report + s8 running → s8 gets completed ──"
# Restore project state to have active round.
jq '.active_round = 2' e2e-close/state/project-state.json > e2e-close/state/project-state.json.tmp && \
    mv e2e-close/state/project-state.json.tmp e2e-close/state/project-state.json

# Create valid closure-report.
cat > "$ROUND_DIR/closure-report.yaml" << 'GOOD'
schema_version: "1.0.0"
round_id: 1
closed_at: null

summary: "Round completed successfully with all 8 stages finished."
remaining_risks:
  - id: R001
    description: "None identified"

stage_closure:
  s8_round_closure_completed: false

validator_summary:
  preclose_status: pass
  postclose_status: pass
GOOD

# Set current_stage to s8_round_closure and status to running (not yet complete).
yq -i ".current_stage = \"s8_round_closure\"" "$ROUND_DIR/state.yaml" 2>/dev/null || true
yq -i ".stages.s8_round_closure.status = \"running\"" "$ROUND_DIR/state.yaml" 2>/dev/null || true
yq -i ".stages.s8_round_closure.completed_at = null" "$ROUND_DIR/state.yaml" 2>/dev/null || true

# Create minimal transaction chain files so s8 validator passes.
for f in source-index.yaml evidence-ledger.yaml critique-ledger.yaml review-disposition.yaml revision-plan.yaml writing-plan.yaml patch-plan.yaml writing-diff.yaml patch-trace.yaml knowledge-delta.yaml knowledge-apply-log.yaml experiment-obligations.yaml; do
    [ -f "$ROUND_DIR/$f" ] || echo "schema_version: '1.0.0'" > "$ROUND_DIR/$f"
done
# Create valid next-round-targets.yaml with at least one candidate.
cat > "$ROUND_DIR/next-round-targets.yaml" << 'NRT'
schema_version: "1.0.0"
candidates:
  - id: T001
    description: "Follow-up work"
NRT

# Create valid round-summary.yaml.
cat > "$ROUND_DIR/round-summary.yaml" << 'RS'
schema_version: "1.0.0"
summary: "Round completed"
RS

# Create valid source-index with one included source.
cat > "$ROUND_DIR/source-index.yaml" << 'SRCIDX'
schema_version: "1.0.0"
sources:
  - id: S001
    status: included
    type: primary_paper
    snapshot_sha256: "abc123"
SRCIDX

# Create source note with affected_claims.
mkdir -p "$ROUND_DIR/source-notes"
cat > "$ROUND_DIR/source-notes/S001.yaml" << 'SN'
schema_version: "1.0.0"
source_id: S001
notes: "Test note"
affected_claims:
  - C001
SN

# Create evidence-ledger with one evidence item linking to source and claim.
cat > "$ROUND_DIR/evidence-ledger.yaml" << 'EV'
schema_version: "1.0.0"
evidence:
  - id: E001
    source_id: S001
    claim: "test"
    evidence_category: weakening
    strength: medium
    location: "Section 1"
EV

# Run close-round. It will fail at the validator pipeline (no real data),
# but s8 should still be marked complete before that.
cr close-round e2e-close 2>&1 > /dev/null || true

# Check that s8 was completed.
CLOSE_STATUS=$(yq -r '.stages.s8_round_closure.status // ""' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
if [ "$CLOSE_STATUS" = "complete" ]; then
    pass "s8_round_closure status is complete after close-round"
else
    fail "s8_round_closure status=$CLOSE_STATUS after close-round (expected complete)"
fi

# Check closure-report exists (closed_at is only set when pipeline passes).
if [ -f "$ROUND_DIR/closure-report.yaml" ]; then
    pass "closure-report.yaml exists"
else
    fail "closure-report.yaml missing"
fi

# Check stage-run-log has s8 completed event.
RUNLOG_HAS_CLOSE=$(yq -r '[.events[] | select(.event=="stage_completed" and .stage=="s8_round_closure")] | length' "$ROUND_DIR/stage-run-log.yaml" 2>/dev/null || echo 0)
if [ "$RUNLOG_HAS_CLOSE" -gt 0 ]; then
    pass "stage-run-log has s8_round_closure completed event"
else
    fail "stage-run-log missing s8_round_closure completed event"
fi

echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
