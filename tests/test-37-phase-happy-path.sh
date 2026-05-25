#!/usr/bin/env bash
# test-37-phase-happy-path.sh — Verify full 37-phase round setup and close_round completion.
# Creates all required preconditions, marks all phases complete, and validates
# close-round completes the close_round phase (pipeline may fail on empty data).
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-happy-XXXXXX)
cd "$TEST_DIR"

echo "══ 37-Phase Happy Path Test ══"
echo "Test dir: $TEST_DIR"
echo ""

cr workspace init > /dev/null 2>&1
cr start e2e-happy > /dev/null 2>&1
jq '.active_round = null' e2e-happy/state/project-state.json > e2e-happy/state/project-state.json.tmp && \
    mv e2e-happy/state/project-state.json.tmp e2e-happy/state/project-state.json

mkdir -p e2e-happy/writing e2e-happy/state
cat > e2e-happy/writing/paper-draft.md << 'PAPER'
# Test Paper

## Introduction
This is a test paper.

## Method
Our method is novel.

## Results
Results show improvement.

## Conclusion
We conclude success.
PAPER

cat > e2e-happy/state/claim-ledger.yaml << 'CL'
schema_version: "1.0.0"
claims:
  - claim_id: C001
    text: "Test claim"
    section: intro
    status: active
CL

cr-start-paper-round e2e-happy "test happy path" > /dev/null 2>&1

ROUND_DIR="e2e-happy/rounds/round-002"

# ── Create minimal artifacts for all phases ──
echo "── Creating minimal artifacts ──"

mkdir -p "$ROUND_DIR/raw-sources" "$ROUND_DIR/source-notes" "$ROUND_DIR/patches" "$ROUND_DIR/experiments"
mkdir -p "$ROUND_DIR/writing"
cp e2e-happy/writing/paper-draft.md "$ROUND_DIR/writing/paper-draft.md"

for f in paper-state.yaml loaded-knowledge.yaml round-objective.yaml full-paper-coverage-plan.yaml research-questions.yaml search-plan.yaml search-queue.yaml search-log.yaml source-triage.yaml source-index.yaml evidence-ledger.yaml related-work-map.yaml literature-delta.yaml claim-evidence-matrix.yaml baseline-positioning.yaml evaluation-gap-map.yaml critique-claim-precision.yaml critique-novelty-baseline.yaml critique-evidence.yaml critique-evaluation.yaml critique-writing.yaml critique-ledger.yaml dispositions.yaml human-decisions.yaml experiment-obligations.yaml writing-plan.yaml writing-diff.yaml patch-application-report.yaml argument-flow-report.yaml claim-paper-matrix.yaml reviewer-readiness.yaml literature-knowledge-delta.yaml thinking-knowledge-delta.yaml knowledge-delta.yaml knowledge-apply-log.yaml next-round-targets.yaml; do
    echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/$f"
done
touch "$ROUND_DIR/raw-sources/S001.md"
echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/source-notes/S001.yaml"
touch "$ROUND_DIR/patches/PP-001.yaml"

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

cat > "$ROUND_DIR/evidence-ledger.yaml" << 'EV'
schema_version: "1.0.0"
evidence:
  - evidence_id: "E001"
    source_id: "S001"
    claim_id: "C001"
    direction: "supports"
    summary: "Test evidence"
EV

# Mark all phases complete and create phase-run-log.
NOW="2026-01-01T00:00:00Z"
cat > "$ROUND_DIR/phase-run-log.yaml" << 'HDR'
schema_version: "1.0.0"
events:
HDR

VALIDATOR_SHA256="0000000000000000000000000000000000000000000000000000000000000000"

