# /critical-cs-research

Start a new 37-phase paper research round for a CriticalResearch project.

## Usage

```
/critical-cs-research <project> <objective>
```

## Arguments

- `project`: Existing project ID in the workspace. Must have `writing/paper-draft.md`.
- `objective`: A concise description of what this round should focus on (e.g. "检查 introduction 的 claim 精度、related work 的 baseline 覆盖、evaluation contract 的完整性").

## What it does

1. Calls `cr-start-paper-round <project> "<objective>"` — the **only** valid entry point for paper rounds.
2. Calls `cr step <project> status` to show the current phase and required outputs.
3. Outputs the Phase 1 prompt and asks you to begin execution.

## Invariants (must not be violated)

- **This command must never bypass `cr-start-paper-round`.** No direct state.yaml edits. No manual round directory creation. No calling `cr-new-round --mode paper`.
- **You must not stop until `cr close-round <project>` succeeds.** The Stop hook will block incomplete rounds.
- **You must execute all 37 phases in order.** No skipping. No jumping forward.
- **Each phase must be validated by `cr-complete-phase` before advancing.** Do not mark phases complete manually.
- **Module reviews (M0-M7) must pass before entering the next module.**

## Typical session flow

```
/critical-cs-research my-paper "检查 introduction 和 evaluation"
# Phase 1: snapshot_paper_state — 生成 paper-state.yaml
# Phase 2: load_project_knowledge — 加载知识库
...
# Phase 37: close_round — 生成 closure-report.yaml
cr close-round my-paper
```

## See also

- `cr step <project> status` — Show current phase progress
- `cr step <project> advance` — Validate current phase and move to next
- `cr review-module <project> M<N>` — Generate module review checkpoint
- `cr close-round <project>` — Close the round (37 phases must be complete)
