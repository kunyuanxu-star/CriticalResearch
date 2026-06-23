# CriticalResearch

CriticalResearch is a thesis-centered research loop engine. It turns a vague
research objective into a defensible `research.md` brief by repeatedly asking:

1. What is the current thesis?
2. What is its weakest link?
3. What is the next minimum action that reduces the largest uncertainty?

CriticalResearch uses one default artifact per run and no visible process table.

## Install

```bash
bash install.sh
```

Requirements: Bash, Git, Python 3, and PyYAML.

## Quick Start

```bash
cr workspace init
cr project init edge-cache --domain systems
cr run edge-cache "Can we design a cache invalidation strategy for edge deployments with intermittent connectivity?"
cr status edge-cache
cr show edge-cache
cr validate edge-cache
```

Default run output:

```text
edge-cache/
  project.yaml
  documents/
  knowledge/
  runs/
    run-001/
      research.md
```

`trace.jsonl` is created only with `--debug`.

## Commands

```bash
cr workspace init
cr project init <id> --domain <domain>
cr run <project> "objective" [--mode quick|standard|deep] [--debug]
cr status <project> [--field status|latest_run|weakest_link]
cr show <project> [--run run-001]
cr validate <project> [--run run-001] [--json] [--strict]
```

Modes:

- `quick`: 1 loop, skeptical reviewer plus writing coach.
- `standard`: 3 loops, systems researcher, skeptical reviewer, industry practitioner, writing coach.
- `deep`: 5 loops, standard roles plus methodology auditor and evidence skeptic.

## Research Brief

Each run centers on one file:

```text
<project>/runs/<run-id>/research.md
```

The file has YAML frontmatter for machine state and fixed Markdown headings for
human reading:

```markdown
---
schema_version: "1.0.0"
project_id: "edge-cache"
run_id: "run-001"
status: "complete"
mode: "standard"
weakest_link: "proof_plan"
next_action: "Run a minimum experiment against TTL and gossip baselines."
---

# Research Brief

## Thesis
## Basic System
## Core Contradiction
## Strawmen and Root Cause
## Key Insight
## Design Direction
## Minimal Proof Plan
## Reviewer Attacks
## Evidence Boundary
## Weakest Link
## Next Minimum Experiment
```

The body can be written in English or Chinese. Headings and frontmatter keys
remain stable so the validator can inspect the brief.

## Loop Model

The agent maintains a Thesis Repair Loop:

```text
One loop = identify and repair the single weakest part of the current thesis.
```

The loop combines:

- Humanize-style discipline: bounded loops, terminal states, convergence checks.
- STORM-style simulation: multiple perspectives attack the thesis internally.
- CriticalResearch reasoning: basic system, contradiction, strawmen, root cause,
  single insight, proof plan, evidence boundary.

Completion means the brief is actionable, not unattackable.

## Validation

`cr validate` checks the minimum research closure:

- thesis has a one-sentence claim;
- Basic System defines setting, object, and goal;
- Core Contradiction has need, but, and therefore;
- at least two strawmen have concrete failure modes;
- shared root cause and key insight exist;
- Minimal Proof Plan has metric, baseline, minimum experiment, and decision rule;
- Evidence Boundary has known, assumed, and unknown;
- Next Minimum Experiment has action and decision rule.

Exit codes:

```text
0 = valid
1 = valid with warnings
2 = invalid
```

Terminal statuses are `complete`, `blocked`, `gated`, `budget_exhausted`, and
`invalid`.

## Current Model

Use `cr run`, `cr status`, and `cr validate`. Unsupported process-management
commands print replacement guidance.
