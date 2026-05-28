# Stage 8: Apply Survey Patch

# Purpose

Apply the ordered survey patch plan to the declared mutable survey document while preserving traceability, unit boundaries, evidence grounding, and critique-to-diff accountability.

This stage is part of the **survey workflow**. Its goal is not to freely edit the survey. Its goal is to execute the revision plan from Stage 7 exactly: each applied change must trace to a critique, disposition, patch plan item, evidence item, and document diff.

A patch is valid only if it modifies the declared mutable document, stays within declared unit anchors, preserves anchor comments, records before/after snippets, and verifies that the intended critique has been addressed.

## Inputs

* `revision-plan.yaml` — full critique dispositions, patch plan, dependency order, validation criteria, and residual risks.
* `patch-plan.yaml` — executable patch summary.
* `deferred-obligations.yaml` — critiques intentionally deferred.
* `no-patch-rationale.yaml` — critiques explicitly rejected.
* `critical-review.yaml` — original critique items and reviewer objections.
* `review-disposition.yaml` — disposition proposals.
* `taxonomy-update.yaml` — taxonomy changes that patches may implement.
* `comparison-matrix.yaml` — comparison matrix updates that patches may implement.
* `gap-analysis-update.yaml` — gap changes that patches may implement.
* `evidence-ledger.yaml` — source evidence for citations and evidence trace.
* `source-index.yaml` — source metadata for citation consistency.
* `dangerous-baselines.yaml` — dangerous baseline integration requirements.
* `contract.yaml` — mutable document, target units, scope, and allowed writes.
* `units/<target>.units.yaml` — unit boundaries and anchors.
* Target survey document — current text with unit anchors.

## Allowed Writes

* `patches/SP-NNN.yaml`
* target survey document declared in `contract.yaml`
* `patch-trace.yaml`
* `document-diff.yaml`
* `applied-patch-summary.md`
* `residual-risks.yaml`
* `next-round-targets.yaml`

No other project document may be modified.

## Required Procedure

### Step 1: Load Scope and Unit Boundaries

Read `contract.yaml` and identify:

* mutable document ID;
* mutable document path;
* target units;
* allowed write scope;
* read-only context documents;
* round ID;
* project ID.

Read `units/<target>.units.yaml` and locate the exact unit boundaries in the survey document.

Before applying any patch, verify:

* the target document path matches `contract.yaml`;
* every patch target unit is listed in the contract or explicitly allowed by the round;
* every target unit exists in the unit registry;
* every target unit anchor exists in the document;
* anchor comments must not be modified.

If any boundary is missing or ambiguous, stop and report a blocker.

### Step 2: Validate Patch Plan Before Editing

Read `revision-plan.yaml` and `patch-plan.yaml`.

For every planned patch, verify:

* patch ID is unique;
* patch type is valid for survey workflow;
* patch has critique trace;
* patch has evidence trace unless it is a purely structural rewrite;
* patch has target unit and target location;
* patch has an operation;
* patch has validation criteria;
* dependencies appear earlier in `patch_order`;
* no patch targets a read-only document;
* no patch targets units outside the contract scope.

Do not apply patches not present in `revision-plan.yaml` or `patch-plan.yaml`.

### Step 3: Generate Patch Files

For each patch in dependency order, generate `patches/SP-NNN.yaml`.

Each patch file must include:

```yaml id="hp2mrt"
schema_version: "1.0.0"
patch_id: SP-NNN
workflow: survey
project_id: string
round_id: string

target_document:
  id: string
  path: string

target_units:
  - string

source_trace:
  critiques:
    - string
  dispositions:
    - string
  revision_plan_items:
    - string
  evidence:
    - string
  sources:
    - string
  taxonomy_refs:
    - string
  matrix_refs:
    - string
  gap_ids:
    - string
  dangerous_baseline_ids:
    - string

patch_type: taxonomy_revision | comparison_matrix_update | gap_analysis_update | related_work_section_rewrite | missing_source_addition | dangerous_baseline_integration | terminology_revision | scope_clarification | evidence_replacement | edge_case_handling | transition_rewrite

status: pending

intended_repair:
  reviewer_objection: string
  critique_ids:
    - string
  repair_goal: string
  validation_criteria:
    - string

survey_payload:
  taxonomy_changes:
    - string
  comparison_dimensions:
    - string
  sources_added:
    - string
  gaps_updated:
    - string
  terminology_changes:
    - string
  text_changes:
    - unit: string
      operation: insert | replace | delete | move | split | merge | table_update | matrix_update | terminology_definition
      anchor_before: string | null
      anchor_after: string | null
      old_content: string | null
      new_content: string
      rationale: string

application_record:
  applied_at: null
  before_snippet: null
  after_snippet: null
  document_hash_before: null
  document_hash_after: null
  status: pending
```

