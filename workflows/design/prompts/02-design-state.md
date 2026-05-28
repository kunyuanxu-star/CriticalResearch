# Stage 2: Design State
# Assess current design — architecture, components, invariants, interfaces.

## Inputs
- `contract.yaml`
- Target design-doc — full text within unit anchors
- `units/<target>.units.yaml` — unit maturity
- Project knowledge — claims, design decisions

## Task
Produce `design-state.yaml`:
- Per-unit assessment: current architecture, invariants, interfaces, lifecycle, failure models
- Completeness: are all components documented? All interfaces specified?
- Invariant coverage: are invariants explicit and enforceable?
- Interface contracts: are semantics stable? Pre/post conditions documented?
- Gaps: missing components, underspecified interfaces, unhandled failure modes

## Outputs
- `design-state.yaml` — per-unit architecture assessment, invariant coverage, interface contracts, gaps
