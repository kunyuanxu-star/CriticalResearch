#!/usr/bin/env bash
# Happy-path test: create a paper round, fill minimal valid artifacts,
# complete all 13 pre-close phases, and close the round.
set -euo pipefail

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

export CR_WORKSPACE_ROOT="$TMP"
SCRIPTS="$(cd "$(dirname "$0")/../scripts" && pwd)"
export PATH="$SCRIPTS:$PATH"

fail() { echo "FAIL: $1"; exit 1; }

echo "=== Happy Path Test ==="
echo "Workspace: $TMP"

# 1. Init workspace and project
cr workspace init
cr start toy-paper --profile systems
PROJ="$TMP/toy-paper"

# 2. Open a paper-mode round
cr round toy-paper --mode paper

ACTIVE=$(jq -r '.active_round' "$PROJ/state/project-state.json")
echo "Active round: $ACTIVE"
[ "$ACTIVE" -eq 2 ] || fail "Expected round 2, got $ACTIVE"  # round 1 is setup

RND=$(printf "%03d" "$ACTIVE")
ROUND="$PROJ/rounds/round-$RND"
[ -d "$ROUND" ] || fail "Round dir not created"
echo "Round dir: $ROUND"

# 3. Verify all L1 YAML templates exist
for f in loaded-knowledge.yaml paper-state.yaml round-target.yaml research-plan.yaml \
         search-log.yaml source-index.yaml evidence-ledger.yaml critique-ledger.yaml \
         literature-delta.yaml writing-diff.yaml knowledge-delta.yaml \
         knowledge-apply-log.yaml closure-report.yaml experiment-obligations.yaml; do
    [ -f "$ROUND/$f" ] || fail "Missing $f"
done
echo "All L1 YAML templates present"

# 4. Fill minimal valid artifacts for each phase

# Phase 1: reconstruct_paper_state
cat > "$ROUND/paper-state.yaml" << YAML
schema_version: "1.0.0"
round_id: $ACTIVE
paper_snapshot:
  draft_path: writing/paper-draft.md
core_claims: []
main_risks: []
round_recommendation:
  priority: test
  reason: "Happy path test"
YAML

cat > "$ROUND/loaded-knowledge.yaml" << YAML
schema_version: "1.0.0"
round_id: $ACTIVE
loaded_cards: []
YAML

# Phase 2: define_round_target
cat > "$ROUND/round-target.yaml" << YAML
schema_version: "1.0.0"
round_id: $ACTIVE
target_gap: "Test round target"
YAML

# Phase 3: plan_research
cat > "$ROUND/search-queue.yaml" << YAML
queries:
  - query_id: Q001
    query_class: core_problem
    query: "test query"
  - query_id: Q002
    query_class: strongest_baseline
    query: "test query"
  - query_id: Q003
    query_class: recent_top_conference
    query: "test query"
  - query_id: Q004
    query_class: production_or_real_world_case
    query: "test query"
  - query_id: Q005
    query_class: counterexample_or_failure
    query: "test query"
YAML

# Phase 4: run_retrieval
cat > "$ROUND/search-log.yaml" << YAML
schema_version: "1.0.0"
round_id: $ACTIVE
searches:
  - query_id: Q001
    query_class: core_problem
    query: "test"
    adapter: web
    executed_at: "2026-01-01T00:00:00Z"
    returned_count: 10
    selected_sources: [S001]
  - query_id: Q002
    query_class: strongest_baseline
    query: "test"
    adapter: web
    executed_at: "2026-01-01T00:00:00Z"
    returned_count: 10
    selected_sources: [S002]
  - query_id: Q003
    query_class: recent_top_conference
    query: "test"
    adapter: web
    executed_at: "2026-01-01T00:00:00Z"
    returned_count: 10
    selected_sources: [S003]
  - query_id: Q004
    query_class: production_or_real_world_case
    query: "test"
    adapter: web
    executed_at: "2026-01-01T00:00:00Z"
    returned_count: 10
    selected_sources: [S004]
  - query_id: Q005
    query_class: counterexample_or_failure
    query: "test"
    adapter: web
    executed_at: "2026-01-01T00:00:00Z"
    returned_count: 10
    selected_sources: [S005]
YAML

# Create raw source snapshots
for sid in S001 S002 S003 S004 S005; do
    cat > "$ROUND/raw-sources/${sid}.md" << MD
# Source $sid
Test source content.
MD
done

