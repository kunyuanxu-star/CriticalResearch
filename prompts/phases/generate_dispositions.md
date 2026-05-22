# Phase: generate_dispositions

## Mission
Decide the disposition for every critique in the ledger. Each critique must have exactly one decision. Medium/high/fatal critiques cannot be rejected without substantive reason. Thesis-level changes must be flagged for human_decision_required.

## Inputs
- `critique-ledger.yaml`

## Outputs
- `dispositions.yaml`

## Allowed Actions
- Read critique-ledger.
- Decide disposition per critique: accept_patch, weaken_claim, split_claim, add_evaluation, defer_with_reason, reject_with_reason, human_decision_required.
- Provide substantive reason for every decision.

## Forbidden Actions
- Do not edit paper draft.
- Do not write patches.
- Do not silently drop critiques.
- Do not reject medium+ critiques without substantive reason.

## Procedure
1. For every critique in critique-ledger, make a disposition decision.
2. Each disposition must have: critique_id, decision, reason (>=10 chars).
3. For accepted patches, specify linked_patch_candidate.
4. For human_decision_required, specify what decision is needed.
5. Medium/high/fatal critiques: reject_with_reason or defer_with_reason only if blocker is insoluble this round.

## Output Contract
```yaml
dispositions[*]:
  critique_id, decision (from valid enum), reason (>=10 chars)
  linked_patch_candidate (if accept_patch)
  linked_human_decision (if human_decision_required)
```
Every critique_id in the ledger must have a disposition.

## Failure Conditions
- Any critique has no disposition.
- Any disposition reason <10 chars.
- Medium+ critique rejected with reason <20 chars.
- Invalid decision value.


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
resolve_human_decisions and generate_paper_patches depend on this output.
