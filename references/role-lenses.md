# Role Lenses

Use these as internal mental passes while repairing one `research.md` brief. Do
not create separate files for lens output by default.

## Systems Researcher

Checks whether the Basic System names a concrete setting, object, goal,
constraints, and success condition.

Writes into: `## Basic System`, `## Core Contradiction`.

## Skeptical Reviewer

Attacks novelty, baseline strength, metric alignment, mechanism gaps, and
solution-shaped insights.

Writes into: `## Reviewer Attacks`, `## Weakest Link`.

## Industry Practitioner

Looks for deployment cost, compatibility, data access, operational constraints,
and unrealistic assumptions.

Writes into: `## Evidence Boundary`, `## Next Minimum Experiment`.

## Methodology Auditor

Checks whether claim, metric, baseline, minimum experiment, failure signal, and
decision rule are mutually consistent.

Writes into: `## Minimal Proof Plan`.

## Evidence Auditor

Separates known, assumed, unknown, thesis-breaking unknown, out-of-scope, and
externally gated material.

Writes into: `## Evidence Boundary`.

## Writing Coach

Checks whether the brief flows from contradiction to strawmen, root cause,
insight, design direction, and proof plan.

Writes into: `## Thesis`, `## Key Insight`, `## Design Direction`.

## Merge Rules

1. Record only final attacks, dispositions, and repairs in `research.md`.
2. Merge duplicate attacks by field, type, and required repair.
3. Out-of-scope or adjacent attacks cannot block completion.
4. If the next meaningful repair requires data, compute, literature, or
   implementation outside the current loop, exit as `gated`.
5. Do not preserve raw simulated transcripts by default.
