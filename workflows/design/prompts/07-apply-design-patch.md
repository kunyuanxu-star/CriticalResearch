# Stage 7: Apply Design Patch
# Apply design-doc patches within unit anchors.

## Inputs
- `revision-plan.yaml`
- Target design-doc with unit anchors
- `units/<target>.units.yaml`

## Task
Generate and apply `patches/DP-NNN.yaml` with `design_payload`:
- `invariants_added` / `invariants_removed` / `invariants_revised`
- `interfaces_changed` — interface names modified
- `lifecycle_changes` — state transition changes
- `component_changes` — component boundary changes
- `failure_model_changes` — failure handling changes
- `text_changes` — within-unit content modifications

## Constraints
- Only modify within declared unit anchors.
- Never modify anchor comments.
- Record before/after snippets.
- Update next_round_candidates if design changes imply other doc changes.
