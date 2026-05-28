# Stage 6: Revision Plan

## Purpose

Transform the critical review, claim-evidence analysis, and writing strategy into a concrete, ordered, evidence-constrained revision plan for the target paper.

This stage is part of the **paper workflow**. Its role is not to edit the paper. Its role is to compile reviewer objections and writing decisions into an executable patch plan that Stage 7 can apply without free-form judgment.

Every patch must answer a specific question:

> Which OSDI/SOSP-level reviewer objection does this patch neutralize, and what must change in the paper for that objection to no longer apply?

A revision plan is invalid if it only says “rewrite,” “clarify,” “strengthen motivation,” or “improve flow” without specifying the affected claim, paragraph, section, evidence constraint, and expected reviewer-visible effect.

## Stage Type

planning-only

## Required Inputs

* `critical-review.yaml` — reviewer critiques, severity, grounding, and likely objections.
* `writing-strategy.yaml` — narrative, section, paragraph, sentence, claim, and positioning strategy.
* `claim-evidence-grounding.yaml` — evidence strength, overclaims, claim risks, and evaluation obligations.
* `osdi-sosp-reviewer-risk.yaml` — fatal/high reviewer risks if available.
* `evaluation-obligations.yaml` — required experiments, baselines, workloads, and metrics if available.
* `contract.yaml` — target document, target units, round objective, and scope.
* Target paper document — current text and unit anchors.
* `workflows/paper/workflow.yaml` — valid patch types and patch schema.
* `workflows/paper/profile.md` — paper workflow semantics.
* `workflows/_shared/stage-protocol.md` — stage execution discipline.
* `workflows/_shared/patch-discipline.md` — patch traceability and dependency rules.
* `workflows/_shared/evidence-discipline.md` — evidence adequacy and claim-strength rules.

## Allowed Writes

* `revision-plan.yaml`
* `patch-plan.yaml`
* `deferred-obligations.yaml`
* `no-patch-rationale.yaml`

No target paper edits are allowed in this stage.

## Outputs

* `revision-plan.yaml` — full revision plan with dispositions, patches, and traceability.
* `patch-plan.yaml` — ordered, dependency-aware patch execution plan.
* `deferred-obligations.yaml` — deferred critiques requiring future rounds or evidence.
* `no-patch-rationale.yaml` — rejected critiques with rationale and evidence.
* `evaluation-obligations.yaml` — updated evaluation obligations linked to patches.
* `osdi-sosp-reviewer-risk.yaml` — updated reviewer risk assessment reflecting patch dispositions.

## Required Procedure

### Step 1: Load Critiques, Strategy, and Evidence Constraints

Read all critique items, writing-strategy decisions, and claim-evidence records.

For each critique, identify:

* critique ID;
* severity;
* affected section, paragraph, sentence, claim, contribution, or evaluation obligation;
* likely reviewer objection;
* evidence basis;
* required repair;
* whether the critique blocks paper patching.

For each writing strategy item, identify:

* target unit;
* target section;
* affected claim or paragraph;
* intended rhetorical repair;
* source critique;
* evidence constraint.

For each claim in `claim-evidence-grounding.yaml`, identify:

* current wording;
* evidence strength;
* overclaim status;
* evidence-supported wording;
* whether the claim may be strengthened, weakened, moved, deleted, or must remain unchanged.

### Step 2: Disposition Every Critique

Every critique from `critical-review.yaml` must receive one disposition:

* `accepted`: valid and repaired in this round.
* `partially_accepted`: valid but only partially repaired in this round.
* `rejected`: invalid, out of scope, already handled, or contradicted by stronger evidence.
* `deferred`: valid but requires another round, new evidence, new experiments, or a different target unit.
* `human_decision_required`: requires user judgment about scope, positioning, risk tolerance, or contribution framing.

Disposition rules:

* Fatal critiques must be repaired, blocked by human decision, or explicitly marked impossible within scope.
* High critiques should normally become patches unless they require missing evidence or out-of-scope work.
* A critique about overclaiming cannot be rejected unless evidence shows the claim is actually supported.
* A critique about missing baseline cannot be rejected unless the baseline is out of scope or already handled.
* A critique about writing clarity cannot be accepted without a concrete target paragraph, sentence, or section operation.

### Step 3: Convert Reviewer Objections into Patch Goals

For every accepted or partially accepted critique, define a patch goal.

A patch goal must state:

* the reviewer objection to neutralize;
* the current paper weakness;
* the required paper-level change;
* the evidence or strategy supporting the change;
* the expected reviewer-visible effect.

Invalid patch goal:

> Improve motivation.

Valid patch goal:

