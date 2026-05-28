---
description: "Start enforced workflow-specific CriticalResearch round"
argument-hint: "<project> --workflow <id> --doc <id> [--unit <id>] <objective>"
allowed-tools:
  - "Bash(cr-round:*)"
  - "Bash(cr stage:*)"
  - "Bash(cr round close:*)"
  - "Bash(cr-validate-stage:*)"
  - "Read"
  - "Write"
  - "Edit"
  - "MultiEdit"
  - "Grep"
  - "Glob"
  - "Task"
  - "AskUserQuestion"
---

# /critical-cs-research

Start a new workflow-specific research round for a CriticalResearch project.

## Usage

```
/critical-cs-research <project> --workflow <id> --doc <doc-id> [--unit <unit-id>] <objective>
```

## Arguments

- `project`: Existing project ID in the workspace. Must have at least one document in `documents/`.
- `--workflow`: Workflow to use (survey, design, paper, proposal, experiment). Required.
- `--doc`: Document ID to target (survey, design-doc, paper, proposal, experiment-plan). Required.
- `--unit`: Unit ID within the target document to focus on (e.g., `survey.sandboxed-containers`). Optional.
- `objective`: A concise description of what this round should focus on.

## Execution Contract

Parse arguments as:

```
PROJECT=<first token>
--workflow <workflow-id>
--doc <doc-id>
--unit <unit-id> (optional)
<objective> (remaining text)
```

Run exactly:

```bash
cr round start "$PROJECT" --workflow "$WORKFLOW" --doc "$DOC" ${UNIT:+--unit "$UNIT"} --mode deep --objective "$OBJECTIVE"
cr stage status "$PROJECT"
```

Then execute the current stage. Do not summarize completion until `cr round close "$PROJECT"` succeeds.

## Invariants (must not be violated)

- **This command must never bypass `cr round start`.** No direct state.yaml edits. No manual round directory creation.
- **You must not stop until `cr round close <project>` succeeds.** The Stop hook will block incomplete rounds.
- **You must execute the workflow-specific stage order.** No skipping. No jumping forward.
- **Each stage must be validated before advancing.** Do not mark stages complete manually.

## Typical session flow

```
/critical-cs-research my-project --workflow survey --doc survey --unit survey.sandboxed-containers "Research sandboxed containers"
# Stage 1: contract — generate round-contract.yaml
# Stage 2: survey_state — capture current survey snapshot
# Stage 3: research_planning — plan evidence search
# Stage 4: source_analysis — execute search, collect evidence
# Stage 5: taxonomy_synthesis — build/refine taxonomy
# Stage 6: critical_review — generate critique-ledger.yaml and review-disposition.yaml
# Stage 7: revision_plan — generate revision-plan.yaml
# Stage 8: apply_survey_patch — apply patches, generate patch-trace.yaml and document-diff.yaml
# Stage 9: knowledge_delta — generate knowledge-delta.yaml
# Stage 10: closure — generate next-round-targets.yaml, close round
cr round close my-project
```

## See also

- `cr stage status <project>` — Show current stage progress
- `cr stage advance <project>` — Validate current stage and move to next
- `cr round close <project>` — Close the round (all workflow stages must be complete)
