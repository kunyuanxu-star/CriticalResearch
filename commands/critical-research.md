---
description: "Run the CriticalResearch thesis repair loop"
argument-hint: "<project> [--mode quick|standard|deep] [--debug] [--autonomous] <objective>"
allowed-tools:
  - "Bash(cr run:*)"
  - "Bash(cr status:*)"
  - "Bash(cr validate:*)"
  - "Bash(cr show:*)"
  - "Bash(cr progress:*)"
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
/critical-research <project> [--mode quick|standard|deep] [--debug] [--autonomous] <objective>
```

## Execution

1. Parse `project`, optional `--mode`, optional `--debug`, optional `--autonomous`, and remaining `objective`.
2. Run:

```bash
cr run "$PROJECT" "$OBJECTIVE" --mode "$MODE" ${DEBUG:+--debug} ${AUTONOMOUS:+--autonomous}
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

## Execution Contract

### Required Inputs

- `project`: existing CriticalResearch project id.
- `objective`: non-empty research objective.
- `mode`: `quick`, `standard`, or `deep`; default to `standard`.
- `autonomous`: optional long-run supervision state; default off.
- `<project>/project.yaml`.
- The newly created or selected `<project>/runs/<run-id>/research.md`.

### Allowed Writes

- `<project>/project.yaml`, only through `cr run` metadata updates.
- `<project>/runs/<run-id>/research.md`.
- `<project>/runs/<run-id>/trace.jsonl`, only when `--debug` is requested.
- `<project>/runs/<run-id>/state/*` and `<project>/runs/<run-id>/logs/*`, only when `--autonomous` is requested.

Do not write process-state files, registries, patch traces, knowledge logs, or raw simulated transcripts by default.

### Required Outputs

- `research.md` with stable frontmatter and all required Markdown sections.
- Terminal `status`: `complete`, `blocked`, `gated`, `budget_exhausted`, or `invalid`.
- Updated `loop_count`, `weakest_link`, `validation`, `convergence`, and `next_action`.
- Reviewer attacks that name role, field, severity, scope, argument, required repair, and disposition.
- Evidence boundary that separates known, assumed, unknown, thesis-breaking unknown, and out-of-scope material.

### Quality Gates

- Run `cr validate "$PROJECT" --run "$RUN"` before stopping.
- `complete` requires validator exit `0`.
- `blocked`, `gated`, and `budget_exhausted` may stop with validator warnings only when their terminal allowance conditions are explicit in `research.md`.
- Do not continue only because minor or out-of-scope attacks remain.
- Do not count word count, extra detail, or raw critique volume as progress.

### Traceability

- Every repair must be tied to the current `weakest_link`.
- Every reviewer attack must target a concrete field in `research.md`.
- Every accepted risk, deferred item, or external evidence need must appear in Reviewer Attacks, Evidence Boundary, Weakest Link, or Next Minimum Experiment.
- Debug trace must contain only decision summaries and validation deltas, never raw chain-of-thought.

## Rules

- Maintain a thesis, not a process checklist.
- Do not create process-state files, registries, patch traces, or knowledge logs by default.
- Do not expose raw simulated transcripts.
- Do not continue looping because only minor attacks remain.
- Every non-invalid terminal state must include a concrete `next_action`.