> Replace the current generic motivation paragraph in `paper.introduction` with a problem-root-cause paragraph that explains why container-level isolation cannot safely support privileged workload customization without exposing shared-kernel attack surface. This addresses CR-003 by making the problem specific, systems-relevant, and tied to a concrete isolation boundary.

### Step 4: Choose Valid Patch Types

Use only patch types declared in `workflows/paper/workflow.yaml`:

* `paragraph_rewrite`
* `section_restructure`
* `claim_weakening`
* `claim_strengthening`
* `related_work_repositioning`
* `evaluation_obligation_addition`
* `contribution_rewrite`

Patch type rules:

* Use `section_restructure` when the order or role of sections/paragraph groups must change.
* Use `paragraph_rewrite` when the local argument must be rewritten without changing the paper structure.
* Use `claim_weakening` when the current claim exceeds available evidence.
* Use `claim_strengthening` only when direct evidence supports stronger wording.
* Use `related_work_repositioning` when the paper mispositions or underestimates prior work.
* Use `evaluation_obligation_addition` when a claim cannot be defended without adding an experiment, proof, baseline, workload, or metric.
* Use `contribution_rewrite` when the contribution statement is vague, overstated, misplaced, or not aligned with evidence.

Do not use prose rewrite to hide an unresolved evidence, novelty, or baseline problem.

### Step 5: Enforce Claim-Evidence Constraints

Before creating each patch, check whether it modifies any claim.

Rules:

* A claim with `evidence_strength: none` may not be strengthened.
* A claim with `evidence_strength: weak` may not be strengthened unless the patch also adds a concrete evaluation obligation and weakens the immediate paper wording.
* A performance, scalability, security, compatibility, or correctness claim may not be made stronger without direct evidence, formal argument, or explicit evaluation obligation.
* A novelty claim must be checked against dangerous related work.
* If the evidence supports only a narrower scope, the patch must weaken or scope the claim.
* If a claim is unsupported and nonessential, deletion is preferred over vague qualification.

### Step 6: Define Patch Granularity

Each patch should have one primary purpose.

Allowed patch granularity:

* section-level;
* paragraph-level;
* sentence-level;
* claim-level;
* contribution-level;
* related-work-positioning-level;
* evaluation-obligation-level.

Do not combine unrelated repairs into a single patch.

A patch may include multiple local edits only if they are necessary to repair the same reviewer objection.

### Step 7: Build Argument-Dependency Order

Order patches by argument dependency, not merely by location.

Typical order:

1. `section_restructure` patches that change the argument skeleton.
2. Problem/motivation patches.
3. Root-cause and insight patches.
4. Claim weakening or strengthening patches.
5. Contribution rewrite patches.
6. Design/mechanism paragraph rewrites.
7. Related-work repositioning patches.
8. Evaluation-obligation additions.
9. Local transition and paragraph rewrites.

Dependency rules:

* A contribution rewrite must depend on the claim changes that define the contribution.
* A paragraph rewrite must depend on section restructure if the paragraph is moved.
* A related-work repositioning patch must depend on the revised novelty or baseline claim.
* An evaluation-obligation patch must depend on the claim it supports.
* Patches that modify the same paragraph must be ordered explicitly.

### Step 8: Record Traceability

Every patch must trace through the full chain:

`critique → disposition → writing strategy → claim/evidence constraint → patch → expected reviewer-visible effect`

Record:

* critique IDs;
* disposition ID;
* strategy item ID;
* claim IDs;
* evidence IDs;
* reviewer-risk IDs;
* evaluation-obligation IDs;
* target units;
* patch type;
* dependencies.

A patch without this trace is invalid.

### Step 9: Define Expected Effect and Validation Criteria

For every patch, state:

* what will change in the paper;
* how it addresses the critique;
* what reviewer objection should no longer apply;
* what claim becomes weaker, stronger, clearer, moved, or deleted;
* how Stage 7 should verify successful application.

Validation criteria must be specific.

Invalid:

> The section becomes clearer.

Valid:

> The first paragraph of `paper.introduction` now states a concrete systems problem, identifies the shared-kernel/privileged-workload conflict, and avoids unsupported claims about general security improvement.

### Step 10: Handle Deferred Obligations

For every deferred or partially accepted critique, create an entry in `deferred-obligations.yaml`.

Each deferred obligation must include:

* critique ID;
* reason for deferral;
* required future workflow;
* required target unit;
* required evidence, experiment, baseline, or human decision;
* risk if not addressed.

Do not use deferral to avoid difficult but in-scope repairs.

### Step 11: Handle Rejected Critiques

For every rejected critique, create an entry in `no-patch-rationale.yaml`.

A rejection is valid only if:

* the critique is factually wrong;
* the critique is contradicted by stronger evidence;
* the critique is out of scope for the current round;
* the issue is already handled in the current paper;
* the critique depends on an invalid interpretation of the paper.

