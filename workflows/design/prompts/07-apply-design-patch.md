# Stage 7: Apply Design Patch
# Apply design-doc patches within unit anchors.

## Inputs
- `revision-plan.yaml`
- `design-state.yaml`
- Target design-doc with unit anchors
- `units/<target>.units.yaml`

## Task
Apply design-doc patches from the revision plan. For each patch:
- Generate `patches/DP-NNN.yaml` with `design_payload`
- Record before/after snippets for every change
- Produce `patch-trace.yaml` linking each patch to its critique and revision decision
- Produce `document-diff.yaml` with all changes mapped to patch IDs

### design_payload fields:
- `invariants_added` / `invariants_removed` / `invariants_revised`
- `interfaces_changed` — interface names modified
- `lifecycle_changes` — state transition changes
- `component_changes` — component boundary changes
- `failure_model_changes` — failure handling changes
- `text_changes` — within-unit content modifications

## Outputs
- `patches/DP-NNN.yaml` — individual patch files with design payload
- `document-diff.yaml` — structured diff of all changes
- `patch-trace.yaml` — traceability matrix: patch_id → critique_id → status

## Output Contract

```yaml
document-diff.yaml:
  schema_version: "1.0.0"
  diffs:
    - patch_id: string
      unit_anchor: string
      before_text: string (>= 10 chars)
      after_text: string (>= 10 chars, != before_text)
      status: applied

patch-trace.yaml:
  schema_version: "1.0.0"
  patches:
    - patch_id: string
      critique_id: string
      revision_decision: string
      status: planned | applied | validated | rejected | blocked
      validation_notes: string
```

## Constraints
- Only modify within declared unit anchors.
- Never modify anchor comments.
- Record before/after snippets for every change.
- Update next_round_candidates if design changes imply other doc changes.

## Failure Conditions
- Any patch applied without a document-diff entry.
- Any change has before_text == after_text.
- Any patch missing traceability in patch-trace.yaml.
- Any modification outside declared unit anchors.
