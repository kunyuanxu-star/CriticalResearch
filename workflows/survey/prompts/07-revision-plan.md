# Stage 7: Revision Plan

# Purpose

Plan concrete, traceable, and dependency-ordered survey document changes that address the critical review.

This stage is part of the **survey workflow**. Its goal is to convert critique into an executable patch plan. It must not merely list edits. It must decide how each critique should be handled, what document change is required, what evidence supports the change, what taxonomy or comparison dependency must be resolved first, and how later stages can verify that the critique has actually been repaired.

A revision plan is invalid if it accepts a critique without a patch, rejects a critique without evidence-backed rationale, or proposes a patch that does not directly address the reviewer objection.

## Inputs

* `critical-review.yaml` — numbered critique items, severity, reviewer objections, required repairs, and evidence basis.
* `review-disposition.yaml` — proposed dispositions from the critical review stage.
* `coverage-risk.yaml` — remaining coverage and missing-source risks.
* `taxonomy-update.yaml` — updated taxonomy, classification dimensions, category changes, and system classifications.
* `comparison-matrix.yaml` — system × dimension matrix.
* `gap-analysis-update.yaml` — filled, reframed, remaining, and new gaps.
* `taxonomy-rationale.md` — rationale for taxonomy design decisions.
* `taxonomy-risks.yaml` — unresolved taxonomy risks.
* `evidence-ledger.yaml` — evidence backing classifications, comparisons, and gaps.
* `dangerous-baselines.yaml` — dangerous baselines and their required handling.
* `contract.yaml` — target units, scope, mutable document, and allowed writes.
* Target survey document — current text and unit anchors.

## Allowed Writes

* `revision-plan.yaml`
* `patch-plan.yaml`
* `deferred-obligations.yaml`
* `no-patch-rationale.yaml`

No target survey document edits are allowed in this stage.
## Outputs

* `coverage-risk.yaml`
* `taxonomy-risks.yaml`

## Required Procedure

### Step 1: Normalize Critiques

Read every critique item from `critical-review.yaml`.

For each critique, extract:

* critique ID;
* critique type;
* severity;
* target system, dimension, matrix cell, gap, paragraph, or section;
* reviewer objection;
* evidence basis;
* required repair type;
* whether it blocks the survey patch;
* whether it requires human decision.

Do not merge critiques unless they have the same root cause and require the same patch.

### Step 2: Decide Disposition for Every Critique

Every critique must receive one disposition:

* `patch`: accepted and repaired in this round;
* `partial_patch`: partially repaired in this round, with explicit residual obligation;
* `deferred`: not repaired in this round, but recorded as a future obligation;
* `no_patch`: explicitly rejected with evidence-backed rationale;
* `human_decision_required`: cannot be resolved without user judgment.

Disposition rules:

* Fatal critiques cannot be deferred unless marked `human_decision_required`.
* High critiques should normally become patches unless outside the round scope.
* A critique that threatens taxonomy validity, dangerous baseline integration, or gap overclaim cannot be ignored.
* `no_patch` is valid only if the critique is factually wrong, out of scope, already handled, or contradicted by stronger evidence.
* `deferred` is valid only if the critique requires new source search, a different unit, or a future workflow round.

### Step 3: Map Accepted Critiques to Patch Intent

For every critique with disposition `patch` or `partial_patch`, define the patch intent.

Patch intent must answer:

* What reviewer objection is this patch meant to neutralize?
* What survey structure will change?
* What evidence justifies the change?
* What existing text, table, taxonomy, or gap statement is affected?
* What should be true after the patch is applied?
* What risk remains after the patch?

A patch that does not neutralize a reviewer objection is invalid.

### Step 4: Choose Patch Type

Assign one or more workflow-specific patch types:

* `taxonomy_revision`: revise categories, classification dimensions, boundary definitions, or taxonomy rationale.
* `comparison_matrix_update`: update system × dimension values, add missing dimensions, or clarify unknown/not-applicable cells.
* `gap_analysis_update`: fill, weaken, delete, reframe, or add gaps.
* `related_work_section_rewrite`: rewrite survey prose to explain systems, transitions, taxonomy, or positioning.
* `missing_source_addition`: add a missing system/source into the survey discussion or matrix.
* `dangerous_baseline_integration`: explicitly compare or reposition a dangerous baseline.
* `terminology_revision`: define, rename, weaken, or disambiguate terms.
* `scope_clarification`: narrow survey scope or explain exclusions.
* `evidence_replacement`: replace weak/inferred/secondary evidence with stronger evidence.
* `edge_case_handling`: add, classify, or explicitly scope a hybrid/taxonomy-breaking system.
* `transition_rewrite`: add or rewrite paragraph transitions to show why a system or dimension matters.

Patch types must match the critique's required repair type. Do not use a text rewrite to hide a taxonomy problem.

### Step 5: Determine Patch Granularity

