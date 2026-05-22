# Phase: global_argument_pass

## Mission
Check that local patch applications did not break the global argument chain. Verify introduction→motivation→problem→design→evaluation→conclusion→limitations coherence. If broken, the phase must fail and trigger repair.

## Inputs
- `writing/paper-draft.md`
- `paper-state.yaml`
- `writing-diff.yaml`

## Outputs
- `argument-flow-report.yaml`

## Allowed Actions
- Read current draft, paper-state, and writing-diff.
- Check argument chain coherence.
- Verify upstream/downstream consistency for changed sections.

## Forbidden Actions
- Do not edit draft.
- Do not add new content.
- Do not generate critique.

## Procedure
1. For each changed section, check upstream (what leads to it) and downstream (what follows).
2. Verify: introduction_chain, motivation_to_problem, design_to_evaluation, conclusion_to_claims.
3. Each check must have a status and, if broken, a specific issue description.

## Output Contract
```yaml
flow_checks:
  introduction_chain: string, motivation_to_problem: string
  design_to_evaluation: string, conclusion_to_claims: string
```

## Failure Conditions
- Any flow check is empty or placeholder.
- Argument chain is broken and not documented.


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
claim_evidence_alignment_pass will verify claim-evidence consistency.
