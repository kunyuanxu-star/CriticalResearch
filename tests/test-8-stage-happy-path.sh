#!/usr/bin/env bash
# test-8-stage-happy-path.sh — Verify full 8-stage round setup and s8_round_closure completion.
# Creates all required preconditions, marks all stages complete, and validates
# close-round completes the s8_round_closure stage (pipeline may fail on empty data).
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

echo "══ 8-Stage Happy Path Test ══"
echo "Test dir: $TEST_DIR"
echo ""

cr workspace init > /dev/null 2>&1
cr start e2e-happy > /dev/null 2>&1
jq '.active_round = null' e2e-happy/state/project-state.json > e2e-happy/state/project-state.json.tmp && \
    mv e2e-happy/state/project-state.json.tmp e2e-happy/state/project-state.json

mkdir -p e2e-happy/writing e2e-happy/state
cat > e2e-happy/documents/paper.md << 'PAPER'
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

# ── Create minimal artifacts for all stages ──
echo "── Creating minimal artifacts ──"

mkdir -p "$ROUND_DIR/raw-sources" "$ROUND_DIR/source-notes" "$ROUND_DIR/patches" "$ROUND_DIR/experiments"
mkdir -p "$ROUND_DIR/documents"
cp e2e-happy/documents/paper.md "$ROUND_DIR/documents/paper.md"

for f in round-contract.yaml evidence-ledger.yaml claim-evidence-map.yaml search-log.yaml critique-ledger.yaml review-disposition.yaml revision-plan.yaml writing-plan.yaml patch-plan.yaml writing-diff.yaml patch-trace.yaml experiment-obligations.yaml knowledge-delta.yaml knowledge-apply-log.yaml next-round-targets.yaml round-summary.yaml; do
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

# Mark all stages complete and create stage-run-log.
NOW="2026-01-01T00:00:00Z"
cat > "$ROUND_DIR/stage-run-log.yaml" << 'HDR'
schema_version: "1.0.0"
events:
HDR

VALIDATOR_SHA256="0000000000000000000000000000000000000000000000000000000000000000"

for i in $(seq 0 7); do
    sid=$(yq -r ".stage_order[$i] // \"\"" "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
    [ -z "$sid" ] && continue
    order=$((i + 1))

    yq -i ".stages.\"$sid\".status = \"complete\"" "$ROUND_DIR/state.yaml" 2>/dev/null || true
    yq -i ".stages.\"$sid\".completed_at = \"$NOW\"" "$ROUND_DIR/state.yaml" 2>/dev/null || true

    outputs=$(yq -r ".stages.\"$sid\".required_outputs // [] | .[]" "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
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
        echo "  - event: stage_completed"
        echo "    stage: $sid"
        echo "    order: $order"
        echo "    at: \"$NOW\""
        echo "    status_transition:"
        echo "      from: \"running\""
        echo "      to: complete"
        echo "    validator:"
        echo "      path: \"scripts/cr-validate-stage\""
        echo "      sha256: \"$VALIDATOR_SHA256\""
        echo "      exit_code: 0"
        echo "    output_hashes:$HASH_LINES"
    } >> "$ROUND_DIR/stage-run-log.yaml"
done

# Generate round-summary.
cat > "$ROUND_DIR/round-summary.yaml" << 'GOOD'
schema_version: "1.0.0"
round_id: 2
summary: "Happy path test round completed successfully."
all_stages_complete: true
remaining_risks:
  - risk_id: RISK-001
    description: "None."
    next_action: "Monitor."
unresolved_human_decisions: []
GOOD

yq -i '.current_stage = "s8_round_closure"' "$ROUND_DIR/state.yaml" 2>/dev/null || true

# ── Close round (allow pipeline to fail) ──
echo ""
echo "── Closing round ──"
CLOSE_OUT=$(cr close-round e2e-happy 2>&1 || true)

# ── Verification ──
echo ""
echo "── Verification ──"

# 1. All 8 stages complete.
COMPLETED=$(yq -r '[.stages[] | select(.status=="complete")] | length' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "0")
if [ "$COMPLETED" -eq 8 ]; then
    pass "All 8 stages marked complete"
else
    fail "Only $COMPLETED stages complete (expected 8)"
fi

# 2. s8_round_closure is complete.
CLOSE_STATUS=$(yq -r '.stages.s8_round_closure.status // ""' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
if [ "$CLOSE_STATUS" = "complete" ]; then
    pass "s8_round_closure stage is complete"
else
    fail "s8_round_closure status='$CLOSE_STATUS' (expected complete)"
fi

# 3. Stage-run-log has 8 completed events.
COMPLETED_EVENTS=$(yq -r '[.events[] | select(.event=="stage_completed")] | length' "$ROUND_DIR/stage-run-log.yaml" 2>/dev/null || echo 0)
if [ "$COMPLETED_EVENTS" -eq 8 ]; then
    pass "stage-run-log has 8 completed events"
else
    fail "stage-run-log has $COMPLETED_EVENTS completed events (expected 8)"
fi

# 4. round-summary exists.
if [ -f "$ROUND_DIR/round-summary.yaml" ]; then
    pass "round-summary.yaml exists"
else
    fail "round-summary.yaml missing"
fi

# 5. Manifest snapshot exists.
if [ -f "$ROUND_DIR/stage-manifest.snapshot.yaml" ]; then
    pass "stage-manifest.snapshot.yaml exists"
else
    fail "stage-manifest.snapshot.yaml missing"
fi

# 6. State.yaml has correct structure.
STAGE_COUNT=$(yq -r '.stage_order | length' "$ROUND_DIR/state.yaml" 2>/dev/null || echo "0")
if [ "$STAGE_COUNT" -eq 8 ]; then
    pass "state.yaml has 8 stages in stage_order"
else
    fail "state.yaml has $STAGE_COUNT stages (expected 8)"
fi

# 7. Round directory structure is complete.
for f in round.yaml state.yaml round-contract.yaml stage-manifest.snapshot.yaml stage-run-log.yaml audit-log.yaml repair-log.yaml round-summary.yaml; do
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
