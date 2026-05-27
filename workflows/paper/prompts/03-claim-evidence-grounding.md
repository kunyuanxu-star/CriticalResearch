# Stage 3: Claim-Evidence Grounding
# Map every claim to its supporting evidence.

## Inputs
- `paper-state.yaml`
- Project knowledge — claims, evidence, survey findings
- `contract.yaml` — read-only context

## Task
Produce `claim-evidence-grounding.yaml`:
- For every claim in the paper: what evidence supports it?
- Evidence types: measurement, proof, prior work citation, logical argument
- Evidence strength: strong (direct measurement), moderate (cited prior work), weak (logical argument only)
- Gaps: claims without evidence — flag as high risk
- Overclaimed: claims that go beyond what evidence supports
