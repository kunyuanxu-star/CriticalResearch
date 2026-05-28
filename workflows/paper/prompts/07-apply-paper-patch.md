# Stage 7: Apply Paper Patch

## Purpose

Apply the ordered paper patch plan from Stage 6 to the declared mutable paper document while preserving unit boundaries, claim-evidence constraints, reviewer-objection traceability, and exact document diffs.

This stage is part of the **paper workflow**. It is the only stage that modifies the target paper document. All previous stages produce analysis, critique, strategy, or planning artifacts; this stage executes the accepted patch plan.

This stage must not perform free-form editing. Every modification must be justified by a planned patch and must trace through:

`critique → disposition → writing strategy → claim/evidence constraint → patch plan → paper patch → document diff → patch trace`

A patch is valid only if it modifies the declared mutable document, stays within allowed unit boundaries, preserves anchors, records exact before/after text, and verifies that the intended reviewer objection has been addressed.

## Stage Type

controlled-patching

## Required Inputs

* `revision-plan.yaml` — ordered patches, critique dispositions, dependencies, expected effects, claim constraints, and validation criteria.
* `patch-plan.yaml` — executable patch instructions, target units, operations, anchors, and content guidance.
* `deferred-obligations.yaml` — critiques deferred from this round.
* `no-patch-rationale.yaml` — rejected critiques and their rationale.
* `critical-review.yaml` — original reviewer critiques and likely objections.
* `writing-strategy.yaml` — narrative, section, paragraph, sentence, and claim strategy.
* `claim-evidence-grounding.yaml` — evidence strength, overclaim assessments, evidence-supported wording, and claim risks.
* `evaluation-obligations.yaml` — required experiments, baselines, workloads, and metrics if available.
* `contract.yaml` — mutable document declaration, target units, round scope, and read-only context.
* `units/<target>.units.yaml` — target unit boundaries and anchors.
* `workflows/paper/workflow.yaml` — valid paper patch types.
* `workflows/paper/schemas/paper-patch.schema.json` — paper patch payload schema.
* `workflows/paper/profile.md` — paper workflow semantics.
* `workflows/_shared/stage-protocol.md` — stage execution discipline.
* `workflows/_shared/patch-discipline.md` — patch traceability and diff rules.
* `workflows/_shared/evidence-discipline.md` — evidence adequacy and claim-strength rules.
* Target paper document — current paper text with unit anchors.

## Outputs

* `deferred-obligations.yaml`
* `evaluation-obligations.yaml`
* `no-patch-rationale.yaml`

## Allowed Writes
* Target paper document declared in `contract.yaml` — only within allowed unit boundaries.
* `patches/PP-NNN.yaml`
* `patch-trace.yaml`
* `document-diff.yaml`
* `applied-patch-summary.md`
* `residual-risks.yaml`
* `next-round-targets.yaml`

No other project document may be modified.

## Required Procedure

### Step 1: Load Scope and Verify Mutable Document

Read `contract.yaml` and identify:

* project ID;
* round ID;
* mutable document ID;
* mutable document path;
* target units;
* allowed write scope;
* read-only context documents.

Verify:

* the target paper document path matches `contract.yaml`;
* the paper document exists;
* every target unit exists in the unit registry;
* every unit anchor exists in the document;
* anchor comments are present and must not be modified;
* no read-only context document will be written.

If scope or unit boundaries are ambiguous, stop and report a blocker.

### Step 2: Validate Revision Plan Before Editing

Read `revision-plan.yaml` and `patch-plan.yaml`.

Before applying any edit, verify:

* every accepted critique has at least one planned patch;
* every patch ID is unique;
* every patch type is valid for paper workflow;
* every patch appears in `patch_order`;
* patch dependencies are acyclic;
* every dependency appears earlier in `patch_order`;
* every patch targets only allowed units;
* every patch has critique trace;
* every patch has writing-strategy trace when relevant;
* every claim-modifying patch has claim-evidence constraints;
* every patch has validation criteria;
* `patch-plan.yaml` and `revision-plan.yaml` agree.

Do not apply patches that are absent from the revision plan.

### Step 3: Generate Patch Files Before Editing

