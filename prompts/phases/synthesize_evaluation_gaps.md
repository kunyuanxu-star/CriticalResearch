# Phase: synthesize_evaluation_gaps

## Mission
Map every core claim to its evaluation contract. Identify what evaluation is required, what exists, what is missing, and what the minimum new experiment or argument would be.

## Inputs
- `claim-evidence-matrix.yaml`
- `baseline-positioning.yaml`

## Outputs
- `evaluation-gap-map.yaml`

## Allowed Actions
- Read claim-evidence-matrix and baseline-positioning.
- Define evaluation contract per claim.
- Identify missing evaluation.
- Define support and refutation conditions.

## Forbidden Actions
- Do not design experiments (that is M5).
- Do not critique evaluation (that is M4).
- Do not edit paper draft.

## Procedure
1. For each claim, define the required_evaluation_contract.
2. List existing_evidence that satisfies part of the contract.
3. Identify missing_evaluation explicitly.
4. Define minimum_new_experiment_or_argument.
5. Define support_condition and refutation_condition.

## Output Contract
```yaml
gap_map[*]:
  claim_id, required_evaluation_contract, existing_evidence, missing_evaluation
  minimum_new_experiment_or_argument (>=10 chars)
  support_condition (>=10 chars), refutation_condition (>=10 chars)
```

## Failure Conditions
- Any claim has no gap_map entry.
- support_condition or refutation_condition <10 chars.
- minimum_new_experiment_or_argument <10 chars.


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
`critique_evaluation_contract` will assess whether the evaluation contract is adequate.
