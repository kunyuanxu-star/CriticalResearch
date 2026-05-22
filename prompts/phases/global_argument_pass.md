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

## Handoff
claim_evidence_alignment_pass will verify claim-evidence consistency.
