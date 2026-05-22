# Phase: normalize_evidence

## Mission
Convert source notes into structured, claim-linked evidence. Each evidence item must specify direction (supports/weakens/contradicts/contextualizes), strength (S/A/B/C/D), and limits. At least one evidence item must weaken or contradict a claim.

## Inputs
- `source-notes/`
- `source-index.yaml`
- `state/claim-ledger.yaml`

## Outputs
- `evidence-ledger.yaml`

## Allowed Actions
- Read source notes and source index.
- Map source findings to paper claims.
- Assign evidence direction and strength.
- Document limits and boundaries.

## Forbidden Actions
- Do not generate critique-ledger.
- Do not edit paper draft.
- Do not write patches.
- Do not synthesize claims or baselines (that is M3).

## Procedure
1. For each source note, extract findings that relate to paper claims.
2. Create evidence items with: evidence_id, source_id, source_note_id, linked_claims.
3. Assign direction: supports, weakens, contradicts, or contextualizes.
4. Assign strength: S (definitive), A (strong), B (moderate), C (weak), D (anecdotal).
5. Write summary (>=20 chars) and limits (>=5 chars).
6. Ensure at least one evidence item weakens or contradicts.

## Output Contract
```yaml
evidence[*]:
  evidence_id, source_id, source_note_id, linked_claims, evidence_type, direction, strength, summary (>=20 chars), limits (>=5 chars)
```
Min 5 items, >=1 weakening/contradicting.

## Failure Conditions
- Fewer than 5 evidence items.
- No weakening or contradicting evidence.
- Any evidence item has summary <20 chars or limits <5 chars.
- Any evidence references a source_id not in source-index.

## Knowledge Use
Cite loaded knowledge cards with intended_use including `normalize_evidence`.


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
`build_related_work_map` will use these evidence items to construct the baseline landscape.
