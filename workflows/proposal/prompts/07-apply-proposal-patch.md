# Stage 7: Apply Proposal Patch

## Mission
Apply patches to the proposal document according to the revision plan. Record every change in writing-diff.yaml. Produce patch-trace.yaml for full traceability: patch_id → critique_id → revision_decision → writing_pattern → status. Generate milestone obligations for goal-level patches. Validate patch application.

This stage enforces **Inv7**: Every document patch must trace back to a critique, revision decision, or scope decision.

## Inputs
- `round:revision-plan.yaml` — goal/structure/resource/evidence-level revisions
- `project:documents/proposal.md` — current proposal document
- `round:proposal-state.yaml` — frozen proposal baseline
- `round:contribution-statement.yaml` — contribution boundary

## Outputs
- Updated `project:documents/proposal.md`
- `writing-diff.yaml` — structured record of all changes
- `patch-trace.yaml` — traceability matrix
- `milestone-obligations.yaml` — milestone specs for goal-level patches

## Allowed Actions
- Read revision plan, proposal document, proposal state, and contribution statement.
- Apply patches in revision-plan sequence.
- Record each change with before/after text and patch_id.
- Update patch lifecycle from planned to applied.
- Generate milestone obligations for goal-level patches.
- Write patch-trace.yaml with full traceability.
- Validate that patches landed correctly.

## Forbidden Actions
- Do not add new goals or evidence not in revisions.
- Do not edit sections not targeted by revisions.
- Do not generate new critique.
- Do not create untracked edits.

## Procedure

### 1. Apply Patches
For each revision with status != blocked:
- Locate target section in proposal document.
- Determine writing pattern: add_section, delete_section, rewrite_section, strengthen_goal, weaken_goal, reframe_goal, add_evidence, add_milestone, update_resource_estimate, restructure_argument.
- Apply the pattern.
- Record before_text and after_text.
- Verify after_text != before_text.
- Update status to implemented.

### 2. Record Writing Diff
For every applied revision, write an entry to writing-diff.yaml:
- revision_id, section_anchor, before_text, after_text, status: applied.

### 3. Generate Patch Trace
Write patch-trace.yaml linking each change to its origin:
- trace_id, revision_id, critique_id, writing_pattern, status.
- validation_notes.

### 4. Generate Milestone Obligations
For every revision affecting a goal with resource or timeline implications:
- Target goal, deliverable, timeline adjustment, resource delta, dependencies, success criteria.
- Do not invent resource numbers without evidence support.

### 5. Validate
- Verify every approved revision is either applied or explicitly rejected/blocked.
- Verify proposal document is >200 bytes after changes.
- Verify no untracked sections were modified.
- Verify contribution statement is reflected in the document text.
- Verify the proposal document still has: problem statement, goals, milestones, risks.

## Output Contract

```yaml
writing-diff.yaml:
  changes:
    - revision_id: REV-###
      section_anchor: string
      before_text: string (>= 10 chars)
      after_text: string (>= 10 chars, != before_text)
      status: applied

patch-trace.yaml:
  schema_version: "1.0.0"
  round_id: integer
  traces:
    - trace_id: TRC-###
      revision_id: REV-###
      critique_id: CRT-###
      writing_pattern: add_section | delete_section | rewrite_section | strengthen_goal | weaken_goal | reframe_goal | add_evidence | add_milestone | update_resource_estimate | restructure_argument
      status: planned | applied | validated | rejected | blocked
      validation_notes: string

milestone-obligations.yaml:
  schema_version: "1.0.0"
  round_id: integer
  obligations:
    - obligation_id: MOB-###
      target_goal: GL-###
      deliverable: string
      timeline_adjustment: string
      resource_delta: string
      dependencies: [string]
      success_criteria: string
```

## Failure Conditions
- Any applied revision has no writing-diff entry.
- Any change has before_text == after_text.
- Proposal document < 200 bytes after changes.
- Any revision missing traceability in patch-trace.yaml.
- Any goal-level revision missing milestone obligation.
- Proposal document missing problem statement, goals, milestones, or risks after patching.

## Completion Checklist
- [ ] All approved revisions applied to proposal document.
- [ ] writing-diff.yaml records every change.
- [ ] patch-trace.yaml links every revision to critique.
- [ ] Milestone obligations generated for goal-level revisions.
- [ ] Proposal document validated (>200 bytes, no untracked changes, structural completeness).

## Handoff
The next stage (`risk_milestone_update`) re-evaluates the risk register and milestone tracker against the patched proposal document.
