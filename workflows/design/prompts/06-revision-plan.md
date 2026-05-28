# Stage 6: Revision Plan
# Plan concrete design-doc changes to address the critical review.

## Inputs
- `critical-review.yaml`
- `invariant-interface-strategy.yaml`
- `contract.yaml`
- Target design-doc

## Task
Produce `revision-plan.yaml` and `patch-plan.yaml`:
- Disposition for every critique (patch / deferred / no-patch)
- For each patch: patch_id (DP-NNN), patch_type, target unit(s), specific change description, source trace
- Patch types: architecture_revision, component_boundary_update, invariant_revision, interface_contract_update, lifecycle_model_update, failure_model_update, implementation_obligation
- Order patches by dependency
- Deferred obligations with rationale

## Outputs
- `revision-plan.yaml` — full revision plan with dispositions, patch ordering, and deferred obligations
- `patch-plan.yaml` — executable patch plan with patch IDs, types, target units, dependency graph, pre/postconditions

## Output Contract

```yaml
revision-plan.yaml:
  schema_version: "1.0.0"
  dispositions:
    - disposition_id: string
      critique_id: string
      disposition: patch | deferred | no-patch
      rationale: string
      patch_ids: [string]
  patch_order:
    - patch_id: string
  patches:
    - patch_id: string
      patch_type: architecture_revision | component_boundary_update | invariant_revision | interface_contract_update | lifecycle_model_update | failure_model_update | implementation_obligation
      target_units: [string]
      description: string (>= 20 chars)
      source_critiques: [string]
      dependencies: [string]
      preconditions: [string]
      postconditions: [string]

patch-plan.yaml:
  schema_version: "1.0.0"
  patches:
    - patch_id: string
      patch_type: string
      order: integer
      dependencies: [string]
      target_units: [string]
      operation: string
      preconditions: [string]
      postconditions: [string]
```

## Failure Conditions
- Any critique left without disposition.
- Patch dependency graph has cycles.
- Any patch has no source_critiques.
- Any accepted critique has no corresponding patch.
