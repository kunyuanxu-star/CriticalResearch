# Stage 6: Revision Plan

## Purpose

Convert critiques, feasibility research, and scope strategy into a concrete, ordered, evidence-constrained revision plan for the proposal document.

This stage is part of the **proposal workflow**. Its role is not to edit the proposal. Its role is to compile reviewer concerns, feasibility findings, and scope decisions into an executable patch plan that Stage 7 can apply without free-form judgment.

Every patch must answer a specific question:

> Which critique, scope decision, or feasibility concern does this patch address, and what must change in the proposal for that issue to be resolved?

A revision plan is invalid if it only says "improve motivation," "clarify goals," "reduce scope," or "strengthen approach" without specifying the affected section, goal, milestone, risk, and expected reviewer-visible effect.

## Stage Type

planning-only

## Required Inputs

- `critical-review.yaml` — problem reality, scope controllability, research question clarity, contribution quality, technical credibility, risk identification, milestone executability critiques.
- `feasibility-research.yaml` — technical feasibility, resource estimates, comparable efforts.
- `scope-strategy.yaml` — scope boundaries, explicit non-goals, deferred investigations.
- `contract.yaml` — target document, target units, round objective, and scope.
- `proposal-state.yaml` — frozen proposal baseline.
- Target proposal document — current text and unit anchors.
- `workflows/proposal/workflow.yaml` — valid patch types and patch schema.
- `workflows/_shared/stage-protocol.md` — stage execution discipline.
- `workflows/_shared/patch-discipline.md` — patch traceability and dependency rules.
- `workflows/_shared/evidence-discipline.md` — evidence adequacy rules.

## Allowed Writes

- `revision-plan.yaml`
- `patch-plan.yaml`
- `deferred-obligations.yaml`
- `no-patch-rationale.yaml`

No target proposal edits are allowed in this stage.

## Required Procedure

### Step 1: Load Critiques, Feasibility, and Scope Context

Read all critique items, feasibility findings, and scope decisions.

For each critique, identify:
- critique ID;
- severity;
- target area (problem, scope, research_question, contribution, technical_approach, risk, milestone);
- required repair;
- whether the critique blocks proposal patching.

For each feasibility finding, identify:
- technical risk level;
- resource constraints;
- comparable effort reference;
- whether the finding requires scope adjustment.

For each scope decision, identify:
- what is in scope, out of scope, and deferred;
- explicit non-goals;
- required tradeoffs.

### Step 2: Disposition Every Critique

Every critique from `critical-review.yaml` must receive one disposition:

- `accepted`: valid and repaired in this round.
- `partially_accepted`: valid but only partially repaired.
- `rejected`: invalid, out of scope, or contradicted by stronger evidence.
- `deferred`: valid but requires another round or missing feasibility data.
- `human_decision_required`: requires user judgment about scope, risk tolerance, or contribution framing.

Disposition rules:
- Fatal critiques must be repaired, blocked by human decision, or explicitly marked impossible within scope.
- High critiques should normally become patches unless they require missing feasibility data.
- A critique about problem reality cannot be rejected unless evidence shows the problem is demonstrably real.
- A critique about scope cannot be deferred without documenting what would need to change.

### Step 3: Convert Critiques into Patch Goals

For every accepted or partially accepted critique, define the patch goal:
- What critique does this patch neutralize?
- What proposal section changes?
- What evidence justifies the change?
- What should be true after the patch?

### Step 4: Choose Valid Patch Types

Use only patch types declared in `workflows/proposal/workflow.yaml`:
- `problem_reframing`
- `research_question_revision`
- `scope_narrowing`
- `contribution_rewrite`
- `technical_route_update`
- `risk_register_update`
- `milestone_update`

Patch type rules:
- Use `problem_reframing` when the problem statement must be restated or repositioned.
- Use `research_question_revision` when questions must be clarified, split, or removed.
- Use `scope_narrowing` when the proposal scope must be reduced or explicitly bounded.
- Use `contribution_rewrite` when the contribution statement is vague, overstated, or misaligned.
- Use `technical_route_update` when the technical approach must change.
- Use `risk_register_update` when risks must be added, removed, or reprioritized.
- Use `milestone_update` when deliverables, timelines, or dependencies must change.

### Step 5: Determine Patch Granularity

Each patch should have one primary purpose. Granularity levels:
- problem-statement-level;
- research-question-level;
- scope-level;
- contribution-level;
- technical-approach-level;
- risk-level;
- milestone-level.

Do not combine unrelated repairs into a single patch.

### Step 6: Build Patch Dependency Graph

Order patches by dependency. Typical order:
1. `problem_reframing` patches that change the problem foundation.
2. `research_question_revision` patches.
3. `scope_narrowing` patches.
4. `contribution_rewrite` patches.
5. `technical_route_update` patches.
6. `risk_register_update` patches.
7. `milestone_update` patches.

For each patch, record dependencies, patches that depend on it, and reason for ordering.

### Step 7: Record Traceability

Every patch must trace: `critique → disposition → patch → expected effect`

Record: critique IDs, disposition IDs, feasibility finding IDs, target sections, patch type, dependencies.

### Step 8: Define Expected Effect and Validation Criteria

For every patch, state:
- what will change in the proposal;
- how it addresses the critique;
- what should be true after application;
- how Stage 7 should verify successful application.

### Step 9: Handle Deferred Obligations

For every deferred or partially accepted critique, create an entry in `deferred-obligations.yaml`. Include: critique ID, reason for deferral, required future workflow, required data or decisions, risk if not addressed.

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
    planning_status: ready_for_patch | blocked_by_human_decision | blocked_by_missing_data | blocked_by_scope

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
      patch_type: problem_reframing | research_question_revision | scope_narrowing | contribution_rewrite | technical_route_update | risk_register_update | milestone_update
      priority: critical | high | medium | low
      target_sections:
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
      target_sections: [string]
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
      required_decision: string
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

## Full-Proposal Coverage Requirement
Revision plan must cover all sections of the proposal affected by critiques and scope decisions, not just the primary target.

## Handoff
The next stage (`apply_proposal_patch`) applies the revision plan to the proposal document.
