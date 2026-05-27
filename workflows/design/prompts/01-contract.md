# Stage 1: Contract
# Establish the design round's scope. Design rounds modify exactly one
# design-doc and target specific architecture units.

## Inputs
- `engine/core/transaction-rules.md` — structural constraints
- `workflows/design/workflow.yaml` — design workflow definition
- `project.yaml` — project identity
- `documents/registry.yaml` — all documents
- `units/<target>.units.yaml` — design unit boundaries
- User's objective

## Task
Produce `contract.yaml` with workflow `id: design`, mutable document of type `design-doc`,
and target design units (design-principle, architecture-component, mechanism-design units).

## Constraints
- Only one design-doc can be modified.
- Design rounds frequently read paper and survey as context but must not modify them.
- If design changes imply paper rewrites, record next_round_candidates.