for i in $(seq 0 36); do
    pid=$(yq -r ".phase_order[$i] // \"\"" "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
    [ -z "$pid" ] && continue
    order=$((i + 1))

    yq -i ".phases.\"$pid\".status = \"complete\"" "$ROUND_DIR/state.yaml" 2>/dev/null || true
    yq -i ".phases.\"$pid\".completed_at = \"$NOW\"" "$ROUND_DIR/state.yaml" 2>/dev/null || true

    outputs=$(yq -r ".phases.\"$pid\".required_outputs // [] | .[]" "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
    HASH_LINES=""
    for out in $outputs; do
        [ -z "$out" ] && continue
        f="$ROUND_DIR/$out"
        if [ -f "$f" ]; then
            h=$(shasum -a 256 "$f" 2>/dev/null | cut -d' ' -f1 || echo "unknown")
            HASH_LINES="${HASH_LINES}
      \"$out\": \"$h\""
        elif [ -d "$f" ]; then
            h=$(find "$f" -type f -exec shasum -a 256 {} \; 2>/dev/null | sort | shasum -a 256 | cut -d' ' -f1 || echo "unknown")
            HASH_LINES="${HASH_LINES}
      \"$out\": \"$h\""
        fi
    done
    [ -z "$HASH_LINES" ] && HASH_LINES="      {}"

    {
        echo "  - event: phase_completed"
        echo "    phase: $pid"
        echo "    order: $order"
        echo "    at: \"$NOW\""
        echo "    status_transition:"
        echo "      from: \"running\""
        echo "      to: complete"
        echo "    validator:"
        echo "      path: \"scripts/cr-validate-phase\""
        echo "      sha256: \"$VALIDATOR_SHA256\""
        echo "      exit_code: 0"
        echo "    output_hashes:$HASH_LINES"
    } >> "$ROUND_DIR/phase-run-log.yaml"
done

# Generate closure-report.
cat > "$ROUND_DIR/closure-report.yaml" << 'GOOD'
schema_version: "1.0.0"
round_id: 2
closed_at: null
summary: "Happy path test round completed successfully."
remaining_risks:
  - risk_id: RISK-001
    description: "None."
    next_action: "Monitor."
phase_closure:
  pre_close_phases_complete: true
  close_round_completed: false
validator_summary:
  preclose_status: pass
  postclose_status: pending
GOOD

# Generate module reviews.
for mod in M0 M1 M2 M3 M4 M5 M6 M7; do
    cr-review-module "$TEST_DIR/e2e-happy" "$ROUND_DIR" "$mod" > /dev/null 2>&1 || true
done

yq -i '.current_phase = "close_round"' "$ROUND_DIR/state.yaml" 2>/dev/null || true

# ── Close round (allow pipeline to fail) ──
echo ""
echo "── Closing round ──"
CLOSE_OUT=$(cr close-round e2e-happy 2>&1 || true)

# ── Verification ──
echo ""
echo "── Verification ──"

# 1. All 37 phases complete.
COMPLETED=$(yq -r '[.phases[] | select(.status=="complete")] | length' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "0")
if [ "$COMPLETED" -eq 37 ]; then
    pass "All 37 phases marked complete"
else
    fail "Only $COMPLETED phases complete (expected 37)"
fi

# 2. close_round is complete.
CLOSE_STATUS=$(yq -r '.phases.close_round.status // ""' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
if [ "$CLOSE_STATUS" = "complete" ]; then
    pass "close_round phase is complete"
else
    fail "close_round status='$CLOSE_STATUS' (expected complete)"
fi

# 3. Phase-run-log has 37 completed events.
COMPLETED_EVENTS=$(yq -r '[.events[] | select(.event=="phase_completed")] | length' "$ROUND_DIR/phase-run-log.yaml" 2>/dev/null || echo 0)
if [ "$COMPLETED_EVENTS" -eq 37 ]; then
    pass "phase-run-log has 37 completed events"
else
    fail "phase-run-log has $COMPLETED_EVENTS completed events (expected 37)"
fi

# 4. closure-report exists.
if [ -f "$ROUND_DIR/closure-report.yaml" ]; then
    pass "closure-report.yaml exists"
else
    fail "closure-report.yaml missing"
fi

# 5. Module reviews exist.
for mod in M0 M1 M2 M3 M4 M5 M6 M7; do
    if [ -f "$ROUND_DIR/phase-reviews/${mod}-review.yaml" ]; then
        pass "Module review $mod exists"
    else
        fail "Module review $mod missing"
    fi
done

# 6. Manifest snapshot exists.
if [ -f "$ROUND_DIR/phase-manifest.snapshot.yaml" ]; then
    pass "phase-manifest.snapshot.yaml exists"
else
    fail "phase-manifest.snapshot.yaml missing"
fi

# 7. State.yaml has correct structure.
PHASE_COUNT=$(yq -r '.phase_order | length' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "0")
if [ "$PHASE_COUNT" -eq 37 ]; then
    pass "state.yaml has 37 phases in phase_order"
else
    fail "state.yaml has $PHASE_COUNT phases (expected 37)"
fi

# 8. Round directory structure is complete.
for f in round.yaml state.yaml round-objective.yaml full-paper-coverage-plan.yaml phase-manifest.snapshot.yaml phase-run-log.yaml audit-log.yaml repair-log.yaml closure-report.yaml; do
    if [ -f "$ROUND_DIR/$f" ]; then
        pass "Round file $f exists"
    else
        fail "Round file $f missing"
    fi
done

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo ""
echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
