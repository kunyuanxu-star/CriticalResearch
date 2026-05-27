# Stage 6: Document Patch

## Mission
Apply patches to the target document according to the patch plan and writing plan. Record every change in writing-diff.yaml. Produce patch-trace.yaml for full traceability: patch_id → critique_id → revision_decision → writing_pattern → status. Generate experiment obligations for claim-level patches. Validate patch application.

This stage enforces **Inv4**: Every document patch must trace back to a critique, revision decision, or writing strategy.

## Inputs
- `round:patch-plan.yaml` — concrete patch plan
- `round:writing-plan.yaml` — three-level writing strategy
- `project:documents/<doc-id>.md` — current target document

## Outputs
- Updated `project:documents/<doc-id>.md`
- `writing-diff.yaml` — structured record of all changes
- `patch-trace.yaml` — traceability matrix
- `experiment-obligations.yaml` — experiment specs for claim-level patches

## Allowed Actions
- Read patch plan, writing plan, and current draft.
- Apply patches in sequence.
- Record each change with before/after text and patch_id.
- Update patch lifecycle from planned to applied.
- Generate experiment obligations for claim-level patches.
- Write patch-trace.yaml with full traceability.
- Validate that patches landed correctly.

## Forbidden Actions
- Do not add new evidence or claims not in patches.
- Do not edit sections not targeted by patches.
- Do not generate new critique.
- Do not create untracked edits.

## Procedure

### 1. Apply Patches
Apply patches in patch-plan sequence. For each patch:
- Locate target_section and before_anchor in draft.
- Apply the writing_pattern.
- Record before_text and after_text.
- Verify after_text != before_text.
- Update patch status to applied.

### 2. Record Writing Diff
For every applied patch, write an entry to writing-diff.yaml:
- patch_id, section_anchor, before_text, after_text, status: applied.

### 3. Generate Patch Trace
Write patch-trace.yaml linking each patch to its origin:
- trace_id, patch_id, critique_id, revision_decision, writing_pattern, status.
- validation_notes.

### 4. Generate Experiment Obligations
For every patch affecting a core claim, define:
- Target claim, hypothesis, baselines, evidence type, validation method, metrics, success criteria.
- Do not invent results.

### 5. Validate
- Verify every planned patch is either applied or explicitly rejected/blocked.
- Verify draft is >100 bytes after changes.
- Verify no untracked sections were modified.

## Output Contract

```yaml
writing-diff.yaml:
  changes:
    - patch_id: PP-###
      section_anchor: string
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
      writing_pattern: string
      status: planned|applied|validated|rejected|blocked
      validation_notes: string

experiment-obligations.yaml:
  schema_version: "1.0.0"
  round_id: integer
  obligations:
    - experiment_id: EXP-###
      target_claim: CLM-###
      hypothesis: string
      baselines: [string]
      evidence_type: string
      validation_method: string
      metrics: [string]
      success_criteria: string
```

## Failure Conditions
- Any applied patch has no writing-diff entry.
- Any change has before_text == after_text.
- Draft < 100 bytes after changes.
- Any patch missing traceability in patch-trace.yaml.
- Any claim-level patch missing experiment obligation.

## Completion Checklist
- [ ] All approved patches applied to draft.
- [ ] writing-diff.yaml records every change.
- [ ] patch-trace.yaml links every patch to critique and revision.
- [ ] Experiment obligations generated for claim-level patches.
- [ ] Draft validated (>100 bytes, no untracked changes).

## Full-Document Coverage Requirement
Patches may be localized, but the global argument flow must be checked after application. Ensure upstream/downstream sections remain consistent.

## Handoff
The next stage (`s7_knowledge_consolidation`) distills round-local learning into the global knowledge base.
