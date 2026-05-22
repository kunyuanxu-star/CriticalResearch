# Phase: triage_sources

## Mission
Screen every raw source. Mark each as include, exclude, or maybe with a substantive reason. At least 2 sources must be marked include and rated as S/A-level evidence candidates.

## Inputs
- `search-log.yaml`
- `raw-sources/`

## Outputs
- `source-triage.yaml`

## Allowed Actions
- Read raw source content.
- Read search log.
- Decide include/exclude/maybe for each source.
- Estimate evidence level (S/A/B/C/D).
- Provide substantive reason for each decision.

## Forbidden Actions
- Do not generate evidence-ledger.
- Do not write source-notes (that is read_sources).
- Do not critique the paper.
- Do not edit paper draft.

## Procedure
1. For each raw source, skim the content.
2. Classify as include, exclude, or maybe based on relevance to in-scope claims.
3. Estimate evidence_level_candidate (S/A/B/C/D).
4. Provide concrete reason for each decision (>=5 chars).
5. Link each triage decision to a research question.
6. Ensure >=2 include sources rated S or A.

## Output Contract
```yaml
triage[*]:
  source_id: string
  decision: include|exclude|maybe
  reason: string (>=5 chars)
  evidence_level_candidate: S|A|B|C|D
  linked_question: string
```
At least 2 include decisions with evidence_level_candidate S or A.

## Failure Conditions
- Fewer than 5 triage decisions.
- Fewer than 2 include decisions with S/A evidence level.
- Any triage decision has reason <5 chars.

## Handoff
`ingest_sources` will create the structured source index.
