# Stage 7: Revision Plan

## Purpose

Convert critiques, results analysis, and methodology review into a concrete, ordered, evidence-constrained revision plan for the experiment design.

This stage is part of the **experiment workflow**. Its role is not to edit the experiment plan. Its role is to compile critique findings and results analysis into an executable patch plan that Stage 8 can apply without free-form judgment.

Every patch must answer a specific question:

> Which critique, result gap, or methodology weakness does this patch address, and what must change in the experiment design for that issue to be resolved?

A revision plan is invalid if it only says "fix methodology," "add control," "run more subjects," or "improve analysis" without specifying the affected hypothesis, variable, measure, component, and expected effect.

## Stage Type

planning-only

## Required Inputs

- `critique-ledger.yaml` — structured critique entries with severity, target, and required actions.
- `review-disposition.yaml` — per-critique dispositions and required action types.
- `results-analysis.yaml` — hypothesis results, critique postmortem, and result gaps.
- `experiment-findings.yaml` — evidence-grade findings with confidence.
- `methodology-design.yaml` — complete methodology specification.
- `experiment-execution-plan.yaml` — step-by-step execution plan.
- `contract.yaml` — target document, target units, round objective, and scope.
- Target experiment plan document — current text and unit anchors.
- `workflows/experiment/workflow.yaml` — valid patch types and patch schema.
- `workflows/_shared/stage-protocol.md` — stage execution discipline.
- `workflows/_shared/patch-discipline.md` — patch traceability and dependency rules.
- `workflows/_shared/evidence-discipline.md` — evidence adequacy rules.

## Allowed Writes

- `revision-plan.yaml`
- `patch-plan.yaml`
- `deferred-obligations.yaml`
- `no-patch-rationale.yaml`

No target experiment plan edits are allowed in this stage.

## Required Procedure

### Step 1: Load Critiques, Results, and Methodology Context

Read all critique items, review dispositions, results analyses, and methodology records.

For each critique, identify:
- critique ID;
- severity;
- target type (design, methodology, variable_control, measurement, writing);
- required action type (redesign, add_control, change_measure, add_analysis, reframe, delete, defer);
- whether the critique blocks experiment patching.

For each result, identify:
- hypothesis outcome;
- evidence strength;
- gaps that require follow-up;
- new concerns raised by results.

### Step 2: Disposition Every Critique

Every critique from `critique-ledger.yaml` must receive one disposition:

- `accepted`: valid and repaired in this round.
- `partially_accepted`: valid but only partially repaired.
- `rejected`: invalid, out of scope, or contradicted by stronger evidence.
- `deferred`: valid but requires data, new experiments, or a different round.
- `human_decision_required`: requires user judgment about design tradeoffs or scope.

Disposition rules:
- Fatal critiques must be repaired, blocked by human decision, or explicitly marked impossible within scope.
- High critiques should normally become patches unless they require missing results or new experiments.
- A critique about measurement validity cannot be rejected unless the measurement protocol is demonstrably adequate.
- A critique about confound control cannot be deferred without documenting the specific obstacle.

### Step 3: Map Accepted Critiques to Patch Intent

For every accepted or partially accepted critique, define the patch intent:
- What critique does this patch neutralize?
- What methodology component changes?
- What evidence justifies the change?
- What should be true after the patch?

### Step 4: Choose Valid Patch Types

Use only patch types declared in `workflows/experiment/workflow.yaml`:
- `hypothesis_update`
- `methodology_revision`
- `result_recording`
- `analysis_update`
- `obligation_fulfillment`

Patch type rules:
- Use `hypothesis_update` when the hypothesis must be refined, scoped, or reformulated.
- Use `methodology_revision` when design, variables, measures, or controls must change.
- Use `result_recording` when new or corrected results must be recorded.
- Use `analysis_update` when statistical methods, effect size measures, or analysis plans must change.
- Use `obligation_fulfillment` when a deferred obligation from a prior round must be discharged.

Do not use analysis_update to hide a methodology problem.

### Step 5: Determine Patch Granularity

Each patch should have one primary purpose. Granularity levels:
- hypothesis-level;
- design-level;
- variable-level;
- measure-level;
- control-level;
- analysis-level;
- result-level.

