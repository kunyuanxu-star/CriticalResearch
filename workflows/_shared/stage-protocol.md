# Stage Execution Protocol

This is a shared execution-discipline document referenced by stage prompts across all workflows. It defines the mechanical rules for stage execution — not what a stage does, but how it operates within the round harness.

## Core Protocol

Every stage MUST follow this sequence:

### 1. Load Round State
Read `contract.yaml` first. Identify:
- `workflow_id` — confirms which workflow is active
- `mutable_document` — the single document this round may modify
- `target_units` — specific units within the mutable document targeted this round
- `read_only_context` — documents accessible for reference only

Read `workflow-state.yaml` to confirm `current_stage`. The stage name in workflow-state MUST match the stage this prompt defines. If the stage is already marked `complete`, do not re-execute — signal this fact and advance.

### 2. Load Required Inputs
Read every file listed in the stage prompt's Required Inputs section. Do not skip any. If a required input file is missing or malformed, STOP — do not fabricate content to proceed.

### 3. Execute the Stage
Follow the Required Procedure steps exactly. Do not add steps not listed. Do not skip listed steps.

### 4. Write Only Allowed Outputs
Write ONLY to files listed in Allowed Writes. Writing to any other file — including read-only context documents, other document types, project-level config, or knowledge cards that are not explicitly allowed — is a protocol violation.

### 5. Validate Before Advance
Run every gate in Quality Gates before advancing. A gate that fails means the stage is incomplete — fix the output artifact, then re-check.

If any Failure Condition is met, STOP. Record a blocker in the workflow state. Do not fabricate content to bypass a failure condition.

### 6. Advance
Only after ALL quality gates pass: run `cr stage advance`. Never advance a stage that has not been fully executed.

## Stage State Machine

Each stage exists in one of these states:
- `pending` — not yet started
- `in_progress` — currently executing
- `complete` — all quality gates passed, advanced
- `blocked` — a failure condition was met, human decision required

The harness enforces that stages execute in `stage_order` sequence. Skipping stages is NEVER permitted. Executing a stage out of order is NEVER permitted.

## Read-Only Context

Documents in `read_only_context` MAY be read for reference. They MUST NOT receive writes under any circumstances. If the stage discovers that a change to a read-only document is needed, record it as a `next_round_candidate` in the output artifact — do not modify the document.

## Cross-Workflow Discipline

A round enters exactly one workflow. Do not apply another workflow's rubric, patch types, or validators. The current workflow's `workflow.yaml` is authoritative for all stage prompts, schemas, validators, and patch types.

## Unit Anchors

When modifying the mutable document, changes MUST be constrained to the declared target units. Do not modify text outside unit boundaries unless:
- The unit definition itself needs adjustment (record as a unit-registry change)
- The change is a structural operation (section reorder, section rename) that spans unit boundaries — in which case, document every affected unit explicitly in the patch trace

## Error Recovery

If a tool failure prevents stage completion:
1. Re-read required inputs to ensure they haven't changed
2. Re-execute the failed procedure step
3. If the same failure recurs, record it as a blocker — do not retry indefinitely

Never fabricate outputs when inputs are missing or tools fail. A blocked stage with a clear diagnosis is correct. A completed stage with fabricated content is a silent failure.