# Phase 5: ingest_sources
for sid in S001 S002 S003 S004 S005; do
    SHA=$(shasum -a 256 "$ROUND/raw-sources/${sid}.md" | awk '{print $1}')
done

cat > "$ROUND/source-index.yaml" << YAML
schema_version: "1.0.0"
round_id: $ACTIVE
sources:
  - source_id: S001
    title: "Test Source 1"
    source_type: paper
    retrieved_at: "2026-01-01T00:00:00Z"
    snapshot_path: raw-sources/S001.md
    sha256: "$(shasum -a 256 "$ROUND/raw-sources/S001.md" | awk '{print $1}')"
  - source_id: S002
    title: "Test Source 2"
    source_type: paper
    retrieved_at: "2026-01-01T00:00:00Z"
    snapshot_path: raw-sources/S002.md
    sha256: "$(shasum -a 256 "$ROUND/raw-sources/S002.md" | awk '{print $1}')"
  - source_id: S003
    title: "Test Source 3"
    source_type: paper
    retrieved_at: "2026-01-01T00:00:00Z"
    snapshot_path: raw-sources/S003.md
    sha256: "$(shasum -a 256 "$ROUND/raw-sources/S003.md" | awk '{print $1}')"
  - source_id: S004
    title: "Test Source 4"
    source_type: paper
    retrieved_at: "2026-01-01T00:00:00Z"
    snapshot_path: raw-sources/S004.md
    sha256: "$(shasum -a 256 "$ROUND/raw-sources/S004.md" | awk '{print $1}')"
  - source_id: S005
    title: "Test Source 5"
    source_type: paper
    retrieved_at: "2026-01-01T00:00:00Z"
    snapshot_path: raw-sources/S005.md
    sha256: "$(shasum -a 256 "$ROUND/raw-sources/S005.md" | awk '{print $1}')"
YAML

# Phase 6: normalize_evidence
cat > "$ROUND/evidence-ledger.yaml" << YAML
schema_version: "1.0.0"
round_id: $ACTIVE
evidence:
  - evidence_id: E001
    source_id: S001
    source_type: paper
    evidence_level: S
    related_claims: [CLM-001]
    relation: supports
    direct_support: "Test evidence supports the claim."
    does_not_support: "Does not cover edge cases."
    applicable_scenario: "Test scenario"
    allowed_wording: "Evidence suggests the claim holds."
    forbidden_wording: "The claim is proven."
  - evidence_id: E002
    source_id: S002
    source_type: paper
    evidence_level: A
    related_claims: [CLM-001]
    relation: weakens
    direct_support: "Test evidence partially weakens."
    does_not_support: "Does not fully contradict."
    applicable_scenario: "Test scenario"
    allowed_wording: "Evidence suggests limitations."
    forbidden_wording: "The claim is invalid."
  - evidence_id: E003
    source_id: S003
    source_type: paper
    evidence_level: A
    related_claims: [CLM-001]
    relation: supports
    direct_support: "Additional supporting evidence."
    does_not_support: "Limited to one domain."
    applicable_scenario: "Test scenario"
    allowed_wording: "Additional support found."
    forbidden_wording: "Universally applicable."
  - evidence_id: E004
    source_id: S004
    source_type: paper
    evidence_level: B
    related_claims: [CLM-001]
    relation: contextualizes
    direct_support: "Provides context for the claim."
    does_not_support: "Not direct evidence."
    applicable_scenario: "Broader context"
    allowed_wording: "Contextual evidence places the claim."
    forbidden_wording: "Direct proof."
  - evidence_id: E005
    source_id: S005
    source_type: paper
    evidence_level: B
    related_claims: [CLM-001]
    relation: weakens
    direct_support: "Further weakening evidence."
    does_not_support: "Specific to one setting."
    applicable_scenario: "Specific setting"
    allowed_wording: "Further limitations identified."
    forbidden_wording: "Claim is false."
YAML

# Phase 7: update_literature_knowledge
cat > "$ROUND/literature-delta.yaml" << YAML
schema_version: "1.0.0"
round_id: $ACTIVE
updates: []
YAML

# Phase 8: adversarial_critique
cat > "$ROUND/critique-ledger.yaml" << YAML
schema_version: "1.0.0"
round_id: $ACTIVE
critiques:
  - critique_id: CRT-001
    severity: medium
    target_type: claim
    target_id: CLM-001
    attack_type: overclaim
    attack_statement: "The claim may be too broad given the limited evidence scope."
    why_damaging: "Reviewers may reject the claim as unsubstantiated."
    evidence_refs: [E002, E005]
    required_action:
      action_type: narrow_claim
      must_create_patch: true
