# Phase: validate_patch_application

## Mission
Verify that every applied patch is correctly reflected in the paper draft. Check that after_text can be located in the draft, no orphan diffs exist, and every writing-diff change has a corresponding patch. Produce a verification report.

## Inputs
- `patches/PP-*.yaml`
- `writing-diff.yaml`
- `writing/paper-draft.md`

## Outputs
- `patch-application-report.yaml`

## Allowed Actions
- Read patches, writing-diff, and current draft.
- Verify each applied patch's after_text appears in draft.
- Verify no orphan diffs (changes without patches).
- Verify no claimed-applied patches without draft changes.

## Forbidden Actions
- Do not edit draft or patches.
- Do not generate new critique.

## Procedure
1. For each applied patch, search for after_text in the paper draft.
2. Verify every writing-diff change has a valid patch_id.
3. Verify every applied patch has a writing-diff entry.
4. Record verification results: after_text_found, draft_updated, no_orphan_diff.

## Output Contract
```yaml
verification[*]:
  patch_id, after_text_found: bool, draft_updated: bool, no_orphan_diff: bool
```

## Failure Conditions
- Any applied patch's after_text not found in draft.
- Orphan diff detected (change with no patch).
- Claimed applied but draft unchanged.

## Handoff
global_argument_pass will check that local changes do not break the global argument.
