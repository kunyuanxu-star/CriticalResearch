# Phase: synthesize_claim_evidence

## Mission
Synthesize evidence per claim. Every core claim must appear in the matrix with supporting, weakening, contradicting, and missing evidence, a support_level, and a risk_level. Claims without evidence must be explicitly flagged as evidence_gap.

## Inputs
- `evidence-ledger.yaml`
- `paper-state.yaml`

## Outputs
- `claim-evidence-matrix.yaml`

## Allowed Actions
- Read evidence-ledger and paper-state.
- Map every evidence item to claim(s).
- Assess support_level per claim (none/partial/strong/conclusive).
- Flag evidence gaps explicitly.

## Forbidden Actions
- Do not add new evidence or sources.
- Do not critique claims (that is M4).
- Do not edit paper draft or write patches.

## Procedure
1. For every core claim in paper-state, create a claim_row.
2. List supporting_evidence, weakening_evidence, contradicting_evidence.
3. List missing_evidence explicitly.
4. Assign current_support_level: none, partial, strong, conclusive.
5. Assign risk_level based on evidence quality.
6. If support_level is not strong/conclusive, must have evidence_gap declared.

## Output Contract
```yaml
claim_rows[*]:
  claim_id, supporting_evidence, weakening_evidence, contradicting_evidence
  missing_evidence: [string]
  current_support_level: none|partial|strong|conclusive
  risk_level: low|medium|high|fatal
  evidence_gap: string (required if support_level is not strong/conclusive)
```

## Failure Conditions
- Any core claim missing from matrix.
- Any claim_row has no support_level.
- Support_level is partial or none but no evidence_gap declared.
- Evidence_refs reference evidence_ids not in evidence-ledger.

## Handoff
`critique_evidence_sufficiency` will attack these support_level assessments.
