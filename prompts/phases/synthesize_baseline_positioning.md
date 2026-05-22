# Phase: synthesize_baseline_positioning

## Mission
Identify the single strongest baseline and assess the novelty threat. Document what positioning changes the paper needs to defend against this baseline.

## Inputs
- `related-work-map.yaml`
- `claim-evidence-matrix.yaml`

## Outputs
- `baseline-positioning.yaml`

## Allowed Actions
- Read related-work-map and claim-evidence-matrix.
- Identify strongest baseline.
- Explain why it is the strongest.
- Assess fairness of comparison.
- Recommend positioning changes.

## Forbidden Actions
- Do not critique novelty (that is M4).
- Do not edit paper draft.

## Procedure
1. From related-work-map, identify the strongest baseline (closest, most dangerous).
2. Explain why it is the strongest.
3. Assess whether the current comparison is fair.
4. Quantify the novelty threat: low, medium, high, fatal.
5. Specify required_positioning_change: what must the paper add to differentiate.

## Output Contract
```yaml
strongest_baseline:
  baseline_id, name (>=5 chars), why_strongest (>=20 chars), comparison_is_fair: bool
novelty_threat: low|medium|high|fatal
required_positioning_change: string (>=20 chars)
```

## Failure Conditions
- Strongest baseline name <5 chars.
- why_strongest <20 chars.
- required_positioning_change <20 chars.

## Handoff
`critique_novelty_and_baselines` will challenge the novelty claims.