Every rejection must cite evidence, document location, or scope rationale.

### Step 12: Produce Revision Plan and Patch Plan

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
    planning_status: ready_for_patch | blocked_by_human_decision | blocked_by_missing_evidence | blocked_by_scope

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
      patch_type: paragraph_rewrite | section_restructure | claim_weakening | claim_strengthening | related_work_repositioning | evaluation_obligation_addition | contribution_rewrite
      priority: critical | high | medium | low

      target_units:
        - string
      target_locations:
        - section: string
          paragraph_id: string | null
          sentence_id: string | null
          anchor_description: string

      trace:
        critique_ids:
          - string
        disposition_ids:
          - string
        writing_strategy_refs:
          - string
        claim_ids:
          - string
        evidence_ids:
          - string
        reviewer_risk_ids:
          - string
        evaluation_obligation_ids:
          - string

      reviewer_objection_addressed: string
      current_problem: string
      patch_goal: string
      expected_effect: string

      claim_constraints:
        modifies_claim: boolean
        claim_change_type: none | weaken | strengthen | move | delete | split | clarify
        evidence_strength: strong | moderate | weak | none | not_applicable
        evidence_permits_change: boolean
        required_wording_constraint: string

      dependency_order:
        depends_on:
          - string
        blocks:
          - string
        ordering_rationale: string

      expected_diff_scope:
        operation: insert | replace | delete | move | split | merge
        estimated_paragraphs_changed: integer | null
        estimated_lines_changed: integer | null
        content_guidance: string

      validation_criteria:
        - string

      residual_risks:
        - string
```

```yaml
patch-plan.yaml:
  schema_version: "1.0.0"
  round_id: string
  patches:
    - patch_id: string
      patch_type: string
      target_units:
        - string
      operation: insert | replace | delete | move | split | merge
      anchor_description: string
      content_guidance: string
      claim_changes:
        - claim_id: string
          action: weaken | strengthen | move | delete | split | clarify | none
      expected_diff_summary: string
      dependencies:
        - string
      validation:
        - string
```

```yaml
deferred-obligations.yaml:
  schema_version: "1.0.0"
  obligations:
    - obligation_id: string
      critique_id: string
      reason_for_deferral: string
      required_future_workflow: paper | survey | design | experiment | proposal
      required_target_unit: string | null
      required_evidence_or_decision: string
      risk_if_not_addressed: fatal | high | medium | low
```

```yaml
no-patch-rationale.yaml:
  schema_version: "1.0.0"
  decisions:
    - critique_id: string
      rationale: string
      evidence_or_scope_basis: string
      residual_risk: string | null
```

## Quality Gates

* Every critique from `critical-review.yaml` has exactly one disposition.
* Every accepted critique maps to at least one patch.
* Every partially accepted critique maps to at least one patch and one residual risk or deferred obligation.
* Every rejected critique has evidence-backed or scope-backed rationale.
* Every deferred critique identifies a future workflow, target unit, or required evidence.
* Every patch uses a patch type declared in `workflows/paper/workflow.yaml`.
* Every patch targets only units allowed by `contract.yaml`.
* Every patch has critique trace, strategy trace, claim/evidence trace, expected effect, dependency order, and validation criteria.
* No claim is strengthened unless `claim-evidence-grounding.yaml` permits it.
* Every patch dependency points to an earlier patch in `patch_order`.
* `patch-plan.yaml` entries match `revision-plan.yaml` patches one-to-one.
* The plan is executable by Stage 7 without unstated judgment.

## Failure Conditions

Stop and report a blocker if:

* any critique lacks a disposition;
* any accepted critique lacks a patch;
* any patch uses an invalid patch type;
* any patch targets a unit outside the contract;
* any patch dependency is cyclic or points forward incorrectly;
* any claim-strengthening patch targets a weak or unsupported claim;
* a fatal critique cannot be repaired, deferred with scope rationale, or assigned to human decision;
* the patch plan is too vague for Stage 7 to apply without free editing.

## Forbidden Behavior

* Do not apply patches to the paper document.
* Do not generate patches without critique → disposition → strategy trace.
* Do not use generic patch descriptions such as “improve clarity.”
* Do not invent patch types.
* Do not plan edits outside target units.
* Do not strengthen unsupported claims.
* Do not defer hard in-scope critiques merely to avoid revision.
* Do not reject critiques without evidence or scope rationale.
* Do not reorder patches arbitrarily.
* Do not hide evidence gaps through rhetorical rewriting.

## Advance Rule

After `revision-plan.yaml`, `patch-plan.yaml`, `deferred-obligations.yaml`, and `no-patch-rationale.yaml` are produced and all quality gates pass, run `cr stage advance`.
