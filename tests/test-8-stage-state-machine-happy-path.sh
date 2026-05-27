#!/usr/bin/env bash
# test-8-stage-state-machine-happy-path.sh — Verify 8-stage state machine:
#   start -> running -> complete -> next stage open.
#   dependencies unblock correctly.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-state-XXXXXX)
cd "$TEST_DIR"

echo "══ 8-Stage State Machine Happy Path ══"
echo "Test dir: $TEST_DIR"
echo ""

cr workspace init > /dev/null 2>&1
cr start e2e-state > /dev/null 2>&1
jq '.active_round = null' e2e-state/state/project-state.json > e2e-state/state/project-state.json.tmp && \
    mv e2e-state/state/project-state.json.tmp e2e-state/state/project-state.json

mkdir -p e2e-state/writing e2e-state/state
echo "# test paper" > e2e-state/documents/paper.md
echo "schema_version: \"1.0.0\"" > e2e-state/state/claim-ledger.yaml

cr-start-paper-round e2e-state "test state machine" > /dev/null 2>&1
ROUND_DIR="e2e-state/rounds/round-002"
STATE_FILE="$ROUND_DIR/state.yaml"

# ── Test 1: Initial state ──
echo "── Test 1: Initial state ──"
CURRENT=$(yq -r '.current_stage' "$STATE_FILE" 2>/dev/null || echo "")
[ "$CURRENT" = "s1_round_contract" ] && pass "current_stage = s1_round_contract" || fail "current_stage = $CURRENT"

S1_STATUS=$(yq -r '.stages.s1_round_contract.status' "$STATE_FILE" 2>/dev/null || echo "")
[ "$S1_STATUS" = "open" ] && pass "s1 status = open" || fail "s1 status = $S1_STATUS"

S2_STATUS=$(yq -r '.stages.s2_evidence_grounding.status' "$STATE_FILE" 2>/dev/null || echo "")
[ "$S2_STATUS" = "blocked" ] && pass "s2 status = blocked" || fail "s2 status = $S2_STATUS"

# ── Test 2: Complete s1 → s2 unblocks ──
echo ""
echo "── Test 2: Complete s1 → s2 unblocks ──"
# Create a valid round-contract.yaml with required semantic fields.
cat > "$ROUND_DIR/round-contract.yaml" << 'RC'
schema_version: "1.0.0"
contract:
  target: "Verify 8-stage state machine transitions"
  success_criteria:
    - "All stages complete in order"
    - "Dependencies unblock correctly"
RC

cr-complete-stage "$TEST_DIR/e2e-state" "$ROUND_DIR" s1_round_contract > /dev/null 2>&1

S1_NEW=$(yq -r '.stages.s1_round_contract.status' "$STATE_FILE" 2>/dev/null || echo "")
[ "$S1_NEW" = "complete" ] && pass "s1 marked complete" || fail "s1 status = $S1_NEW"

S2_NEW=$(yq -r '.stages.s2_evidence_grounding.status' "$STATE_FILE" 2>/dev/null || echo "")
[ "$S2_NEW" = "open" ] && pass "s2 unblocked to open" || fail "s2 status = $S2_NEW"

CURRENT_NEW=$(yq -r '.current_stage' "$STATE_FILE" 2>/dev/null || echo "")
[ "$CURRENT_NEW" = "s2_evidence_grounding" ] && pass "current_stage advanced to s2" || fail "current_stage = $CURRENT_NEW"

# ── Test 3: Dependency chain ──
echo ""
echo "── Test 3: Dependency chain ──"
# Create valid s2 outputs.
cat > "$ROUND_DIR/evidence-ledger.yaml" << 'EV'
schema_version: "1.0.0"
evidence:
  - id: E001
    source_id: S001
    claim: "test evidence"
    evidence_category: weakening
    strength: medium
    location: "Section 1"
EV

cat > "$ROUND_DIR/claim-evidence-map.yaml" << 'CEM'
schema_version: "1.0.0"
maps:
  - claim_id: C001
    evidence_ids: [E001]
CEM

echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/search-log.yaml"
mkdir -p "$ROUND_DIR/raw-sources" && echo "source" > "$ROUND_DIR/raw-sources/S001.md"

cr-complete-stage "$TEST_DIR/e2e-state" "$ROUND_DIR" s2_evidence_grounding > /dev/null 2>&1

