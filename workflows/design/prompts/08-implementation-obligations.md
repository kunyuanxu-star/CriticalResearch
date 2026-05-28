# Stage 8: Implementation Obligations
# Extract implementation obligations from design changes.

## Inputs
- All patches
- `critical-review.yaml`
- `contract.yaml`


## Outputs
- `implementation-obligations.yaml` — per-decision implementation requirements, test cases, invariants, and cross-patch tracing

## Task
Produce `implementation-obligations.yaml`:
- For each design decision that has implementation implications:
  - What must be implemented? (Specific modules, types, functions)
  - What test must pass? (Specific test cases)
  - What invariant must hold? (Runtime checks, compile-time guarantees)
  - Priority: blocking vs. nice-to-have
- Cross-reference to design patches (which patch created this obligation)
- Track obligations across rounds — don't lose them
