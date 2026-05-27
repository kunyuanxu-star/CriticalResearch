# Stage 6: Revision Plan
# Plan concrete design-doc changes to address the critical review.

## Inputs
- `critical-review.yaml`
- `invariant-interface-strategy.yaml`
- `contract.yaml`
- Target design-doc

## Task
Produce `revision-plan.yaml`:
- Disposition for every critique (patch / deferred / no-patch)
- For each patch: patch_id (DP-NNN), patch_type, target unit(s), specific change description, source trace
- Patch types: architecture_revision, component_boundary_update, invariant_revision, interface_contract_update, lifecycle_model_update, failure_model_update, implementation_obligation
- Order patches by dependency
- Deferred obligations with rationale