Do not combine unrelated repairs into a single patch.

### Step 6: Build Patch Dependency Graph

Order patches by dependency. Typical order:
1. `hypothesis_update` patches that change what is being tested.
2. `methodology_revision` patches that change design or controls.
3. `analysis_update` patches that change statistical methods.
4. `result_recording` patches that record new or corrected results.
5. `obligation_fulfillment` patches that close deferred obligations.

For each patch, record dependencies, patches that depend on it, and reason for ordering.

### Step 7: Record Traceability

Every patch must trace: `critique → disposition → patch → expected effect`

Record: critique IDs, disposition IDs, hypothesis IDs, result finding IDs, target components, patch type, dependencies.

### Step 8: Define Expected Effect and Validation Criteria

For every patch, state:
- what will change in the experiment design;
- how it addresses the critique;
- what should be true after application;
- how Stage 8 should verify successful application.

### Step 9: Handle Deferred Obligations

For every deferred or partially accepted critique, create an entry in `deferred-obligations.yaml`. Include: critique ID, reason for deferral, required future workflow, required data or experiments, risk if not addressed.

### Step 10: Handle Rejected Critiques

For every rejected critique, create an entry in `no-patch-rationale.yaml`. Cite evidence, document location, or scope rationale.

### Step 11: Produce Revision Plan and Patch Plan

Write `revision-plan.yaml` and `patch-plan.yaml`.

## Output Contract

```yaml
revision-plan.yaml:
  schema_version: "1.0.0"
  round_id: string
  project_id: string
  target_document: string

  plan_summary:
    total_critiques: integer
    accepted: integer
    partially_accepted: integer
    rejected: integer
    deferred: integer
    human_decision_required: integer
    total_patches: integer
    highest_unresolved_risk: fatal | high | medium | low | none
    planning_status: ready_for_patch | blocked_by_human_decision | blocked_by_missing_results | blocked_by_scope

  dispositions:
    - disposition_id: string
      critique_id: string
      severity: fatal | high | medium | low
      disposition: accepted | partially_accepted | rejected | deferred | human_decision_required
      rationale: string
      patch_ids:
        - string
      residual_risk: string | null

  patch_order:
    - patch_id: string

  patches:
    - patch_id: string
      patch_type: hypothesis_update | methodology_revision | result_recording | analysis_update | obligation_fulfillment
      priority: critical | high | medium | low
      target_components:
        - string
      description: string (>= 20 chars)
      expected_effect: string (>= 20 chars)
      source_critiques:
        - string
      dependencies:
        - string
      evidence_ids:
        - string
      validation_criteria: string (>= 20 chars)

patch-plan.yaml:
  schema_version: "1.0.0"
  round_id: string
  patches:
    - patch_id: string
      patch_type: string
      order: integer
      dependencies: [string]
      target_components: [string]
      operation: string
      preconditions: [string]
      postconditions: [string]

deferred-obligations.yaml:
  schema_version: "1.0.0"
  round_id: string
  obligations:
    - critique_id: string
      reason_deferred: string (>= 20 chars)
      required_workflow: string
      required_data: string
      risk_if_skipped: string

no-patch-rationale.yaml:
  schema_version: "1.0.0"
  round_id: string
  rejections:
    - critique_id: string
      reason: string (>= 20 chars)
      evidence_ref: string
      scope_rationale: string
```

## Failure Conditions
- Any fatal critique accepted without a patch.
- Any patch has description < 20 chars.
- Any patch has no source_critiques.
- Patch dependency graph has cycles.
- Deferred obligation missing reason or risk.

## Completion Checklist
- [ ] All critiques dispositioned.
- [ ] Every accepted critique maps to at least one patch.
- [ ] Patches ordered by dependency.
- [ ] Every patch has traceability and validation criteria.
- [ ] Deferred obligations and rejected critique rationale documented.
- [ ] revision-plan.yaml and patch-plan.yaml are valid YAML.

## Full-Experiment Coverage Requirement
Revision plan must cover all hypotheses, variables, measures, and controls affected by critiques and results gaps, not just the primary target.

## Handoff
The next stage (`apply_experiment_patch`) applies the revision plan to the experiment plan document.
