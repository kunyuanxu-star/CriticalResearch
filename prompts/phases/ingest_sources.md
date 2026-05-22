# Phase: ingest_sources

## Mission
Create a structured, hash-verified index of all included sources. Each source must have a sha256 hash, title, origin, evidence_level, and included flag.

## Inputs
- `raw-sources/`
- `source-triage.yaml`

## Outputs
- `source-index.yaml`

## Allowed Actions
- Read raw source files.
- Compute sha256 hashes.
- Record structured metadata per source.
- Verify source integrity.

## Forbidden Actions
- Do not edit raw source content.
- Do not generate evidence-ledger.
- Do not critique the paper.

## Procedure
1. For each triaged source, record: source_id, path, url_or_origin, title, authors_or_org, retrieved_at, sha256, evidence_level, included flag.
2. Compute sha256 hash of each raw source file.
3. Ensure >=2 sources are evidence_level S or A.

## Output Contract
```yaml
sources[*]:
  source_id, path, url_or_origin, title, authors_or_org, retrieved_at, sha256 (>=6 chars), evidence_level, included
```
At least 5 sources, with >=2 at S/A level.

## Failure Conditions
- Fewer than 5 indexed sources.
- Any source missing sha256 or has sha256 <6 chars.
- Any source missing title.
- Fewer than 2 S/A-level sources.


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
`read_sources` will deeply read each included source.
