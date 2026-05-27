---
description: "Start enforced 8-stage CriticalResearch paper transaction"
argument-hint: "<project> <objective>"
allowed-tools:
  - "Bash(cr-start-paper-round:*)"
  - "Bash(cr step:*)"
  - "Bash(cr close-round:*)"
  - "Bash(cr-validate-stage:*)"
  - "Bash(cr-validate-stage-run-log:*)"
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

Start a new 8-stage paper research round for a CriticalResearch project.

## Usage

```
/critical-cs-research <project> <objective>
```

## Arguments

- `project`: Existing project ID in the workspace. Must have `writing/paper-draft.md`.
- `objective`: A concise description of what this round should focus on.

## Execution Contract

Parse arguments as:

```
PROJECT=<first token>
OBJECTIVE=<remaining text>
```

Run exactly:

```bash
cr-start-paper-round "$PROJECT" "$OBJECTIVE"
cr step "$PROJECT" status
```

Then execute the current stage. Do not summarize completion until `cr close-round "$PROJECT"` succeeds.

## Invariants (must not be violated)

- **This command must never bypass `cr-start-paper-round`.** No direct state.yaml edits. No manual round directory creation.
- **You must not stop until `cr close-round <project>` succeeds.** The Stop hook will block incomplete rounds.
- **You must execute all 8 stages in order.** No skipping. No jumping forward.
- **Each stage must be validated by `cr-complete-stage` before advancing.** Do not mark stages complete manually.

## Typical session flow

```
/critical-cs-research my-paper "检查 introduction 和 evaluation"
# Stage 1: s1_round_contract — 生成 round-contract.yaml
# Stage 2: s2_evidence_grounding — 执行检索并生成 evidence-ledger.yaml
# Stage 3: s3_critical_review — 生成 critique-ledger.yaml 和 review-disposition.yaml
# Stage 4: s4_revision_strategy — 生成 revision-plan.yaml
# Stage 5: s5_writing_strategy — 生成 writing-plan.yaml 和 patch-plan.yaml
# Stage 6: s6_paper_patch — 应用补丁并生成 patch-trace.yaml
# Stage 7: s7_knowledge_consolidation — 生成 knowledge-delta.yaml
# Stage 8: s8_round_closure — 生成 next-round-targets.yaml
cr close-round my-paper
```

## See also

- `cr step <project> status` — Show current stage progress
- `cr step <project> advance` — Validate current stage and move to next
- `cr close-round <project>` — Close the round (8 stages must be complete)
