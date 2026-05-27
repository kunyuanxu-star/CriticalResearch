# Stage 4: Design Critical Review
# Critically review the design for correctness, completeness, and feasibility.

## Inputs
- `design-state.yaml`
- `evidence-grounding.yaml`
- Target design-doc

## Task
Produce `critical-review.yaml`:

1. **Architecture critique**:
   - Are component boundaries clean? (Minimal coupling, clear responsibilities)
   - Are there circular dependencies?
   - Is the layering sensible?

2. **Invariant critique**:
   - Are invariants enforceable at runtime? (Not just aspirational)
   - Are there conflicting invariants?
   - Are invariants testable?

3. **Interface critique**:
   - Are interface semantics stable under concurrent access?
   - Are error cases defined?
   - Is resource ownership explicit?

4. **Lifecycle critique**:
   - Are state transitions complete?
   - Are there deadlock or livelock scenarios?
   - Is resource cleanup guaranteed?

5. **Failure model critique**:
   - What happens when a component fails?
   - Is the failure model explicit?
   - Are cascading failures prevented?

6. **Implementation feasibility**:
   - Can this be implemented within project constraints?
   - Are there unvalidated assumptions?
   - What's the implementation risk?
