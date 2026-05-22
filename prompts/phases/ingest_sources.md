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

## Handoff
`read_sources` will deeply read each included source.