Each patch must have a clear target granularity:

* taxonomy-level;
* category-level;
* dimension-level;
* matrix-level;
* gap-level;
* source-level;
* paragraph-level;
* transition-level;
* terminology-level.

Do not combine unrelated edits into one patch. A patch should have one primary purpose.

However, related edits may be grouped if they must be applied together to preserve consistency. For example, redefining a dimension may require updating the comparison matrix and related-work paragraph in the same patch group.

### Step 6: Build Patch Dependency Graph

Order patches by dependency.

Typical dependency order:

1. `missing_source_addition` or `evidence_replacement` when later taxonomy changes depend on new evidence.
2. `terminology_revision` when later categories depend on stable terms.
3. `taxonomy_revision`.
4. `comparison_matrix_update`.
5. `dangerous_baseline_integration`.
6. `gap_analysis_update`.
7. `related_work_section_rewrite`.
8. `transition_rewrite`.
9. `scope_clarification`.

For each patch, record:

* dependencies;
* patches that depend on it;
* reason for ordering.

A related-work rewrite must not precede the taxonomy or matrix change it depends on.

### Step 7: Define Source Trace

Every patch must trace to evidence.

Record:

* critique IDs addressed;
* evidence IDs used;
* source IDs used;
* matrix cells affected;
* taxonomy categories or dimensions affected;
* dangerous baseline IDs affected;
* gap IDs affected.

A patch without source trace is invalid unless it is a purely structural writing patch. Even structural writing patches must trace to a critique item.

### Step 8: Define Expected Document Change

For each patch, specify concrete expected changes:

* target unit ID;
* target section or paragraph anchor;
* operation:

  * insert;
  * replace;
  * delete;
  * move;
  * split;
  * merge;
  * table update;
  * matrix update;
  * terminology definition;
* current problem;
* desired new content;
* expected diff scope;
* consistency checks required after patch.

Do not write final replacement prose in full unless needed to disambiguate the patch. This stage plans patches; the next stage applies them.

### Step 9: Check Patch Side Effects

For every patch, analyze whether it may introduce new risks:

* Does it weaken or invalidate another taxonomy category?
* Does it require reclassifying other systems?
* Does it make a comparison dimension inconsistent?
* Does it create a new gap overclaim?
* Does it make the project positioning weaker or stronger than evidence supports?
* Does it require additional source coverage?
* Does it introduce terminology inconsistency?
* Does it conflict with the round scope or target units?

If a patch has side effects, either add dependent patches or mark the issue as residual risk.

### Step 10: Handle Deferred Obligations

For every deferred critique or partial patch, write a deferred obligation.

Each obligation must include:

* critique ID;
* reason for deferral;
* why it cannot be repaired in this round;
* required future workflow;
* required target unit;
* required sources or evidence;
* expected repair type;
* risk if not repaired.

A deferred obligation must not be used to avoid hard critique. Fatal critiques should not be deferred unless the current round lacks scope or requires human decision.

Write this into `deferred-obligations.yaml`.

### Step 11: Handle No-Patch Decisions

For every `no_patch` disposition, write explicit rationale.

Valid reasons include:

* critique is contradicted by stronger evidence;
* critique targets material outside scope;
* critique is already addressed by existing text;
* critique is based on an incorrect taxonomy interpretation;
* critique requires a different workflow or future survey expansion.

Invalid reasons include:

* too hard;
* not enough time;
* weak preference;
* would make the paper look worse;
* not important without evidence.

Write this into `no-patch-rationale.yaml`.

### Step 12: Define Patch Validation Criteria

For every patch, define how Stage 8 should verify that the patch was applied successfully.

Validation criteria may include:

* critique no longer applies;
* taxonomy category definition updated;
* all affected systems reclassified consistently;
* comparison matrix cell updated with evidence;
* dangerous baseline explicitly integrated;
* gap weakened, deleted, or reframed;
* term defined before use;
* paragraph now explains why the system is discussed;
* transition now connects systems by dimension rather than chronology;
* evidence IDs appear in patch trace;
* document diff touches only target units.

## Output Contract

