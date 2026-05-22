# Phase: prepare_next_round

## Mission
Identify what the next round should address. List candidate risks, priority items, blocked items, required experiments, and recommended focus. This phase does NOT start a new round.

## Inputs
- `reviewer-readiness.yaml`
- `experiment-obligations.yaml`
- `knowledge-delta.yaml`

## Outputs
- `next-round-targets.yaml`

## Allowed Actions
- Read reviewer-readiness, experiment obligations, knowledge delta.
- List candidate risks for next round.
- Prioritize based on severity and dependencies.
- Recommend next round focus.

## Forbidden Actions
- Do not start a new round.
- Do not edit paper draft.
- Do not create patches.

## Procedure
1. Review remaining_objections and known_weaknesses.
2. Review unfulfilled experiment obligations.
3. Review knowledge gaps from knowledge delta.
4. List candidate_risks in priority order.
5. Identify blocked_items (depend on external factors).
6. Write recommended_next_round: one sentence describing optimal next focus.

## Output Contract
```yaml
candidate_risks: [string] (>=1)
priority: [string]
blocked_items: [string]
recommended_next_round: string (>=20 chars)
```

## Failure Conditions
- candidate_risks empty (no risk suggests round is complete but must be justified).
- recommended_next_round <20 chars.
- No priority ordering.

## Handoff
close_round will validate the entire round and produce the closure report.
