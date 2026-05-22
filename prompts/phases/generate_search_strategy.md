# Phase: generate_search_strategy

## Mission
Convert research questions into a concrete search plan with queries covering all 5 mandatory query classes: core_problem, strongest_baseline, recent_top_conference, production_or_real_world_case, counterexample_or_failure. Each query must bind to a research question.

## Inputs
- `research-questions.yaml`

## Outputs
- `search-plan.yaml`
- `search-queue.yaml`

## Allowed Actions
- Read research questions.
- Generate search queries across 5 mandatory classes.
- Bind each query to a question_id.
- Define success criteria for search coverage.

## Forbidden Actions
- Do not execute searches.
- Do not claim evidence has been found.
- Do not critique the paper.
- Do not write evidence-ledger.

## Procedure
1. For each research question, generate one or more concrete search queries.
2. Ensure queries cover all 5 mandatory classes.
3. Each query must have a linked_question_id.
4. Define success criteria: min_queries=5, min_sources=5, min_s_or_a_sources=2.
5. Write search-plan.yaml and empty search-queue.yaml.

## Output Contract
```yaml
queries[*]:
  query_id: string
  linked_question_id: string (must exist in research-questions.yaml)
  query: string
  query_class: core_problem|strongest_baseline|recent_top_conference|production_or_real_world_case|counterexample_or_failure
```
All 5 query classes must be covered.

## Failure Conditions
- Fewer than 5 queries.
- Any mandatory query class missing.
- Any query has no linked_question_id.
- No counterexample_or_failure query.

## Knowledge Use
Cite loaded knowledge cards with intended_use including `generate_search_strategy`.

## Handoff
`execute_retrieval` will execute these queries and save raw sources.
