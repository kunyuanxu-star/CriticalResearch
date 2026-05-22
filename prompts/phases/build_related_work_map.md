# Phase: build_related_work_map

## Mission
Construct a structured map of related work: baseline families, closest work, dangerous prior work, and positioning risks. Each closest work entry must specify overlap and difference.

## Inputs
- `evidence-ledger.yaml`
- `source-notes/`

## Outputs
- `related-work-map.yaml`

## Allowed Actions
- Read evidence and source notes.
- Group sources into baseline families.
- Identify closest work, dangerous prior work.
- Analyze positioning risks.

## Forbidden Actions
- Do not generate critique (that is M4).
- Do not edit paper draft.
- Do not write patches.

## Procedure
1. Group sources with similar approaches into baseline_families.
2. For each closest work: specify overlap (what is shared) and difference (what is novel).
3. Identify dangerous_prior_work: sources that could invalidate novelty claims.
4. List positioning_risks: where the paper's novelty might be overstated.

## Output Contract
```yaml
baseline_families: [{family_id, name, members}]
closest_work: [{source_id, overlap (>=10 chars), difference (>=10 chars)}]
dangerous_prior_work: [{source_id, risk}]
positioning_risks: [string]
```

## Failure Conditions
- closest_work empty or has no overlap/difference.
- overlap or difference <10 chars.

## Handoff
`update_literature_knowledge` will produce literature delta from this map.