S3_STATUS=$(yq -r '.stages.s3_critical_review.status' "$STATE_FILE" 2>/dev/null || echo "")
[ "$S3_STATUS" = "open" ] && pass "s3 unblocked after s2 complete" || fail "s3 status = $S3_STATUS"

# ── Test 4: Cannot complete out-of-order ──
echo ""
echo "── Test 4: Cannot complete out-of-order ──"
SKIP_OUT=$(cr-complete-stage "$TEST_DIR/e2e-state" "$ROUND_DIR" s4_revision_strategy 2>&1 || true)
echo "$SKIP_OUT" | grep -qE "Cannot complete|current_stage" && pass "Skip blocked: s4" || fail "Skip NOT blocked for s4"

# ── Test 5: All 8 stages in order ──
echo ""
echo "── Test 5: Complete all 8 stages ──"
for s in s3_critical_review s4_revision_strategy s5_writing_strategy s6_paper_patch s7_knowledge_consolidation s8_round_closure; do
    # Create valid required outputs for each stage.
    case "$s" in
        s3_critical_review)
            cat > "$ROUND_DIR/critique-ledger.yaml" << 'CL'
schema_version: "1.0.0"
critiques:
  - id: CR001
    target: "claim C001"
    severity: medium
    description: "needs more evidence"
    evidence_refs: [E001]
CL
            cat > "$ROUND_DIR/review-disposition.yaml" << 'RD'
schema_version: "1.0.0"
dispositions:
  - critique_id: CR001
    action: revise
RD
            ;;
        s4_revision_strategy)
            cat > "$ROUND_DIR/revision-plan.yaml" << 'RP'
schema_version: "1.0.0"
revisions:
  - id: R001
    target: "Section 1"
    action: "add evidence"
RP
            ;;
        s5_writing_strategy)
            cat > "$ROUND_DIR/writing-plan.yaml" << 'WP'
schema_version: "1.0.0"
high_level:
  argument_order: ["Intro", "Body", "Conclusion"]
WP
            cat > "$ROUND_DIR/patch-plan.yaml" << 'PP'
schema_version: "1.0.0"
patches:
  - id: P001
    target: "Section 1"
PP
            ;;
        s6_paper_patch)
            cat > "$ROUND_DIR/writing-diff.yaml" << 'WD'
schema_version: "1.0.0"
changes:
  - id: CH001
    op: insert
    location: "Section 1"
    text: "new text"
WD
            cat > "$ROUND_DIR/patch-trace.yaml" << 'PT'
schema_version: "1.0.0"
traces:
  - patch_id: P001
    status: applied
PT
            cat > "$ROUND_DIR/experiment-obligations.yaml" << 'EO'
schema_version: "1.0.0"
obligations: []
EO
            ;;
        s7_knowledge_consolidation)
            cat > "$ROUND_DIR/knowledge-delta.yaml" << 'KD'
schema_version: "1.0.0"
updates:
  - id: U001
    target: "rule-001"
    action: update
KD
            cat > "$ROUND_DIR/knowledge-apply-log.yaml" << 'KAL'
schema_version: "1.0.0"
entries:
  - update_id: U001
    status: applied
KAL
            ;;
        s8_round_closure)
            cat > "$ROUND_DIR/next-round-targets.yaml" << 'NRT'
schema_version: "1.0.0"
candidates:
  - id: T001
    description: "follow-up work"
NRT
            cat > "$ROUND_DIR/round-summary.yaml" << 'RS'
schema_version: "1.0.0"
summary: "Round completed successfully"
RS
            ;;
    esac
    cr-complete-stage "$TEST_DIR/e2e-state" "$ROUND_DIR" "$s" > /dev/null 2>&1
    STATUS=$(yq -r ".stages.\"$s\".status" "$STATE_FILE" 2>/dev/null || echo "")
    [ "$STATUS" = "complete" ] && pass "$s complete" || fail "$s status = $STATUS"
done

TOTAL_COMPLETE=$(yq -r '[.stages[] | select(.status=="complete")] | length' "$STATE_FILE" 2>/dev/null || echo "0")
[ "$TOTAL_COMPLETE" -eq 8 ] && pass "All 8 stages complete" || fail "Only $TOTAL_COMPLETE stages complete"

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo ""
echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
