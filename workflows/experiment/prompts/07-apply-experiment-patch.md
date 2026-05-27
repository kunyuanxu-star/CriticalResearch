# Stage 7: Apply Experiment Patch

## Mission
Apply revisions to the experiment plan according to the revision plan. Record every change in writing-diff.yaml. Produce patch-trace.yaml for full traceability: patch_id → critique_id → revision_decision → status. Generate validation obligations for methodology and measurement-level patches. Validate patch application.

Every experiment plan patch must trace back to a critique or revision decision.

## Inputs
- `round:revision-plan.yaml` — design/methodology/measurement/analysis-level revisions
- `round:experiment-execution-plan.yaml` — step-by-step execution plan
- `documents/experiment-plan.md` — current experiment plan

## Outputs
- Updated `documents/experiment-plan.md`
- `writing-diff.yaml` — structured record of all changes
- `patch-trace.yaml` — traceability matrix
- `validation-obligations.yaml` — validation specs for methodology and measurement patches

## Allowed Actions
- Read revision plan, execution plan, and experiment plan.
- Apply patches in sequence.
- Record each change with before/after text and patch_id.
- Update patch lifecycle from planned to applied.
- Generate validation obligations for methodology and measurement-level patches.
- Write patch-trace.yaml with full traceability.
- Validate that patches landed correctly.

## Forbidden Actions
- Do not add new hypotheses or variables not in patches.
- Do not modify components not targeted by patches.
- Do not generate new critique.
- Do not create untracked edits.

## Procedure

### 1. Apply Patches
Apply patches in revision-plan sequence. For each revision:
- Locate target_component in experiment plan.
- Apply the revision action (redesign | add_control | change_measure | add_analysis | reframe | delete | defer).
- Record before_text and after_text.
- Verify after_text != before_text.
- Update revision status to implemented.

### 2. Record Writing Diff
For every applied patch, write an entry to writing-diff.yaml:
- patch_id, component_anchor, before_text, after_text, status: applied.

### 3. Generate Patch Trace
Write patch-trace.yaml linking each patch to its origin:
- trace_id, patch_id, critique_id, revision_decision, status.
- validation_notes.

### 4. Generate Validation Obligations
For every methodology or measurement-level patch, define:
- Target component, validation method, acceptance criteria.
- Required evidence type, success threshold.
- Do not invent results.

### 5. Validate
- Verify every planned revision is either applied or explicitly rejected/blocked.
- Verify experiment plan is >100 bytes after changes.
- Verify no untracked components were modified.

## Output Contract

```yaml
writing-diff.yaml:
  changes:
    - patch_id: PP-###
      component_anchor: string
      before_text: string (>= 10 chars)
      after_text: string (>= 10 chars, != before_text)
      status: applied

patch-trace.yaml:
  schema_version: "1.0.0"
  round_id: integer
  traces:
    - trace_id: TRC-###
      patch_id: PP-###
      critique_id: CRT-###
      revision_decision: REV-###
      status: planned | applied | validated | rejected | blocked
      validation_notes: string

validation-obligations.yaml:
  schema_version: "1.0.0"
  round_id: integer
  obligations:
    - validation_id: VAL-###
      target_component: string
      validation_method: string
      acceptance_criteria: string (>= 10 chars)
      required_evidence_type: string
      success_threshold: string
      affected_hypotheses: [HYP-###]
```

## Failure Conditions
- Any applied patch has no writing-diff entry.
- Any change has before_text == after_text.
- Experiment plan < 100 bytes after changes.
- Any patch missing traceability in patch-trace.yaml.
- Any methodology or measurement-level patch missing validation obligation.

## Completion Checklist
- [ ] All approved revisions applied to experiment plan.
- [ ] writing-diff.yaml records every change.
- [ ] patch-trace.yaml links every patch to critique and revision.
- [ ] Validation obligations generated for methodology and measurement patches.
- [ ] Experiment plan validated (>100 bytes, no untracked changes).

## Full-Experiment Coverage Requirement
Patches may be localized, but the global experiment logic must be checked after application. Ensure upstream/downstream components remain consistent.

## Handoff
The next stage (`validation_obligations`) elaborates validation obligations into concrete validation protocols.