For each patch in dependency order, generate `patches/PP-NNN.yaml` before modifying the paper.

Each patch file must follow this structure:

```yaml
schema_version: "1.0.0"
patch_id: PP-NNN
workflow: paper
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
  revision_plan_items:
    - string

patch_type: paragraph_rewrite | section_restructure | claim_weakening | claim_strengthening | related_work_repositioning | evaluation_obligation_addition | contribution_rewrite

status: pending

intended_repair:
  reviewer_objection: string
  current_problem: string
  patch_goal: string
  expected_effect: string
  validation_criteria:
    - string

claim_constraints:
  modifies_claim: boolean
  claim_change_type: none | weaken | strengthen | move | delete | split | clarify
  evidence_strength: strong | moderate | weak | none | not_applicable
  evidence_permits_change: boolean
  evidence_supported_wording: string | null
  forbidden_wording: string | null

paper_payload:
  writing_change_type: paragraph_rewrite | section_restructure | claim_weakening | claim_strengthening | related_work_repositioning | evaluation_obligation_addition | contribution_rewrite
  claim_changes:
    - string
  rhetorical_pattern: string | null
  text_changes:
    - unit: string
      operation: insert | replace | delete | move | split | merge
      anchor_before: string | null
      anchor_after: string | null
      old_content: string | null
      new_content: string
      rationale: string

application_record:
  applied_at: null
  document_hash_before: null
  document_hash_after: null
  before_snippet: null
  after_snippet: null
  status: pending
```

### Step 4: Apply Patches in Dependency Order

Apply patches exactly in `patch_order`.

For every patch:

1. Locate the target unit.
2. Locate the target anchor, paragraph, sentence, claim, section, or contribution statement.
3. Verify the edit is inside the allowed unit boundary.
4. Capture exact before text.
5. Apply the planned edit.
6. Capture exact after text.
7. Verify anchors were not modified.
8. Verify no read-only document was modified.
9. Verify no unrelated unit was modified.
10. Mark the patch file as `applied`.

If the patch cannot be applied as planned, do not improvise. Record a blocker or residual risk.

### Step 5: Apply Patch-Type Specific Rules

#### paragraph_rewrite

A paragraph rewrite must:

* target a specific paragraph;
* preserve the intended section role;
* implement the expected rhetorical function from `writing-strategy.yaml`;
* avoid unsupported strengthening;
* improve argument logic rather than merely polishing style.

The rewritten paragraph must address the reviewer objection listed in the patch.

#### section_restructure

A section restructure may reorder, split, merge, or move paragraphs or subsections.

It must:

* preserve unit boundaries unless the plan explicitly allows multi-unit structural edits;
* update local transitions after movement;
* remove duplicated or orphaned text;
* preserve citation and claim references;
* record every affected unit in `document-diff.yaml`.

If restructuring breaks references or creates dangling transitions, stop and repair within the planned patch scope or record a blocker.

#### claim_weakening

A claim-weakening patch must:

* locate the exact overclaimed text;
* replace it with evidence-supported wording;
* preserve the useful contribution if possible;
* avoid vague hedging such as “may”, “could”, or “somewhat” unless the uncertainty is meaningful;
* ensure the new wording matches the scope in `claim-evidence-grounding.yaml`.

#### claim_strengthening

A claim-strengthening patch is allowed only if:

* `claim-evidence-grounding.yaml` marks evidence strength as `strong` or `moderate`;
* the stronger wording is explicitly permitted by evidence-supported wording;
* dangerous related work does not contradict the claim;
* the patch does not generalize beyond tested conditions.

If the evidence does not permit strengthening, downgrade the patch to claim weakening or record a blocker. Do not strengthen unsupported claims for rhetorical effect.

#### related_work_repositioning

A related-work repositioning patch must:

* name the competing work precisely;
* state the actual difference, not a strawman;
* distinguish mechanism, abstraction, assumptions, workload, threat model, and evaluation scope;
* avoid dismissive language;
* avoid weakening dangerous baselines by omission;
* ensure the paper's positioning remains fair and evidence-backed.

#### evaluation_obligation_addition

