# Stage 9: Knowledge Delta

## Mission
Distill round-local learning into reusable global knowledge. Merge domain research, critique patterns, scope decisions, and risk insights into a single knowledge-delta.yaml. Write knowledge cards back to the global knowledge base. Update the goal ledger. Round-local learning must escape into the global knowledge base.

This stage enforces **Inv9**: Every round must produce a knowledge delta.

## Inputs
- `round:critique-ledger.yaml` — structured critique entries
- `round:patch-trace.yaml` — traceability matrix
- `round:evidence-ledger.yaml` — structured evidence
- `round:scope-assessment.yaml` — scope and contribution decisions
- `round:risk-register.yaml` — updated risk tracking
- `round:milestone-tracker.yaml` — updated milestone tracking

## Outputs
- `knowledge-delta.yaml` — structured knowledge transaction
- `knowledge-apply-log.yaml` — proof of writeback to global knowledge base

## Allowed Actions
- Read critique ledger, patch trace, evidence ledger, scope assessment, risk register, and milestone tracker.
- Distill domain knowledge: market patterns, prior art cards, feasibility patterns, resource benchmarks.
- Distill process knowledge: critique patterns, scope heuristics, risk patterns, milestone estimation rules.
- Write knowledge-delta.yaml with typed updates.
- Write knowledge cards to `_cr/knowledge/` with maturity tracking.
- Record knowledge-apply-log.yaml with before/after hashes.
- Update state/goal-ledger.yaml for affected goals.

## Forbidden Actions
- Do not edit proposal document.
- Do not generate patches.
- Do not write generic advice without specific trigger and scope.
- Do not modify scope assessment or risk register.

## Procedure

### 1. Distill Domain Knowledge
From evidence, scope assessment, and critique outcomes, create or update:
- Market cards: competitive landscape, market gaps, positioning patterns.
- Prior art cards: key approaches, when they work, when they fail.
- Feasibility cards: resource heuristics, timeline patterns, common blocker categories.
- Goal pattern cards: how to scope goals, common overreach patterns.

### 2. Distill Process Knowledge
From critiques, revisions, risk updates, and milestone adjustments, create or update:
- Critique patterns: common proposal weaknesses and how to preempt them.
- Scope heuristics: when to rescope, when to hold the line.
- Risk patterns: recurring risk categories and mitigation strategies.
- Milestone estimation rules: how to bound timelines, identify dependency traps.

### 3. Write Knowledge Delta
Produce knowledge-delta.yaml with updates array:
- update_id, update_type, scope, operation.
- update_type: domain_knowledge | process_heuristic | critique_pattern | resource_benchmark | scope_rule.
- scope: candidate_reusable | bank_update | project_local.
- operation: create_card | update_card | append_comparison | deprecate_card.
- generated_from: patches, critiques, evidence, scope decisions, risks.
- rule: title, statement, applies_to, anti_examples.
- maturity: candidate | used | validated | canonical | deprecated.

### 4. Write Back to Knowledge Base
Write or update knowledge cards in `_cr/knowledge/`:
- Domain cards: `_cr/knowledge/cards/domain/*.md`
- Process cards: `_cr/knowledge/cards/process/*.md`
- Critique cards: `_cr/knowledge/cards/critique/*.md`

Record knowledge-apply-log.yaml with before/after sha256 hashes.

### 5. Update Goal Ledger
Update `state/goal-ledger.yaml` for any goals that were strengthened, weakened, rescoped, or deleted during the round.

## Output Contract

```yaml
knowledge-delta.yaml:
  schema_version: "1.0.0"
  round_id: integer
  no_update_justification: string (optional)
  updates:
    - update_id: KDU-###
      update_type: domain_knowledge | process_heuristic | critique_pattern | resource_benchmark | scope_rule
      scope: candidate_reusable | bank_update | project_local
      operation: create_card | update_card | append_comparison | deprecate_card
      proposed_card_id: string
      target_path: string
      generated_from:
        patches: [TRC-###]
        critiques: [CRT-###]
        evidence: [E-###]
        scope_decisions: [GL-###]
        risks: [RSK-###]
      rule:
        title: string
        statement: string (>= 10)
        applies_to: [string]
        anti_examples: [string]
      content_summary: string
      maturity: candidate | used | validated | canonical | deprecated

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
- Goal ledger not updated for affected goals.

## Completion Checklist
- [ ] Domain knowledge distilled into cards (market, prior art, feasibility).
- [ ] Process knowledge distilled into rules and patterns (critique, scope, risk, estimation).
- [ ] knowledge-delta.yaml has typed updates with full provenance.
- [ ] Knowledge cards written back to `_cr/knowledge/`.
- [ ] knowledge-apply-log.yaml records before/after hashes.
- [ ] Goal ledger updated for affected goals.

## Handoff
The next stage (`closure`) validates the round, verifies transaction chain integrity, and prepares next-round candidates.
