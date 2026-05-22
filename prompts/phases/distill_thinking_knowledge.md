# Phase: distill_thinking_knowledge

## Mission
Distill thinking rules from this round's specific failures, fixes, and reviewer patterns. Each rule must specify: learned_rule, trigger, where_applies, where_not_applies, future_use, maturity. Rules must be derived from concrete round artifacts, not generic advice.

## Inputs
- `critique-ledger.yaml`
- `argument-flow-report.yaml`
- `reviewer-readiness.yaml`

## Outputs
- `thinking-knowledge-delta.yaml`

## Allowed Actions
- Read critique-ledger, argument-flow-report, reviewer-readiness.
- Extract patterns: what went wrong, how it was fixed.
- Formulate reusable thinking rules with trigger conditions.
- Specify where the rule applies and does NOT apply.

## Forbidden Actions
- Do not write generic advice ("write more clearly").
- Do not create rules without concrete round artifacts as evidence.
- Do not write literature knowledge.

## Procedure
1. Review this round's critiques and writing issues.
2. For each specific failure that was fixed, extract the pattern.
3. Formulate a rule: what was the problem, what was the fix, when to apply.
4. Specify trigger conditions: when should this rule be activated.
5. Specify anti-conditions: when should this rule NOT be applied.
6. Record maturity: candidate (from one round), validated (confirmed in multiple rounds), canonical (widely applicable).
7. If no new rules, provide explicit no-op reason >=20 chars.

## Output Contract
```yaml
thinking_rules[*]:
  learned_rule (>=20 chars), trigger (>=10 chars)
  where_applies, where_not_applies, future_use
  maturity: candidate|validated|canonical
  derived_from_round: true
```

## Failure Conditions
- Rule text <20 chars.
- No trigger condition.
- No where_not_applies.
- Rule is generic advice without concrete evidence.
- No rules AND no substantive no-op reason.

## Handoff
apply_knowledge_delta will merge literature and thinking deltas and write back to global base.
