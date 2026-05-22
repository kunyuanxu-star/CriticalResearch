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
apply_knowledge_delta will merge literature and thinking deltas and write back to global base.
