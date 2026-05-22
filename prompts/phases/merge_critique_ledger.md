# Phase: merge_critique_ledger

## Mission
Merge all five critique passes into a single authoritative critique-ledger.yaml. Every critique must specify source_pass, severity, linked claims/sections, evidence_refs, reason (>=20 chars), recommended_action, and must_create_patch flag. Medium+ critiques must have evidence_refs. High/fatal critiques must_create_patch must be true.

## Inputs
- `critique-claim-precision.yaml`
- `critique-novelty-baseline.yaml`
- `critique-evidence.yaml`
- `critique-evaluation.yaml`
- `critique-writing.yaml`

## Outputs
- `critique-ledger.yaml`

## Allowed Actions
- Read all five critique passes.
- Merge findings from all passes into unified ledger.
- Assign severity consistently.
- Flag must_create_patch for medium+ critiques.

## Forbidden Actions
- Do not add new critiques not present in the five passes.
- Do not edit paper draft.
- Do not write patches or dispositions.
- Do not silently drop critiques.

## Procedure
1. Read every finding from all five passes.
2. Assign a unique critique_id to each finding.
3. Record source_pass (which pass this came from).
4. Ensure every medium+ critique has evidence_refs.
5. Set must_create_patch=true for all high/fatal critiques.
6. Ensure every critique has reason >=20 chars.

## Output Contract
```yaml
critiques[*]:
  critique_id, source_pass, severity: low|medium|high|fatal
  linked_claims, linked_sections, evidence_refs
  reason (>=20 chars), recommended_action, must_create_patch: bool
```
At least 1 medium+ critique required.

## Failure Conditions
- No medium+ critiques.
- Any high/fatal critique has must_create_patch=false.
- Any critique reason <20 chars.
- Fewer critiques than the sum of findings in the five passes.


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
`generate_dispositions` will decide how to handle each critique.
