# Stage 7: Knowledge Consolidation

## Mission
Distill round-local learning into reusable global knowledge. Merge literature and thinking knowledge into a single knowledge-delta.yaml. Write knowledge cards back to the global knowledge base. Round-local learning must escape into the global knowledge base.

This stage enforces **Inv5**: Every round must produce a knowledge delta.

## Inputs
- `round:critique-ledger.yaml` — structured critique entries
- `round:patch-trace.yaml` — traceability matrix
- `round:evidence-ledger.yaml` — structured evidence

## Outputs
- `knowledge-delta.yaml` — structured knowledge transaction
- `knowledge-apply-log.yaml` — proof of writeback to global knowledge base

## Allowed Actions
- Read critique ledger, patch trace, and evidence ledger.
- Distill literature knowledge: paper cards, method cards, concept cards, comparison maps.
- Distill thinking knowledge: research principles, writing rules, reviewer patterns, anti-patterns.
- Write knowledge-delta.yaml with typed updates.
- Write knowledge cards to `_cr/knowledge/` with maturity tracking.
- Record knowledge-apply-log.yaml with before/after hashes.

## Forbidden Actions
- Do not edit paper draft.
- Do not generate patches.
- Do not modify claim ledger.
- Do not write generic advice without specific trigger and scope.

## Procedure

### 1. Distill Literature Knowledge
From evidence and sources, create or update:
- Paper cards: key findings, methods, limitations.
- Method cards: technique descriptions, when to use, when not to use.
- Concept cards: definitions, debates, consensus.
- Comparison maps: how sources relate to each other and to the paper.

### 2. Distill Thinking Knowledge
From critiques, patches, and round experience, create or update:
- Research principles: what worked, what didn't, why.
- Writing rules: patterns for clarity, argument flow, claim precision.
- Reviewer patterns: common objections and how to preempt them.
- Anti-patterns: mistakes to avoid in future rounds.

### 3. Write Knowledge Delta
Produce knowledge-delta.yaml with updates array:
- update_id, update_type, scope, operation.
- update_type: thinking_rule | literature_card | research_principle | writing_rule | evaluation_pattern.
- scope: candidate_reusable | bank_update | project_local.
- operation: create_card | update_card | append_comparison | deprecate_card.
- generated_from: patches, critiques, evidence.
- rule: title, statement, applies_to, anti_examples.
- maturity: candidate | used | validated | canonical | deprecated.

### 4. Write Back to Knowledge Base
Write or update knowledge cards in `_cr/knowledge/`:
- Research cards: `_cr/knowledge/cards/research/*.md`
- Writing cards: `_cr/knowledge/cards/writing/*.md`
- Review cards: `_cr/knowledge/cards/review/*.md`

Record knowledge-apply-log.yaml with before/after sha256 hashes.

## Output Contract

```yaml
knowledge-delta.yaml:
  schema_version: "1.0.0"
  round_id: integer
  no_update_justification: string (optional)
  updates:
    - update_id: KDU-###
      update_type: thinking_rule|literature_card|research_principle|writing_rule|evaluation_pattern
      scope: candidate_reusable|bank_update|project_local
      operation: create_card|update_card|append_comparison|deprecate_card
      proposed_card_id: string
      target_path: string
      generated_from:
        patches: [PP-###]
        critiques: [CRT-###]
        evidence: [E-###]
      rule:
        title: string
        statement: string (>= 10)
        applies_to: [string]
        anti_examples: [string]
      content_summary: string
      maturity: candidate|used|validated|canonical|deprecated

knowledge-apply-log.yaml:
  schema_version: "1.0.0"
  round_id: integer
  applied_updates:
    - update_id: KDU-###
      target_path: string
      before_hash: string
      after_hash: string
      applied_at: ISO8601
```

## Failure Conditions
- No knowledge updates and no no_update_justification.
- Any update missing update_type or scope.
- Knowledge cards written without apply-log entry.
- Generic advice without specific trigger or scope.

## Completion Checklist
- [ ] Literature knowledge distilled into cards.
- [ ] Thinking knowledge distilled into rules and patterns.
- [ ] knowledge-delta.yaml has typed updates.
- [ ] Knowledge cards written back to `_cr/knowledge/`.
- [ ] knowledge-apply-log.yaml records before/after hashes.

## Full-Paper Coverage Requirement
Knowledge should be generalizable beyond the current round's primary target. Capture lessons that apply to future rounds.

## Handoff
The next stage (`s8_round_closure`) validates the round and prepares next-round candidates.
