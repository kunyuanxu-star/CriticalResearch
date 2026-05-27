# Stage 1: Contract
# Paper round: establish scope for one paper document and target sections.

## Inputs
- `engine/core/transaction-rules.md`
- `workflows/paper/workflow.yaml`
- `project.yaml`, `documents/registry.yaml`, `units/<paper>.units.yaml`
- User's objective

## Task
Produce `contract.yaml` with workflow `id: paper`, one `paper`-type mutable document,
and specific paper-section units to target.

## Constraints
- Only the paper document is mutable.
- Design-doc and survey may be read but never modified.
- If paper changes imply design changes, record next_round_candidates.