Patch files must be created before document edits are applied.

### Step 4: Apply Patches in Dependency Order

For each patch:

1. Locate the target unit.
2. Locate the target anchor or text span.
3. Verify that the edit is inside the target unit.
4. Capture before snippet.
5. Apply the edit.
6. Capture after snippet.
7. Verify that anchor comments are unchanged.
8. Verify that no unrelated unit was modified.
9. Update the patch file status to `applied`.

Allowed operations:

* `insert`: add content before or after an anchor.
* `replace`: replace a specific text span.
* `delete`: remove a specific text span.
* `move`: relocate a paragraph or table within the same allowed scope.
* `split`: split an overloaded paragraph.
* `merge`: merge adjacent paragraphs.
* `table_update`: update an existing table.
* `matrix_update`: update or insert comparison-matrix content.
* `terminology_definition`: define or revise a technical term.

A patch must not perform broader rewriting than planned. If the planned patch is insufficient, stop and record a blocker or residual risk rather than improvising a larger edit.

### Step 5: Preserve Survey-Specific Consistency

After each patch, check whether the survey remains internally consistent.

Verify:

* taxonomy category names are consistent;
* classification dimensions use the same names as `taxonomy-update.yaml`;
* comparison matrix values match `comparison-matrix.yaml`;
* gap statements match `gap-analysis-update.yaml`;
* dangerous baselines are not removed or weakened without rationale;
* terminology is defined before use;
* citations correspond to evidence IDs and source IDs;
* source discussions are not reduced to unsupported summaries;
* new text explains why each source/system matters to the taxonomy;
* transitions are based on comparison dimensions, not loose chronology.

If a patch creates inconsistency, either apply its dependent patch immediately if already planned, or record residual risk.

### Step 6: Verify Critique Repair

For every patch, verify whether the associated critique has actually been addressed.

For each critique ID:

* identify original reviewer objection;
* identify document change applied;
* determine whether the objection is fully repaired, partially repaired, or unresolved;
* record remaining risk;
* determine whether additional patching is required.

Do not mark a patch successful merely because text changed. It must satisfy the validation criteria from `revision-plan.yaml`.

### Step 7: Record Document Diff

After all patches are applied, produce `document-diff.yaml`.

The diff must record:

* modified document;
* modified units;
* patch IDs applied;
* critique IDs addressed;
* before/after snippets;
* changed taxonomy categories;
* changed comparison dimensions;
* changed gap statements;
* sources added;
* citations added or modified;
* lines or paragraphs affected;
* whether each change stayed within target unit boundaries.

Output format:

```yaml id="xvu88z"
document-diff.yaml:
  schema_version: "1.0.0"
  round_id: string
  target_document:
    id: string
    path: string

  modified_units:
    - unit_id: string
      patches:
        - patch_id: string
      change_summary: string

  diffs:
    - diff_id: string
      patch_id: string
      unit_id: string
      operation: insert | replace | delete | move | split | merge | table_update | matrix_update | terminology_definition
      anchor_before: string | null
      anchor_after: string | null
      before_snippet: string
      after_snippet: string
      critique_ids:
        - string
      evidence_ids:
        - string
      source_ids:
        - string
      validation_result: passed | partial | failed
      residual_risk: string | null

  boundary_check:
    mutable_document_only: true
    target_units_only: true
    anchor_comments_preserved: true
    read_only_documents_untouched: true

  citation_check:
    all_evidence_ids_valid: true
    all_source_ids_valid: true
    unresolved_citations:
      - string

  consistency_check:
    taxonomy_consistent: true | false
    comparison_matrix_consistent: true | false
    gap_analysis_consistent: true | false
    terminology_consistent: true | false
    notes: string
```

### Step 8: Produce Patch Trace

Produce `patch-trace.yaml`.

The patch trace must connect:

* critique → disposition → revision plan → patch file → document diff → repair status.

Output format:

```yaml id="qaj070"
patch-trace.yaml:
  schema_version: "1.0.0"
  round_id: string

  trace:
    - critique_id: string
      disposition: patch | partial_patch | deferred | no_patch | human_decision_required
      patch_ids:
        - string
      evidence_ids:
        - string
      source_ids:
        - string
      diff_ids:
        - string
      repair_status: repaired | partially_repaired | unresolved | deferred | rejected
      validation_summary: string
      residual_risk: string | null
```

