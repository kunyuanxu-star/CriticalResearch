# Phase: update_literature_knowledge

## Mission
Generate literature knowledge updates from source notes, evidence, and related work. This phase produces literature-delta.yaml only. It must NOT generate thinking rules or writing advice.

## Inputs
- `related-work-map.yaml`
- `source-notes/`
- `evidence-ledger.yaml`

## Outputs
- `literature-delta.yaml`

## Allowed Actions
- Read related-work-map, source notes, evidence.
- Generate literature knowledge updates (new, updated, deprecated cards).
- Reference source_id for each update.

## Forbidden Actions
- Do not write thinking rules or writing advice.
- Do not edit paper draft.
- Do not generate critique or patches.
- Do not write to global knowledge base (that is M7).

## Procedure
1. Review source notes and related-work-map for new literature insights.
2. Create update entries for new findings about papers, systems, concepts, debates.
3. Each update must reference a source_id.
4. If no new literature knowledge, produce valid no-op with substantive reason.

## Output Contract
```yaml
updates[*]:
  source_id: string (if creating/updating)
  action: add|update|deprecate|merge
  card_type: paper|system|concept|debate
  summary: string
```
Or explicit no-op with reason >=20 chars if no updates.

## Failure Conditions
- Updates exist but missing source_id.
- No updates AND no substantive no-op reason.


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
M3 (Evidence Synthesis) will synthesize claim-evidence relationships from these artifacts.