An evaluation-obligation patch must:

* add a concrete obligation, not a vague promise;
* identify the claim that requires evaluation;
* identify required baseline, workload, metric, ablation, proof, or artifact evidence;
* phrase the obligation honestly if the paper has not yet performed it;
* avoid implying completed experiments that do not exist.

#### contribution_rewrite

A contribution rewrite must:

* make the contribution specific;
* align with evidence-supported claims;
* distinguish the contribution from prior work;
* avoid generic wording such as “we present a system for X”;
* avoid overclaiming novelty or generality;
* preserve consistency with introduction, design, evaluation, and related work.

### Step 6: Verify Claim-Evidence Safety After Each Patch

After every claim-modifying patch, check:

* Does the modified claim appear in `claim-evidence-grounding.yaml`?
* Does the new wording stay within evidence-supported scope?
* Did the patch introduce a new claim not present in the claim inventory?
* If a new claim appears, is it explicitly recorded in the patch trace for Stage 8 claim alignment?
* Did the patch strengthen any weak or unsupported claim?
* Did the patch remove required limitations?

If a patch introduces an unsupported new claim, record residual risk or revise within the planned patch scope.

### Step 7: Verify Reviewer-Objection Repair

For every applied patch, verify whether the reviewer objection has been addressed.

Classify repair status:

* `repaired`: the objection should no longer apply.
* `partially_repaired`: the patch reduces the risk but does not fully answer the objection.
* `unresolved`: the patch failed to address the objection.
* `blocked`: the patch could not be applied or requires missing evidence/human decision.

Do not mark a patch successful merely because text changed.

### Step 8: Record Document Diff

Produce `document-diff.yaml`.

The diff must include exact before/after text for every document modification.

```yaml
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
      operation: insert | replace | delete | move | split | merge
      location:
        section: string | null
        paragraph_id: string | null
        sentence_id: string | null
        anchor_before: string | null
        anchor_after: string | null
      before_text: string
      after_text: string
      critique_ids:
        - string
      claim_ids:
        - string
      evidence_ids:
        - string
      validation_result: passed | partial | failed
      repair_status: repaired | partially_repaired | unresolved | blocked
      residual_risk: string | null

  boundary_check:
    mutable_document_only: true
    target_units_only: true
    anchor_comments_preserved: true
    read_only_documents_untouched: true

  claim_safety_check:
    unsupported_claims_introduced: false
    strengthened_claims_supported: true
    weakened_claims_match_evidence_scope: true
    notes: string

  document_wellformedness_check:
    headings_valid: true
    citations_preserved: true
    cross_references_valid: true
    no_orphaned_transitions: true
    notes: string
```

### Step 9: Record Patch Trace

Produce `patch-trace.yaml`.

Patch trace must connect critique, disposition, strategy, patch, diff, and repair result.

```yaml
patch-trace.yaml:
  schema_version: "1.0.0"
  round_id: string

  patches:
    - patch_id: string
      source_critiques:
        - string
      disposition: accepted | partially_accepted | rejected | deferred | human_decision_required
      writing_strategy_refs:
        - string
      claim_ids:
        - string
      evidence_ids:
        - string
      target_units:
        - string
      patch_type: paragraph_rewrite | section_restructure | claim_weakening | claim_strengthening | related_work_repositioning | evaluation_obligation_addition | contribution_rewrite
      expected_effect: string
      actual_effect: string
      diff_ids:
        - string
      repair_status: repaired | partially_repaired | unresolved | blocked
      residual_risk: string | null
      status: applied | partial | failed | blocked
```

### Step 10: Produce Applied Patch Summary

Write `applied-patch-summary.md`.

The summary must explain:

* which patches were applied;
* which reviewer objections were repaired;
* which claims were weakened, strengthened, moved, deleted, or clarified;
* which sections were restructured;
* which related-work positioning changes were made;
* which evaluation obligations were added;
* what residual risks remain.

This summary is for human inspection and later closure.

### Step 11: Record Residual Risks

Produce `residual-risks.yaml` for unresolved or partially repaired issues.

Residual risks include:

