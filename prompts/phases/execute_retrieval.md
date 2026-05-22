# Phase: execute_retrieval

## Mission
Execute the search plan. Save raw source snapshots with sufficient content. Record every search in search-log with query class and selected/rejected sources.

## Inputs
- `search-plan.yaml`
- `search-queue.yaml`

## Outputs
- `search-log.yaml`
- `raw-sources/` (>=5 files, each >=50 bytes)

## Allowed Actions
- Execute searches per search-plan.yaml.
- Save raw source content as individual files.
- Record search metadata (query, query_class, selected_sources, rejected_sources).

## Forbidden Actions
- Do not critique sources.
- Do not generate evidence-ledger.
- Do not edit paper draft.
- Do not write source-notes or critique.

## Procedure
1. Execute each query from search-plan.yaml.
2. Save raw source content to raw-sources/SRC-xxx.ext.
3. Each raw source file must be >=50 bytes of substantive content.
4. Record each search in search-log.yaml with query_class, selected_sources, rejected_sources.
5. Ensure counterexample_or_failure query is executed.

## Output Contract
```yaml
search-log.yaml searches[*]:
  query_id, query, query_class, adapter, selected_sources, rejected_sources
raw-sources/: >=5 files, each >=50 bytes
```

## Failure Conditions
- Fewer than 5 searches executed.
- Fewer than 5 raw source files.
- Any raw source file <50 bytes.
- No counterexample_or_failure search in log.

## Completion Checklist
- [ ] >=5 searches recorded with all 5 query classes.
- [ ] >=5 raw source files with >=50 bytes each.
- [ ] Counterexample query executed.

## Handoff
`triage_sources` will evaluate which sources are worth including.
