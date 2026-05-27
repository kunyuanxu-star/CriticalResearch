# Stage 9: Knowledge Delta

## Mission
Distill experiment-round learning into reusable global knowledge. Capture methodology patterns, measurement lessons, analysis insights, validity threat patterns, and experimental design heuristics. Write knowledge cards back to the global knowledge base. Experiment-round learning must escape into the global knowledge base.

Every experiment round must produce a knowledge delta.

## Inputs
- `round:critique-ledger.yaml` — structured critique entries
- `round:patch-trace.yaml` — traceability matrix
- `round:methodology-design.yaml` — complete methodology specification
- `round:validation-protocols.yaml` — validation protocols

## Outputs
- `knowledge-delta.yaml` — structured knowledge transaction
- `knowledge-apply-log.yaml` — proof of writeback to global knowledge base

## Allowed Actions
- Read critique ledger, patch trace, methodology design, and validation protocols.
- Distill methodology knowledge: design patterns, protocol templates, control strategies.
- Distill measurement knowledge: instrument evaluations, validity evidence patterns, reliability benchmarks.
- Distill analysis knowledge: statistical test selection heuristics, power analysis patterns, assumption checking protocols.
- Distill validity knowledge: threat patterns, mitigation strategies, detection heuristics.
- Write knowledge-delta.yaml with typed updates.
- Write knowledge cards to `_cr/knowledge/` with maturity tracking.
- Record knowledge-apply-log.yaml with before/after hashes.

## Forbidden Actions
- Do not modify experiment plan.
- Do not generate patches.
- Do not modify hypothesis ledger.
- Do not write generic advice without specific trigger and scope.

## Procedure

### 1. Distill Methodology Knowledge
From the methodology design and critiques, create or update:
- Design pattern cards: when to use each design type, tradeoffs.
- Protocol template cards: reusable manipulation, measurement, control protocols.
- Control strategy cards: confound taxonomies and mitigation patterns.

### 2. Distill Measurement Knowledge
From measurement protocols and validation, create or update:
- Instrument evaluation cards: validity evidence, reliability data, limitations.
- Measurement pattern cards: scheduling strategies, counterbalancing patterns, quality check procedures.
- Construct cards: operationalization approaches, boundary conditions.

### 3. Distill Analysis Knowledge
From the analysis plan and critiques, create or update:
- Statistical test selection cards: when each test is appropriate, assumptions, alternatives.
- Power analysis cards: effect size conventions by domain, sample size heuristics.
- Assumption checking cards: diagnostic procedures, remediation options.

### 4. Distill Validity Knowledge
From validity threat assessments and critiques, create or update:
- Threat pattern cards: common threats by design type, detection signs.
- Mitigation strategy cards: ranked by effectiveness, cost.
- Reviewer pattern cards: common validity objections and preemption strategies.

### 5. Write Knowledge Delta
Produce knowledge-delta.yaml with updates array:
- update_id, update_type, scope, operation.
- update_type: methodology_pattern | measurement_insight | analysis_heuristic | validity_pattern | experimental_principle.
- scope: candidate_reusable | bank_update | project_local.
- operation: create_card | update_card | append_comparison | deprecate_card.
- generated_from: patches, critiques, validation protocols.
- rule: title, statement, applies_to, anti_examples.
- maturity: candidate | used | validated | canonical | deprecated.

### 6. Write Back to Knowledge Base
Write or update knowledge cards in `_cr/knowledge/`:
- Methodology cards: `_cr/knowledge/cards/methodology/*.md`
- Measurement cards: `_cr/knowledge/cards/measurement/*.md`
- Analysis cards: `_cr/knowledge/cards/analysis/*.md`
- Validity cards: `_cr/knowledge/cards/validity/*.md`

Record knowledge-apply-log.yaml with before/after sha256 hashes.

## Output Contract

```yaml
knowledge-delta.yaml:
  schema_version: "1.0.0"
  round_id: integer
  no_update_justification: string (optional)
  updates:
    - update_id: KDU-###
      update_type: methodology_pattern | measurement_insight | analysis_heuristic | validity_pattern | experimental_principle
      scope: candidate_reusable | bank_update | project_local
      operation: create_card | update_card | append_comparison | deprecate_card
      proposed_card_id: string
      target_path: string
      generated_from:
        patches: [PP-###]
        critiques: [CRT-###]
        validations: [VAL-###]
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
- Generic advice without specific trigger and scope.

## Completion Checklist
- [ ] Methodology knowledge distilled into cards.
- [ ] Measurement knowledge distilled into instrument and pattern cards.
- [ ] Analysis knowledge distilled into heuristics and patterns.
- [ ] Validity knowledge distilled into threat and mitigation cards.
- [ ] knowledge-delta.yaml has typed updates.
- [ ] Knowledge cards written back to `_cr/knowledge/`.
- [ ] knowledge-apply-log.yaml records before/after hashes.

## Full-Experiment Coverage Requirement
Knowledge should be generalizable beyond the current experiment's primary target. Capture lessons that apply to future experiments.

## Handoff
The next stage (`closure`) validates the full experiment round and prepares next-round candidates.
