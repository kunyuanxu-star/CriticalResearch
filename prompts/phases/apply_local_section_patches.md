# Phase: apply_local_section_patches

## Mission
Apply patches to the paper draft according to the writing plan. Record every change in writing-diff.yaml with before/after text, section_anchor, and patch_id. Update patch lifecycle from proposed to applied.

## Inputs
- `writing-plan.yaml`
- `patches/PP-*.yaml`
- `writing/paper-draft.md`

## Outputs
- `writing-diff.yaml` (recording all changes)
- Updated `writing/paper-draft.md`

## Allowed Actions
- Read writing plan, patches, and current draft.
- Apply patches to draft sections.
- Record each change with before/after text and patch_id.
- Update patch lifecycle_status from proposed to applied.

## Forbidden Actions
- Do not add new evidence or claims not in patches.
- Do not edit do_not_touch_sections.
- Do not generate new critique.
- Do not create untracked edits.
- Do not modify unchanged sections.

## Procedure
1. Apply patches in patch_order sequence.
2. For each patch, locate the section_anchor in the draft.
3. Replace before_text_or_anchor with after_text_or_structural_change.
4. Record the change in writing-diff.yaml with before_text, after_text, section_anchor, patch_id.
5. Verify after_text != before_text (actual change occurred).
6. Update patch lifecycle to applied.
7. Ensure draft is >100 bytes after all changes.

## Output Contract
```yaml
writing-diff.yaml changes[*]:
  patch_id, section_anchor, before_text (>=10 chars), after_text (>=10 chars, !=before_text), status: applied
```
Paper draft must be >100 bytes.

## Failure Conditions
- Any applied patch has no corresponding writing-diff entry.
- Any change has before_text == after_text.
- Draft <100 bytes after changes.
- A do_not_touch section was modified.

## Handoff
validate_patch_application will verify every patch landed correctly.
