# Stage 3: Evidence Grounding
# Ground design decisions in evidence: survey findings, related work, prior art.

## Inputs
- `design-state.yaml` — current design assessment
- Project knowledge — claims, related work, survey findings
- `contract.yaml` — read-only context documents

## Task
Produce `evidence-grounding.yaml`:
- For each design decision: what evidence supports it?
- For each invariant: is it provable? Enforceable? What prior work uses similar invariants?
- For each interface: what alternatives were considered and rejected?
- Evidence gaps: design decisions made without evidence — flag these
- Baselines: what does the design do differently from existing systems?