### Step 9: Record Residual Risks

Produce `residual-risks.yaml` for anything not fully resolved.

Residual risks include:

* critique partially repaired;
* patch applied but validation criteria not fully satisfied;
* taxonomy remains unstable;
* dangerous baseline still not fully integrated;
* evidence remains weak;
* matrix cell remains unknown;
* gap statement still overclaims;
* target unit lacks room to repair without broader rewrite;
* human decision required.

Output format:

```yaml id="y7tb46"
residual-risks.yaml:
  schema_version: "1.0.0"
  risks:
    - risk_id: string
      linked_critique_id: string
      linked_patch_id: string | null
      severity: fatal | high | medium | low
      description: string
      reason_unresolved: string
      required_next_action: string
```

### Step 10: Produce Next-Round Targets

If a patch reveals that another document, another unit, or another workflow must be updated, record it in `next-round-targets.yaml`.

Possible next-round targets:

* new source search;
* taxonomy expansion;
* design document update;
* paper introduction update;
* evaluation-plan update;
* related-work section expansion;
* terminology cleanup;
* dangerous baseline deep dive;
* human decision on scope or positioning.

Do not modify other documents in this stage.

### Step 11: Final Validation

Before advancing, validate:

* all planned patches are either applied, deferred, rejected, or blocked;
* all applied patches have patch files;
* all patch files have status `applied`;
* target survey document was modified only within declared unit anchors;
* `document-diff.yaml` exists;
* `patch-trace.yaml` exists;
* no read-only context document was modified;
* citation/evidence references are valid;
* every accepted critique has repair status;
* residual risks are explicitly recorded.

## Output

* `patches/SP-NNN.yaml` — one per applied patch, status updated to `applied`.
* Modified target survey document — only content within declared unit anchors updated.
* `document-diff.yaml` — complete before/after diff record.
* `patch-trace.yaml` — critique-to-patch-to-diff trace.
* `applied-patch-summary.md` — narrative summary of applied patches.
* `residual-risks.yaml` — unresolved or partially resolved issues.
* `next-round-targets.yaml` — cross-document or future-round implications.
* `deferred-obligations.yaml` — critiques intentionally deferred, updated status.
* `no-patch-rationale.yaml` — critiques explicitly rejected, updated status.

## Quality Gates

* Every applied patch must originate from `revision-plan.yaml`.
* Every applied patch must have a corresponding `patches/SP-NNN.yaml`.
* Every patch file must include critique trace, evidence trace, intended repair, and application record.
* Every document edit must occur inside declared unit boundaries.
* Anchor comments must not be modified.
* No read-only document may be modified.
* Every accepted critique must be repaired, partially repaired, or explicitly recorded as unresolved.
* Every evidence-dependent text change must cite valid evidence IDs.
* Every dangerous-baseline patch must preserve fair representation.
* Every taxonomy, matrix, or gap change must remain consistent with Stage 5 artifacts.
* `document-diff.yaml` must record before/after snippets for every patch.
* `patch-trace.yaml` must connect critique, disposition, patch, diff, and repair status.
* Residual risks must be recorded rather than hidden.

## Failure Conditions

Stop and report a blocker if:

* a target unit anchor cannot be found;
* a patch would modify content outside declared unit boundaries;
* a patch depends on an unapplied or missing patch;
* a patch lacks critique trace or source trace;
* evidence IDs referenced by a patch do not exist;
* applying the patch would require modifying another document;
* the document becomes inconsistent with taxonomy or comparison matrix;
* anchor comments would need to be modified;
* a fatal critique remains unresolved after planned patches;
* the patch plan is too vague to execute without free editing.

## Forbidden Behavior

* Do not freely rewrite the survey outside the patch plan.
* Do not apply patches not present in `revision-plan.yaml`.
* Do not modify anchor comments.
* Do not modify read-only context documents.
* Do not silently expand patch scope.
* Do not hide unresolved critique by rewriting around it.
* Do not strengthen claims beyond evidence.
* Do not delete dangerous baselines because they weaken positioning.
* Do not treat a patch as successful merely because text changed.
* Do not leave before/after snippets unrecorded.
* Do not advance if patch trace or document diff is missing.

## Advance Rule

After all patch files, document changes, `document-diff.yaml`, `patch-trace.yaml`, `applied-patch-summary.md`, `residual-risks.yaml`, and `next-round-targets.yaml` are produced and all quality gates pass, run `cr stage advance`.
