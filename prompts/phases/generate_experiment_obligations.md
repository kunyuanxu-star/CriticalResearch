# Phase: generate_experiment_obligations

## Mission
For every claim-affecting patch, generate an experiment obligation: hypothesis, baseline, method, metric, success_condition, refutation_condition. Patches that do not affect claims need explicit no-op justification.

## Inputs
- `patches/PP-*.yaml`
- `evaluation-gap-map.yaml`

## Outputs
- `experiment-obligations.yaml`
- `experiments/EXP-*.yaml`

## Allowed Actions
- Read patches and evaluation gaps.
- Design experiment obligations for claim-affecting patches.
- Specify hypothesis, baseline, method, metric, success/failure conditions.

## Forbidden Actions
- Do not fabricate experiment results.
- Do not run experiments.
- Do not edit paper draft.

## Procedure
1. For each patch with experiment_obligation_needed=true, create an obligation.
2. Define: hypothesis, baseline, method, metric, success_condition, refutation_condition.
3. Link obligation to patch and claim.
4. Specify paper_section_to_update.
5. If no obligations needed, provide explicit no-op reason >=20 chars.

## Output Contract
```yaml
obligations[*]:
  exp_id, linked_patch, linked_claim, hypothesis, baseline
  method, metric, success_condition (>=10 chars), refutation_condition (>=10 chars)
  paper_section_to_update
```
Or no_experiment_needed_reason >=20 chars.

## Failure Conditions
- Claim-affecting patch has no experiment obligation.
- Any obligation has success_condition or refutation_condition <10 chars.
- No obligations AND no substantive no-op reason.


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
plan_writing_changes will order these patches for draft application.
