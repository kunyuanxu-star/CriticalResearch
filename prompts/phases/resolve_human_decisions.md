# Phase: resolve_human_decisions

## Mission
Resolve all human_decision_required dispositions. Decisions affecting thesis, claim scope, assumptions, baselines, contribution, or evaluation priority MUST go through human gate. Agent must NOT silently decide thesis-level changes.

## Inputs
- `dispositions.yaml`
- `state/human-review-queue.yaml`

## Outputs
- `human-decisions.yaml`

## Allowed Actions
- Read dispositions and human-review-queue.
- Present decisions that require human judgment.
- Record resolved decisions with rationale.
- Defer decisions with explicit blocker and next action.

## Forbidden Actions
- Do not silently decide thesis-level changes.
- Do not edit paper draft or write patches.
- Do not resolve human_decision_required dispositions without explicit human input.

## Procedure
1. Identify all dispositions with decision=human_decision_required.
2. For each: if this is a thesis/scope/assumption/baseline/contribution/evaluation-priority decision, queue for human.
3. Record resolved decisions in human-decisions.yaml.
4. If no human decisions needed, provide explicit no-op reason >=20 chars.

## Output Contract
```yaml
decisions[*]:
  critique_id, decision, resolved_by, rationale
```
Or explicit no_human_decision_reason >=20 chars.

## Failure Conditions
- Human_decision_required disposition has no corresponding decision entry.
- No decisions AND no substantive no-op reason.
- Thesis-level change decided without human gate.

## Handoff
generate_paper_patches depends on resolved human decisions.