YAML

# Phase 9: generate_dispositions
cat > "$ROUND/dispositions.yaml" << YAML
schema_version: "1.0.0"
round_id: $ACTIVE
dispositions:
  - critique_id: CRT-001
    disposition_type: paper_patch
    linked_patch_id: PP-001
    justification: "The critique is valid and requires claim narrowing."
    status: resolved
YAML

# Phase 10: generate_paper_patches
cat > "$ROUND/patches/PP-001.yaml" << YAML
schema_version: "1.0.0"
patch_id: PP-001
created_from:
  critique_id: CRT-001
  disposition_id: DSP-001
linked_round: $ACTIVE
severity: medium
patch_type: [narrow_claim]
affected_anchors: [INTRO-P1]
proposed_change:
  before: "The system provides complete isolation."
  after: "The system provides isolation under the tested conditions."
  rationale: "Narrow claim to match evidence scope."
lifecycle_status: recorded
knowledge_implication:
  literature_updates: []
  thinking_candidates: []
YAML

# Phase 11: generate_experiment_obligations (no-op)
PATCH_COUNT=$(find "$ROUND/patches" -name 'PP-*.yaml' -type f | wc -l | tr -d ' ')
cat > "$ROUND/experiment-obligations.yaml" << YAML
schema_version: "1.0.0"
round_id: $ACTIVE
phase: generate_experiment_obligations
obligations: []
no_obligation_reason: "Happy-path test round with no empirical claims."
validated_patches:
$(
  for f in "$ROUND/patches"/PP-*.yaml; do
    [ -f "$f" ] && echo "  - $(basename "$f" .yaml)"
  done
)
YAML

# Update paper-draft.md with anchor and after_text for patch application.
cat > "$PROJ/writing/paper-draft.md" << 'MD'
# Title

<!-- CR-ANCHOR: INTRO-P1 -->
The system provides isolation under the tested conditions.

<!-- anchor: related_work -->
## Related Work
MD

# Phase 12: apply_patches_to_draft
cat > "$ROUND/writing-diff.yaml" << YAML
schema_version: "1.0.0"
round_id: $ACTIVE
draft_before_sha256: "0000000000000000000000000000000000000000000000000000000000000000"
draft_after_sha256: "0000000000000000000000000000000000000000000000000000000000000001"
changes:
  - change_id: WD-001
    patch_id: PP-001
    anchor_id: INTRO-P1
    change_type: narrow
YAML

# Phase 13: distill_knowledge
cat > "$ROUND/knowledge-delta.yaml" << YAML
schema_version: "1.0.0"
round_id: $ACTIVE
updates: []
no_update_justification: "Happy-path test round, no reusable knowledge generated."
YAML

cat > "$ROUND/knowledge-apply-log.yaml" << YAML
schema_version: "1.0.0"
round_id: $ACTIVE
applied_updates: []
index_updates: []
YAML

echo "All minimal artifacts created."

# 5. Complete all pre-close phases
for phase in reconstruct_paper_state define_round_target plan_research \
             run_retrieval ingest_sources normalize_evidence \
             update_literature_knowledge adversarial_critique \
             generate_dispositions generate_paper_patches \
             generate_experiment_obligations apply_patches_to_draft \
             distill_knowledge; do
    echo "Completing phase: $phase"
    cr complete-phase toy-paper "$phase" || fail "Failed to complete phase: $phase"
done

# 6. Verify all 13 pre-close phases are complete
COMPLETED=$(yq -r '[.phases | to_entries[] | select(.value.status == "complete")] | length' "$ROUND/state.yaml")
echo "Completed phases: $COMPLETED"
[ "$COMPLETED" -ge 13 ] || fail "Expected >=13 complete phases, got $COMPLETED"

# 7. Close the round
echo "Closing round..."
cr close-round toy-paper || fail "Close-round failed"

# 8. Verify round is closed
ROUND_STATUS=$(grep '^status:' "$ROUND/round.yaml" | sed 's/^status:\s*//' | xargs)
[ "$ROUND_STATUS" = "complete" ] || fail "Round status is '$ROUND_STATUS', expected 'complete'"

# 9. Verify closure-report.yaml exists and has content
[ -f "$ROUND/closure-report.yaml" ] || fail "closure-report.yaml not generated"
grep -q 'close_round_completed' "$ROUND/closure-report.yaml" || fail "closure-report.yaml missing close_round_completed"

echo ""
echo "═══ Happy Path Test PASSED ═══"
