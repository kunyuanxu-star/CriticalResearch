# Phase: plan_writing_changes

## Mission
Plan the ordered application of patches to the paper draft. Define target sections, patch order, expected changes, and do-not-touch sections. Do NOT apply patches yet.

## Inputs
- `patches/PP-*.yaml`
- `writing/paper-draft.md`

## Outputs
- `writing-plan.yaml`

## Allowed Actions
- Read patches and current paper draft.
- Order patches by section and dependency.
- Define which sections will change.
- Define which sections must NOT change.

## Forbidden Actions
- Do not edit paper draft (that is apply phase).
- Do not apply patches.

## Procedure
1. Read all proposed patches.
2. Group patches by affected_section.
3. Order patches: section-local changes first, cross-section changes last.
4. Define target_sections and patch_order.
5. Define do_not_touch_sections explicitly.
6. Estimate risk_of_inconsistency.

## Output Contract
```yaml
target_sections: [section_anchor, ...] (>=1)
patch_order: [patch_id, ...] (>=1)
do_not_touch_sections: [section_anchor, ...]
risk_of_inconsistency: low|medium|high
```

## Failure Conditions
- target_sections empty.
- patch_order empty or doesn't include all patches.
- No do_not_touch_sections defined.


## Full-Paper Coverage Requirement

This phase must operate over the entire paper, not only over the current round objective.

You must inspect all required sections, claims, assumptions, baselines, and evaluation items listed in `full-paper-coverage-plan.yaml`.

The current round objective determines priority and emphasis, but it must not narrow coverage.

Your output artifact must include:

```yaml
full_paper_coverage:
  sections_checked: []
  claims_checked: []
  assumptions_checked: []
  baselines_checked: []
  evaluation_items_checked: []
  omissions: []

objective_relevance:
  level: direct | indirect
  explanation: ""
  objective_specific_findings: []
```

If any required item is not checked, this phase must not be marked complete.

## Handoff
apply_local_section_patches will execute this plan.
