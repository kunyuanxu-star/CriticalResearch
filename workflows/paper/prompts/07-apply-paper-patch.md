# Stage 7: Apply Paper Patch

## Purpose

Apply the revision plan from stage 6 to the paper document. Each patch modifies the paper within declared unit anchors. Every modification must produce a corresponding entry in `patch-trace.yaml` and `document-diff.yaml`. This is the only stage that writes to the mutable document — all other stages produce analysis or planning artifacts.

This stage must NOT:
- Introduce changes not in the revision plan
- Modify text outside declared unit boundaries (unless the patch is a structural operation spanning boundaries — and even then, document every affected unit)
- Apply patches out of dependency order
- Skip the patch trace or document diff for any applied change

## Stage Type

patching

## Required Inputs

- `revision-plan.yaml` — ordered patch list with dependencies, types, target units, expected effects
- `patch-plan.yaml` — detailed patch instructions: operations, anchors, content guidance
- `contract.yaml` — target units, mutable document declaration
- `workflows/paper/schemas/paper-patch.schema.json` — patch payload schema
- `workflows/paper/profile.md` — paper workflow semantics, writing quality standards
- `workflows/_shared/stage-protocol.md` — stage execution discipline
- `workflows/_shared/patch-discipline.md` — patch traceability and diff rules
- The target paper document — read the sections relevant to each patch before applying

## Allowed Writes

- The target paper document — ONLY within declared unit boundaries
- `patch-trace.yaml` — traceability chain for every applied patch
- `document-diff.yaml` — before/after diff for every text change

## Required Procedure

### Step 1: Load Revision Plan and Validate
Read `revision-plan.yaml` to get the ordered patch list. Read `patch-plan.yaml` for detailed instructions. Confirm:
- Patch order respects dependencies
- All target units exist in the contract and unit registry
- All patch types are valid per `workflow.yaml`

### Step 2: Read Target Sections
For each patch, read the relevant sections of the paper document before applying changes. Note the exact current text. This becomes the "before" in `document-diff.yaml`.

### Step 3: Apply Patches in Order
For each patch in dependency order:

#### For paragraph_rewrite patches:
- Locate the target paragraph within the unit
- Replace the paragraph text with the revised version
- The revised text must achieve the `expected_effect` from the revision plan
- Use the `content_guidance` from `patch-plan.yaml` as direction, not as exact text — the actual rewrite must be complete and publication-quality

#### For section_restructure patches:
- Reorder, split, or merge sections as specified
- If splitting: create new section boundaries, preserving existing content
- If merging: combine sections, eliminating redundancy
- If reordering: move sections, updating cross-references

#### For claim_weakening patches:
- Locate the exact claim text in the paper
- Replace with the weakened version from `writing-strategy.yaml` claim_strategy
- Ensure the weakened claim matches the evidence scope from `claim-evidence-grounding.yaml`

#### For claim_strengthening patches:
- Locate the exact claim text
- Replace with the strengthened version
- ONLY apply if the claim has `evidence_strength: strong` or `moderate` in `claim-evidence-grounding.yaml`
- If evidence doesn't support strengthening, downgrade the patch to claim_weakening or record a blocker

#### For related_work_repositioning patches:
- Modify the related work discussion to frame prior work per the positioning strategy
- Ensure comparisons are fair and specific — name the work, state the difference

#### For evaluation_obligation_addition patches:
- Add explicit evaluation requirements to the paper
- Place in the appropriate section (evaluation, discussion, or future work)
- Phrase as obligations the paper acknowledges, not as things the paper claims to have done

#### For contribution_rewrite patches:
- Rewrite the contribution statement per `writing-strategy.yaml` positioning_strategy
- The new contribution statement must be: one sentence, specific, distinguishable from prior work

### Step 4: Record Patch Trace
For every applied patch, create an entry in `patch-trace.yaml`:
- Patch ID
- Source critique(s)
- Disposition
- Target units
- Patch type
- Expected effect
- Reference to the corresponding diff entry

### Step 5: Record Document Diff
For every text change, create an entry in `document-diff.yaml`:
- Diff ID
- Patch ID
- Unit affected
- Before text (exact)
- After text (exact)
- Operation (insert, replace, delete)

### Step 6: Verify Patch Effects
After all patches are applied, re-read the modified sections and verify:
- Each patch's `expected_effect` was achieved
- No unintended side effects (neighboring text broken, cross-references stale)
- The paper remains well-formed (no hanging references, no broken citation anchors)

## Output Contract

```yaml
patch-trace.yaml:
  schema_version: "1.0.0"
  round_id: integer
  patches:
    - patch_id: string               # PP-001, matches revision-plan
      source_critiques: [string]     # CR-001, CR-002, ...
      disposition: accepted
      target_units: [string]
      patch_type: paragraph_rewrite | section_restructure | claim_weakening | claim_strengthening | related_work_repositioning | evaluation_obligation_addition | contribution_rewrite
      expected_effect: string        # from revision-plan
      actual_effect: string          # what actually changed
      diff_ids: [string]             # D-001, D-002, ...
      status: applied | partial | failed

document-diff.yaml:
  schema_version: "1.0.0"
  round_id: integer
  diffs:
    - diff_id: string                # D-001, D-002, ...
      patch_id: string               # which patch produced this diff
      unit: string                   # unit modified
      operation: insert | replace | delete
      location: string               # section/paragraph anchor
      before: string                 # exact text before change
      after: string                  # exact text after change
```

## Quality Gates

- [ ] Every patch in `revision-plan.yaml` with `disposition: accepted` has been applied
- [ ] `patch-trace.yaml` has an entry for every applied patch
- [ ] `document-diff.yaml` has a before/after entry for every text change
- [ ] Patch order respects dependencies — no patch applied before its dependency
- [ ] All text changes are within declared unit boundaries
- [ ] No patch has `status: failed` — if a patch failed, record a blocker and do not advance
- [ ] The paper document is well-formed after all changes (re-read to confirm)
- [ ] Claim changes match the strategy — a claim marked for weakening was actually weakened, not rewritten as a different claim

## Failure Conditions

- A patch cannot be applied because the target text no longer exists (earlier patch changed it) — STOP; the dependency order was wrong
- A claim_strengthening patch targets a claim with weak evidence — STOP; revert this patch, strengthen only when evidence supports it
- A section_restructure patch creates a malformed document (broken references, orphaned paragraphs) — STOP; fix the restructure
- Applying all patches does not achieve any patch's `expected_effect` — STOP; the patches are insufficient

## Forbidden Behavior

- Do not apply patches out of dependency order — even if it seems harmless
- Do not modify text outside target unit boundaries without documenting every affected unit
- Do not skip the patch trace or document diff — every change must be recorded
- Do not make "while I'm here" edits — if you notice an unrelated issue, record it as a next_round_candidate
- Do not fabricate evidence to justify a claim_strengthening patch
- Do not apply patches that are not in the revision plan

## Advance Rule

After all quality gates pass and all artifacts are written, run `cr stage advance`.