```yaml id="r5f1aq"
revision-plan.yaml:
  schema_version: "1.0.0"
  round_id: string
  project_id: string
  target_document: string

  plan_summary:
    total_critiques: integer
    accepted_patches: integer
    partial_patches: integer
    deferred: integer
    no_patch: integer
    human_decision_required: integer
    highest_remaining_risk: fatal | high | medium | low | none
    planning_judgment: ready_for_patch | blocked_by_human_decision | blocked_by_missing_evidence | blocked_by_scope

  critique_dispositions:
    - critique_id: string
      severity: fatal | high | medium | low
      disposition: patch | partial_patch | deferred | no_patch | human_decision_required
      rationale: string
      addressed_by_patches:
        - patch_id: string
      residual_risk: string | null

  patch_plan:
    - patch_id: string
      patch_type: taxonomy_revision | comparison_matrix_update | gap_analysis_update | related_work_section_rewrite | missing_source_addition | dangerous_baseline_integration | terminology_revision | scope_clarification | evidence_replacement | edge_case_handling | transition_rewrite
      patch_group: string | null
      priority: critical | high | medium | low
      target_units:
        - string
      target_locations:
        - section: string
          anchor: string | null
          paragraph_id: string | null
      critique_ids:
        - string
      reviewer_objection_addressed: string
      change_intent: string
      specific_change_description: string
      operation: insert | replace | delete | move | split | merge | table_update | matrix_update | terminology_definition
      source_trace:
        evidence_ids:
          - string
        source_ids:
          - string
        matrix_refs:
          - string
        taxonomy_refs:
          - string
        gap_ids:
          - string
        dangerous_baseline_ids:
          - string
      dependency_order:
        depends_on:
          - patch_id: string
        blocks:
          - patch_id: string
        ordering_rationale: string
      expected_diff_scope:
        estimated_lines_changed: integer | null
        estimated_paragraphs_changed: integer | null
        expected_tables_changed:
          - string
      side_effects:
        may_require_reclassification: boolean
        may_change_gap_status: boolean
        may_affect_project_positioning: boolean
        may_require_extra_evidence: boolean
        notes: string
      validation_criteria:
        - string
      residual_risks:
        - string

  patch_order:
    - patch_id: string

  blocking_issues:
    - issue_id: string
      issue_type: missing_evidence | human_decision | out_of_scope | unresolved_taxonomy | missing_source | conflicting_evidence
      description: string
      blocks_patches:
        - patch_id: string
      required_resolution: string
```

```yaml id="sq4ipe"
patch-plan.yaml:
  schema_version: "1.0.0"
  patches:
    - patch_id: string
      patch_type: string
      target_unit: string
      target_anchor: string | null
      operation: string
      change_summary: string
      critique_trace:
        - string
      evidence_trace:
        - string
      dependencies:
        - string
      validation:
        - string
```

```yaml id="f3dg51"
deferred-obligations.yaml:
  schema_version: "1.0.0"
  obligations:
    - obligation_id: string
      critique_id: string
      reason_for_deferral: string
      required_future_workflow: survey | design | paper | proposal | experiment
      required_target_unit: string | null
      required_sources_or_evidence:
        - string
      expected_repair_type: string
      risk_if_not_repaired: fatal | high | medium | low
```

```yaml id="xm3eut"
no-patch-rationale.yaml:
  schema_version: "1.0.0"
  decisions:
    - critique_id: string
      rationale: string
      evidence_or_scope_basis: string
      residual_risk: string
```

## Quality Gates

* Every critique in `critical-review.yaml` must have exactly one disposition.
* Every critique with disposition `patch` must map to at least one patch.
* Every critique with disposition `partial_patch` must map to at least one patch and one deferred obligation or residual risk.
* Every fatal critique must be patched, blocked by human decision, or explicitly marked impossible within scope.
* Every high critique must be patched or deferred with strong scope/evidence rationale.
* Every patch must address a concrete reviewer objection.
* Every patch must have source trace, critique trace, target unit, operation, and validation criteria.
* Every taxonomy revision must occur before dependent matrix, gap, or prose rewrites.
* Every dangerous baseline critique must map to a patch or deferred obligation.
* Every no-patch decision must include evidence-backed or scope-backed rationale.
* Patch ordering must be dependency-valid.
* No patch may modify units outside the contract scope.
* The plan must be executable by Stage 8 without requiring unstated judgment.

## Failure Conditions

Stop and report a blocker if:

* a fatal critique cannot be patched, deferred, or assigned to human decision;
* accepted critiques cannot be mapped to concrete target units;
* patch ordering is cyclic or inconsistent;
* source trace is missing for evidence-dependent patches;
* the target survey document lacks anchors needed to apply patches;
* resolving one critique would invalidate taxonomy decisions without a repair path;
* human judgment is required to decide taxonomy scope, baseline inclusion, or project positioning.

## Forbidden Behavior

* Do not accept a critique without a patch.
* Do not reject a critique without evidence-backed rationale.
* Do not defer hard critiques merely to avoid difficult revision.
* Do not use prose rewrite to hide unresolved taxonomy, evidence, or coverage problems.
* Do not plan patches outside the mutable document or target units.
* Do not strengthen survey claims unless evidence supports the stronger wording.
* Do not delete dangerous baselines from discussion because they weaken positioning.
* Do not produce generic patch descriptions such as “improve clarity” or “expand discussion.”
* Do not ignore patch side effects.
* Do not modify the target survey document in this stage.

## Advance Rule

After `revision-plan.yaml`, `patch-plan.yaml`, `deferred-obligations.yaml`, and `no-patch-rationale.yaml` are produced and all quality gates pass, run `cr stage advance`.
