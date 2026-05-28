# Stage 6: Revision Plan

## Purpose

Transform the writing strategy from stage 5 into a concrete, ordered revision plan. Each revision is a specific patch with a declared type, target unit, source critique, expected effect, and dependency ordering. The revision plan is the blueprint that stage 7 executes — every patch applied in stage 7 must have a corresponding entry here.

This stage must NOT:
- Apply patches to the paper document (that's stage 7)
- Introduce patches not traceable to a critique + strategy decision
- Order patches arbitrarily — dependency ordering matters

## Stage Type

planning-only

## Required Inputs

- `critical-review.yaml` — all critiques, severity, grounding
- `writing-strategy.yaml` — narrative, section, claim, and positioning strategy
- `claim-evidence-grounding.yaml` — evidence constraints for claim changes
- `contract.yaml` — target units, round objective
- `workflows/paper/workflow.yaml` — valid patch types, patch schema reference
- `workflows/paper/profile.md` — paper workflow semantics
- `workflows/_shared/stage-protocol.md` — stage execution discipline
- `workflows/_shared/patch-discipline.md` — patch traceability and dependency rules
- `workflows/_shared/evidence-discipline.md` — evidence adequacy for claim patches

## Allowed Writes

- `revision-plan.yaml` — and ONLY revision-plan.yaml
- `patch-plan.yaml` — and ONLY patch-plan.yaml

## Required Procedure

### Step 1: Load Strategy and Critique
Read `writing-strategy.yaml` to get every strategic decision. Read `critical-review.yaml` to confirm that every critique has a disposition. Read `workflows/paper/workflow.yaml` to confirm valid patch types.

### Step 2: Disposition Every Critique
For every critique in `critical-review.yaml`, record a disposition:
- **accepted**: the critique is valid and will be addressed with a patch
- **rejected**: the critique is invalid or unjustified — must explain why
- **deferred**: the critique is valid but out of scope for this round — record as `next_round_candidate`
- **disputed**: the critique raises a point that needs human judgment — flag for decision

Every accepted critique MUST map to at least one patch. A critique with no patch and no explicit rejection/deferral is unresolved.

### Step 3: Generate Patches
For each strategic decision in `writing-strategy.yaml`, generate one or more patches:

For section strategy decisions:
- **section_restructure** patches: reorder, split, or merge sections
- **paragraph_rewrite** patches: rewrite specific paragraphs within a unit

For claim strategy decisions:
- **claim_weakening** patches: narrow the scope or soften the language of a claim
- **claim_strengthening** patches: make a claim more definitive (only when evidence supports it)

For positioning strategy decisions:
- **related_work_repositioning** patches: reframe how prior work is discussed
- **contribution_rewrite** patches: rewrite the contribution statement

For evaluation gaps:
- **evaluation_obligation_addition** patches: add evaluation requirements to the paper (as future work or explicit limitations)

### Step 4: Assign Patch IDs and Traceability
Every patch MUST trace to:
- One or more critique IDs → one disposition (accepted) → the strategic decision → this patch

Record the full trace in the patch entry.

### Step 5: Define Expected Effect
For each patch, state the expected effect on the paper:
- What will be different after this patch is applied?
- How will this address the source critique?
- What should a reviewer notice that's different?

### Step 6: Order by Dependencies
Order patches so that:
- Structural patches (section restructure, reorder) come before content patches within the affected sections
- Claim weakening/strengthening patches come before paragraph rewrites that depend on the revised claims
- Patches that modify the same paragraph are ordered and their interactions noted

### Step 7: Write Revision Plan
Produce `revision-plan.yaml` and `patch-plan.yaml`.

## Output Contract

```yaml
revision-plan.yaml:
  schema_version: "1.0.0"
  round_id: integer
  dispositions:
    - critique_id: string           # CR-001, CR-002, ...
      disposition: accepted | rejected | deferred | disputed
      rationale: string             # why this disposition
      patch_ids: [string]           # patches addressing this critique (if accepted)
  patch_order:
    - patch_id: string              # PP-001, PP-002, ...
      patch_type: paragraph_rewrite | section_restructure | claim_weakening | claim_strengthening | related_work_repositioning | evaluation_obligation_addition | contribution_rewrite
      target_units: [string]        # unit IDs from contract
      source_critiques: [string]    # critique IDs
      source_strategy: string       # reference to writing-strategy decision
      description: string           # what this patch does
      expected_effect: string       # what changes in the paper
      dependencies: [string]        # patch IDs this patch depends on
      estimated_impact: high | medium | low

patch-plan.yaml:
  schema_version: "1.0.0"
  round_id: integer
  patches:
    - patch_id: string              # PP-001, matches revision-plan
      patch_type: string            # matches workflow.yaml patch_types
      target_units: [string]
      operation: insert | replace | delete
      anchor_description: string    # where in the unit the change goes
      content_guidance: string      # what to write (not exact text — that's stage 7)
      claim_changes: [string]       # claim IDs modified
      expected_diff_summary: string # one-line summary of the expected diff
```

## Quality Gates

- [ ] Every critique from `critical-review.yaml` has a disposition entry
- [ ] Every `accepted` disposition maps to at least one patch
- [ ] Every `rejected` disposition has a rationale that addresses the critique's grounding
- [ ] Every `deferred` disposition identifies the round or condition for addressing it
- [ ] Patch IDs are sequential (PP-001, PP-002, ...) and unique
- [ ] Patch types are from `workflows/paper/workflow.yaml` `patch_types` — no invented types
- [ ] Dependency ordering is valid — no patch depends on a later patch
- [ ] Every patch targets at least one unit from `contract.yaml` `target_units`
- [ ] `patch-plan.yaml` entries match `revision-plan.yaml` entries 1:1

## Failure Conditions

- A critique with no disposition — STOP; every critique must be resolved
- A patch with `patch_type` not in workflow.yaml `patch_types` — STOP; invalid patch type
- A dependency cycle — STOP; reorder patches
- A patch that targets a unit not in `target_units` — STOP; out of scope
- A claim_strengthening patch for a claim with `evidence_strength: weak` or `none` — STOP; cannot strengthen without evidence

## Forbidden Behavior

- Do not apply patches to the paper document — planning-only stage
- Do not generate patches without a traceable critique → disposition → strategy chain
- Do not skip disposition for any critique — even minor critiques get a disposition
- Do not invent patch types — use only types from `workflow.yaml`
- Do not create patches for units outside `target_units`

## Advance Rule

After all quality gates pass and both artifacts are written, run `cr stage advance`.
