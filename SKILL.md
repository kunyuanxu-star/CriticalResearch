---
name: critical-research
description: Thesis-centered research loop engine for turning research ideas into defensible briefs through multi-perspective critique, weakest-link repair, and minimal proof planning.
---

# CriticalResearch

You maintain a research thesis, not a process checklist.

Primary artifact:

```text
<project>/runs/<run-id>/research.md
```

Primary command:

```bash
cr run <project> "objective" --mode standard
```

## Operating Model

Each run is a Thesis Repair Loop:

1. Read `research.md`.
2. Identify the single weakest field.
3. Simulate role attacks internally.
4. Classify attacks by field, severity, and scope.
5. Repair only the weakest field and directly dependent fields.
6. Update frontmatter.
7. Run `cr validate`.
8. Stop only at `complete`, `blocked`, `gated`, `budget_exhausted`, or `invalid`.

Do not expose raw simulated transcripts by default. Expose only final attacks,
repairs, evidence boundaries, and next action.

## Execution Contract

Required inputs:

- `research.md` for the active run.
- `project.yaml` for project metadata.
- User objective and selected mode.

Allowed writes:

- The active run's `research.md`.
- `trace.jsonl` only when debug tracing is explicitly enabled.
- Project metadata only through `cr run` and CLI-managed updates.

Required outputs:

- A terminal run state: `complete`, `blocked`, `gated`, `budget_exhausted`, or `invalid`.
- A concrete `next_action` for every non-invalid terminal state.
- Reviewer Attacks, Evidence Boundary, Weakest Link, and Next Minimum Experiment sections that agree with the frontmatter.

Quality gates:

- Run `cr validate` before stopping.
- Treat validator errors as blocking unless the terminal status is explicitly allowed by the validator.
- Do not treat warning text as success in strict review contexts; use `cr validate --strict` when warnings should block.

Traceability:

- Link each repair to one weakest link.
- Link attacks and dispositions to specific brief fields.
- Store only summaries and validation deltas in debug traces; do not store raw simulated transcripts or chain-of-thought.

## Research Standards

Start from contradiction, not implementation.

A strong research thesis should identify:

- the concrete setting;
- the core object;
- the goal;
- the properties that must hold together;
- why existing assumptions or abstractions fail;
- two or more strawmen with concrete failure modes;
- the shared root cause;
- one key insight that changes the problem organization;
- a minimal proof plan with metric, baseline, minimum experiment, and decision rule.

Bad contradiction:

```text
Users need faster scheduling.
```

Better contradiction:

```text
The system needs global coordination to preserve isolation, but the deployment
only permits local and stale observations.
```

Bad gap:

```text
No one has used LLMs for this problem.
```

Better gap:

```text
Existing methods assume stable task boundaries, but the target setting has
drifting boundaries, causing static policies and retraining to fail in different
ways.
```

Bad insight:

```text
Use a graph model.
```

Better insight:

```text
The failure is not representation capacity but boundary instability; modeling
boundary drift directly turns recovery latency into the primary measurable
property.
```

## Simulated Roles

Use these roles internally:

- `systems_researcher`: setting, object, goal, abstractions.
- `skeptical_reviewer`: novelty, baseline, metric, insight.
- `industry_practitioner`: deployment, compatibility, cost, data access.
- `methodology_auditor`: proof plan, baseline, ablation, decision rule.
- `evidence_skeptic`: known, assumed, unknown, thesis-breaking unknown.
- `writing_coach`: argument flow from contradiction to root cause to insight.

Mode role sets:

- `quick`: skeptical reviewer, writing coach.
- `standard`: systems researcher, skeptical reviewer, industry practitioner, writing coach.
- `deep`: all roles.

## Stop Conditions

Stop with:

- `complete` when the brief is actionable and passes `cr validate`;
- `blocked` when a user decision or scope definition is required;
- `gated` when external evidence, data, compute, literature, or implementation is required;
- `budget_exhausted` when the loop budget is used and the brief has a concrete next action;
- `invalid` only when the file cannot be repaired.

Do not continue looping because minor attacks remain. Completion means actionable,
not unattackable.

## Prohibited Default Artifacts

Do not create default process-state files, registries, patch traces, or
knowledge logs. Use one default artifact: `research.md`. Only write
`trace.jsonl` when `--debug` is requested.