* reviewer objection only partially repaired;
* patch applied but validation failed;
* claim wording still broader than evidence;
* dangerous related work still weakly handled;
* evaluation obligation still missing evidence;
* section restructure left a weak transition;
* patch required broader scope than current round permits;
* human decision required.

```yaml
residual-risks.yaml:
  schema_version: "1.0.0"
  risks:
    - risk_id: string
      linked_patch_id: string | null
      linked_critique_id: string | null
      linked_claim_id: string | null
      severity: fatal | high | medium | low
      description: string
      reason_unresolved: string
      required_next_action: string
```

### Step 12: Record Next-Round Targets

Produce `next-round-targets.yaml` if the patching process reveals future work.

Possible targets include:

* claim-evidence re-audit;
* related-work deep dive;
* evaluation design;
* design clarification;
* introduction rewrite;
* limitation discussion;
* terminology cleanup;
* human decision about scope or positioning.

Do not modify other documents in this stage.

### Step 13: Final Validation

Before advancing, verify:

* every accepted patch in `revision-plan.yaml` was applied, partially applied with residual risk, or blocked with explicit reason;
* every applied patch has a `patches/PP-NNN.yaml` file;
* every applied patch appears in `patch-trace.yaml`;
* every document change appears in `document-diff.yaml`;
* every document change stayed inside allowed units;
* no anchor comments were modified;
* no read-only documents were modified;
* claim-strengthening patches are evidence-supported;
* claim-weakening patches match evidence-supported scope;
* the paper remains well-formed;
* no unrelated “while editing” changes were introduced.

## Output

* `patches/PP-NNN.yaml` — one per applied or attempted patch.
* Modified target paper document — only within declared unit boundaries.
* `document-diff.yaml` — exact before/after diff for every text change.
* `patch-trace.yaml` — critique-to-strategy-to-patch-to-diff trace.
* `applied-patch-summary.md` — narrative summary of applied repairs.
* `residual-risks.yaml` — unresolved or partially repaired issues.
* `next-round-targets.yaml` — future round candidates if needed.

## Quality Gates

* Every applied patch originates from `revision-plan.yaml`.
* Every accepted critique has an applied patch, partial patch with residual risk, or blocker.
* Every patch file has status `applied`, `partial`, `failed`, or `blocked`.
* Every document edit is inside declared unit boundaries.
* Anchor comments are unchanged.
* Every text change has exact before/after diff.
* Every patch has critique trace and strategy trace.
* Every claim-modifying patch obeys `claim-evidence-grounding.yaml`.
* No unsupported claim is strengthened.
* No dangerous related work is removed or softened without rationale.
* The paper remains structurally well-formed.
* `patch-trace.yaml` and `document-diff.yaml` exist and are complete.
* Residual risks are recorded rather than hidden.

## Failure Conditions

Stop and report a blocker if:

* the target unit anchor cannot be found;
* a patch would modify content outside allowed unit boundaries;
* a patch depends on a missing or unapplied patch;
* a patch lacks critique trace or claim/evidence constraint;
* a claim-strengthening patch lacks sufficient evidence;
* the target text no longer exists because an earlier patch invalidated the plan;
* applying the patch would require modifying another document;
* the patch plan is too vague to execute without free editing;
* the paper becomes malformed after restructuring;
* a fatal critique remains unresolved without blocker or human decision.

## Forbidden Behavior

* Do not freely rewrite the paper.
* Do not apply patches absent from `revision-plan.yaml`.
* Do not make “while I’m here” edits.
* Do not modify anchor comments.
* Do not modify read-only context documents.
* Do not silently expand patch scope.
* Do not strengthen unsupported claims.
* Do not hide evidence gaps through rhetorical rewriting.
* Do not delete or weaken dangerous related work because it hurts positioning.
* Do not mark a patch successful merely because text changed.
* Do not omit before/after snippets.
* Do not advance if patch trace or document diff is incomplete.

## Advance Rule

After all patch files, paper document modifications, `document-diff.yaml`, `patch-trace.yaml`, `applied-patch-summary.md`, `residual-risks.yaml`, and `next-round-targets.yaml` are produced and all quality gates pass, run `cr stage advance`.
