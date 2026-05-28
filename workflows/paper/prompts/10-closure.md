# Stage 10: Closure

## Purpose

Verify that the round is complete and ready to close. This stage runs the validator pipeline, confirms all required outputs exist, generates next-round targets for any deferred or discovered work, and produces the closure summary. This is the final gate — if closure fails, the round is not complete regardless of what earlier stages produced.

This stage must NOT:
- Modify any stage output artifacts (fix issues in the source stage, not here)
- Skip validators
- Close a round with unresolved blockers

## Stage Type

closure

## Required Inputs

- `contract.yaml` — round scope, required outputs, mutable document
- `workflow-state.yaml` — current stage status, blockers, human decisions
- `critical-review.yaml` — all critiques and dispositions
- `revision-plan.yaml` — all patches and dispositions
- `patch-trace.yaml` — applied patches and traceability
- `document-diff.yaml` — all text changes
- `claim-alignment.yaml` — post-patch claim alignment
- `knowledge-delta.yaml` — knowledge extraction
- All other stage outputs — paper-state, claim-evidence-grounding, writing-strategy
- The modified paper document
- `workflows/paper/workflow.yaml` — workflow-specific validators
- `workflows/_shared/stage-protocol.md` — stage execution discipline
- `workflows/_shared/closure-discipline.md` — validator pipeline and closure checklist

## Allowed Writes

- `next-round-targets.yaml` — and ONLY next-round-targets.yaml
- Closure summary (written by `cr round close`, not by this stage directly)

## Required Procedure

### Step 1: Verify Stage Completion
Check `workflow-state.yaml`:
- Every stage in `stage_order` is marked `complete`
- No stage is `blocked` without a recorded human decision
- No stage is `pending` or `in_progress`

If any stage is not complete, STOP — do not proceed to closure. The incomplete stage must be executed or unblocked first.

### Step 2: Verify Required Outputs Exist
Confirm all files listed in `contract.yaml` required outputs exist and are well-formed:
- Check file existence for every artifact
- Verify YAML files parse without errors (structural check, not full validation)
- Verify the paper document has been modified (if patches were applied)

### Step 3: Verify Patch Traceability
Cross-check `patch-trace.yaml` against `document-diff.yaml`:
- Every patch in patch-trace has corresponding diff entries
- Every diff entry belongs to a patch
- The traceability chain is complete: critique → disposition → revision decision → patch → diff

### Step 4: Run Validator Pipeline
Run validators in order:

#### Engine Validators
1. Project validator: `cr-validate-project`
2. Document registry validator: (`cr-validate-document-registry` if it exists)
3. Round contract validator: `cr-validate-round-contract`
4. Workflow state validator: (`cr-validate-workflow-state` if it exists)
5. Single mutable document validator: `cr-validate-single-mutable-document`
6. Target units validator: `cr-validate-paper-units`
7. Patch trace validator: (`cr-validate-patch-trace` if it exists)
8. Document diff validator: `cr-validate-writing-diff`
9. Knowledge delta validator: (`cr-validate-knowledge-delta` if it exists)

#### Workflow-Specific Validators
10. Paper patch validator: `cr-validate-paper-patch`
11. Paper claims validator: `cr-validate-paper-claims`
12. Paper evidence alignment validator: `cr-validate-paper-evidence-alignment`
13. Claim evidence validator: `cr-validate-claim-evidence`

If any validator fails, read the failure output, identify the root cause, and fix the source artifact. Do not attempt to "close anyway."

### Step 5: Generate Next-Round Targets
Identify work that belongs in future rounds:
- Deferred critiques from `revision-plan.yaml` dispositions
- Issues found in `claim-alignment.yaml` that couldn't be fixed in this round
- Cross-document implications: paper changes that imply design-doc or survey changes
- Evaluation obligations from `claim-evidence-grounding.yaml` that remain unaddressed
- Knowledge gaps discovered during this round

For each candidate, produce a `next-round-targets.yaml` entry with:
- Target document and units
- Objective (one sentence)
- Priority (high, medium, low)
- Rationale (why this needs a follow-up round)

### Step 6: Produce Closure Summary
Prepare the data `cr round close` will use:
- Round objective: was it achieved?
- Key changes: what was modified in the paper?
- Critiques addressed: how many fatal, major, minor critiques were resolved?
- Claims changed: how many strengthened, weakened, dropped, added?
- Knowledge gained: key insight from the knowledge delta
- Next-round candidates: what should the next round address?

### Step 7: Close the Round
Run `cr round close`. If it fails, fix the failing validator and retry. Do not manually mark the round as closed.

## Output Contract

```yaml
next-round-targets.yaml:
  schema_version: "1.0.0"
  round_id: integer
  targets:
    - document: string               # "paper", "design-doc", "survey", "proposal"
      units: [string]                # specific units to target
      objective: string              # one sentence: what to accomplish
      priority: high | medium | low
      rationale: string              # why this needs a follow-up round
      source: string                 # critique ID, alignment issue, or evaluation obligation
```

## Quality Gates

- [ ] All stages in `workflow-state.yaml` are `complete`
- [ ] All required outputs from `contract.yaml` exist on disk
- [ ] All engine validators pass
- [ ] All workflow-specific validators pass
- [ ] `next-round-targets.yaml` exists (even if empty — an empty targets list is valid)
- [ ] No blocker without a recorded human decision
- [ ] `cr round close` succeeds

## Failure Conditions

- A validator fails and cannot be fixed without re-executing a prior stage — STOP; re-execute the stage
- A blocker is unresolved — STOP; the human decision must be recorded before closure
- A required output is missing — STOP; the stage that produces it is incomplete
- The paper document was not modified despite patches being planned — STOP; stage 7 did not execute properly
- `cr round close` fails after three retries with different root causes — STOP; record as unrecoverable

## Forbidden Behavior

- Do not skip validators — every validator in the pipeline must pass
- Do not close a round manually if `cr round close` fails — fix the issue and retry
- Do not modify stage output artifacts during closure — if an artifact is wrong, re-execute the source stage
- Do not suppress validator errors with workarounds — fix the root cause
- Do not mark a round as closed if any blocker is unresolved

## Advance Rule

None — this is the final stage. After `cr round close` succeeds, the round is complete.
