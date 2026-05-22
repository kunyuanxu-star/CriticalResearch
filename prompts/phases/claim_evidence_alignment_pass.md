# Phase: claim_evidence_alignment_pass

## Mission
Verify that every claim in the paper is aligned with the evidence. Claim strength in the draft must not exceed evidence support level. If a claim was weakened or split, verify claim-ledger is synchronized.

## Inputs
- `writing/paper-draft.md`
- `claim-evidence-matrix.yaml`
- `evidence-ledger.yaml`

## Outputs
- `claim-paper-matrix.yaml`

## Allowed Actions
- Read draft, claim-evidence-matrix, and evidence-ledger.
- Map paper claims to evidence support levels.
- Flag misalignments where paper claim strength exceeds evidence.

## Forbidden Actions
- Do not edit draft.
- Do not add evidence.
- Do not change claim-ledger directly.

## Procedure
1. Extract every claim from the paper draft.
2. Map each to a claim_row in claim-evidence-matrix.
3. Compare paper_strength to evidence_level.
4. Flag any misalignment where paper claims exceed evidence support.
5. Record mapping with aligned status.

## Output Contract
```yaml
mapping[*]:
  claim_id, paper_strength, evidence_level, aligned: bool
```

## Failure Conditions
- Claim in paper has no mapping entry.
- Paper claim strength exceeds evidence without documented justification.
- Mapping is empty.


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
reviewer_readiness_pass depends on this alignment report.
