# Phase: distill_literature_knowledge

## Mission
Distill literature insights from this round into structured knowledge updates. Each update must reference a source_id, specify the action (add/update/deprecate/merge), and include the card content. This phase handles ONLY literature knowledge — thinking rules and writing patterns go to distill_thinking_knowledge.

## Inputs
- `literature-delta.yaml`
- `related-work-map.yaml`
- `source-notes/`

## Outputs
- `literature-knowledge-delta.yaml`

## Allowed Actions
- Read literature-delta, related-work-map, source notes.
- Generate literature knowledge updates with source references.
- Classify updates: paper, system, concept, debate.
- Mark maturity: candidate (new), validated (confirmed), canonical (widely applicable).

## Forbidden Actions
- Do not write thinking rules or writing advice.
- Do not modify global knowledge base (that is apply_knowledge_delta).
- Do not edit paper draft.

## Procedure
1. Review source notes and related-work-map for literature insights.
2. For each insight, create a literature update with:
   - Which source_id it came from
   - What action (add new card, update existing, deprecate obsolete, merge duplicates)
   - The card content (title, summary, evidence_level, key_claims, limitations)
   - What it applies to and what it does NOT apply to
3. If no new literature knowledge, provide explicit no-op reason >=20 chars.

## Output Contract
```yaml
literature_updates[*]:
  source_id, action: add|update|deprecate|merge
  card_type: paper|system|concept|debate
  title, summary (>=20 chars)
  applies_when: string, does_not_apply_when: string
  maturity: candidate|validated|canonical
```

## Failure Conditions
- Update has no source_id.
- Summary <20 chars.
- No applies_when or does_not_apply_when.
- No updates AND no substantive no-op reason.


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
distill_thinking_knowledge handles thinking rules; apply_knowledge_delta writes both to global base.
