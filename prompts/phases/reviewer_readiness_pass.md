# Phase: reviewer_readiness_pass

## Mission
Assess whether the paper draft is ready for reviewer scrutiny. Document remaining objections, likely reviewer questions, known weaknesses, and rebuttal hooks. Every high/fatal critique must be resolved, blocked, or tracked for next round.

## Inputs
- `writing/paper-draft.md`
- `critique-ledger.yaml`
- `argument-flow-report.yaml`
- `claim-paper-matrix.yaml`

## Outputs
- `reviewer-readiness.yaml`

## Allowed Actions
- Read draft, critique-ledger, argument-flow-report, claim-paper-matrix.
- Document remaining objections with status.
- Identify likely reviewer questions.
- List known weaknesses and rebuttal hooks.

## Forbidden Actions
- Do not edit draft.
- Do not generate new patches or critique.
- Do not claim paper is ready if high/fatal critiques are unresolved.

## Procedure
1. Review all high/fatal critiques: each must be resolved, blocked, or next_round_tracked.
2. List remaining objections with status: resolved, blocked, or next_round_tracked.
3. Anticipate likely reviewer questions.
4. Document known weaknesses honestly.
5. Provide rebuttal hooks where possible.

## Output Contract
```yaml
remaining_objections[*]:
  status: resolved|blocked|next_round_tracked
likely_reviewer_questions: [string]
known_weaknesses: [string]
```

## Failure Conditions
- High/fatal critique has no remaining_objection entry.
- Objection status is not from valid enum.
- remaining_objections is empty (claiming no objections requires documented justification).

## Handoff
Knowledge distillation phases will extract rules from the reviewer readiness findings.
