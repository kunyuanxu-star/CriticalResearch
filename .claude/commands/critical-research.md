---
description: "Run the CriticalResearch thesis repair loop"
argument-hint: "<project> [--mode quick|standard|deep] [--debug] <objective>"
allowed-tools:
  - "Bash(cr run:*)"
  - "Bash(cr status:*)"
  - "Bash(cr validate:*)"
  - "Bash(cr show:*)"
  - "Read"
  - "Write"
  - "Edit"
  - "MultiEdit"
  - "Grep"
  - "Glob"
  - "WebSearch"
  - "WebFetch"
  - "Task"
---

# /critical-research

Run a CriticalResearch thesis-centered research loop.

## Usage

```text
/critical-research <project> [--mode quick|standard|deep] [--debug] <objective>
```

## Execution

1. Parse `project`, optional `--mode`, optional `--debug`, and remaining `objective`.
2. Run:

```bash
cr run "$PROJECT" "$OBJECTIVE" --mode "$MODE" ${DEBUG:+--debug}
```

3. Read the created `runs/<run-id>/research.md`.
4. Execute the Thesis Repair Loop within the selected budget:
   - identify the weakest field;
   - simulate the configured roles internally;
   - write only final attacks and repairs;
   - repair the weakest field and directly dependent fields;
   - update frontmatter loop counts, validation counts, weakest link, status, and next action;
   - run `cr validate "$PROJECT" --run "$RUN"`.
5. Stop only with `complete`, `blocked`, `gated`, `budget_exhausted`, or `invalid`.

## Rules

- Maintain a thesis, not a process checklist.
- Do not create process-state files, registries, patch traces, or knowledge logs by default.
- Do not expose raw simulated transcripts.
- Do not continue looping because only minor attacks remain.
- Every non-invalid terminal state must include a concrete `next_action`.
