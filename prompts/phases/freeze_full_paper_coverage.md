# Phase: freeze_full_paper_coverage

## Mission
Create a complete inventory of every element that every subsequent phase must cover. This phase does NOT limit scope — it documents what the full paper contains so that coverage can be verified. The user objective is a weighting lens, not a scope limiter.

## Inputs
- `round-objective.yaml` — user's primary focus for this round
- `paper-state.yaml` — frozen paper snapshot

## Outputs
- `full-paper-coverage-plan.yaml` — complete paper inventory

## Allowed Actions
- Read round-objective and paper-state.
- Inventory ALL sections in the paper draft.
- Inventory ALL core claims, assumptions, baselines, and evaluation obligations.
- Write full-paper-coverage-plan.yaml.

## Forbidden Actions
- Do NOT limit paper scope. Every section, claim, assumption, baseline, and evaluation must be listed.
- Do NOT exclude any section or claim — even if it seems unrelated to the objective.
- Do not search, critique, or edit the paper draft.

## Procedure
1. Read `writing/paper-draft.md` and extract every section with section_id and title.
2. From `paper-state.yaml`, extract every core claim, assumption, baseline, and evaluation item.
3. List all items in the paper_inventory.
4. Set coverage_policy: all items required.
5. Document objective_focus alongside the full inventory.
6. Define non_focus_policy: issues in non-focus areas are recorded, not ignored.

## Output Contract
```yaml
paper_inventory:
  sections: [{section_id, title, required: true}, ...]
  claims: [{claim_id, appears_in, required_full_pass: true}, ...]
  assumptions: [{assumption_id, linked_claims}, ...]
  baselines: [{baseline_id, linked_claims}, ...]
  evaluation_items: [{eval_id, linked_claims}, ...]
coverage_policy:
  all_sections_required: true
  all_claims_required: true
  all_assumptions_required: true
  all_baselines_required: true
  all_evaluation_items_required: true
objective_focus:
  objective_id: current
  focus_type: ""
  priority_weight: high
non_focus_policy:
  if_issue_found: record_as_secondary_finding
  if_severe: create_patch_or_human_decision
```

## Failure Conditions
- paper_inventory.sections is empty.
- Any section from the paper draft is missing from the inventory.
- The inventory suggests limiting scope to only objective-related items.

## Full-Paper Coverage Requirement

This phase documents the full paper inventory. Every subsequent phase must cover all items listed here. The `cr-validate-full-paper-coverage` validator checks this.

Your output must include `full_paper_coverage` and `objective_relevance`.

## Handoff
Every subsequent phase uses this inventory to verify full-paper coverage.
