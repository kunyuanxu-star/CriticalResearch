# Stage 10: Closure

## Mission
Validate the entire experiment round, verify transaction chain integrity, document unresolved issues, and produce structured next-round candidates. The round must be a gateway, not a wall.

Every closure must expose unresolved issues and next-round candidates.

## Inputs
- `round:knowledge-delta.yaml` — structured knowledge transaction
- `round:validation-obligations.yaml` — validation specs
- `round:review-disposition.yaml` — per-critique dispositions
- `round:patch-trace.yaml` — traceability matrix

## Outputs
- `next-round-targets.yaml` — 3 structured next-round options with rationale
- `round-summary.yaml` — round summary and remaining risks

## Allowed Actions
- Read all round artifacts.
- Run full validator pipeline.
- Verify transaction chain integrity.
- Check for unresolved human decisions in review-disposition.yaml.
- Produce next-round-targets.yaml with 3 candidates.
- Write round-summary.yaml with summary and remaining_risks.

## Forbidden Actions
- Do not modify any artifact.
- Do not create new content.
- Do not modify experiment plan.
- Do not close if validators fail or human decisions are pending.

## Procedure

### 1. Run Validator Pipeline
Execute all hard validators:
- Schema validation for all YAML artifacts.
- Artifact presence per artifact registry.
- Stage manifest consistency (10 stages).
- Prompt existence and section checks.
- Full-experiment coverage verification.
- Methodology-hypothesis link validation.
- Critique ledger validation (medium+ have evidence_refs).
- Reference bidirectional link checks.
- Patch trace validation.
- Validation obligation completeness.
- Patch application verification.
- Knowledge delta quality and apply-log writeback.
- Human gate checks (no pending decisions in review-disposition.yaml).
- Experiment plan completeness.

### 2. Verify Transaction Chain
Ensure the causal chain is intact:
contract → experiment_state → methodology_design → experiment_critical_review → experiment_plan → revision_plan → apply_experiment_patch → validation_obligations → knowledge_delta.

### 3. Check Human Decisions
Review review-disposition.yaml for any status == pending_human_decision.
If any exist, the round CANNOT close. Document them as blockers.

### 4. Produce Next-Round Candidates
Create exactly 3 structured next-round candidates:
- candidate_id, title, rationale (>= 10 chars).
- linked_critiques, linked_hypotheses.
- priority: high | medium | low.

### 5. Write Round Summary
Produce round-summary.yaml with:
- summary (>= 20 chars).
- all_stages_complete: true.
- remaining_risks (>= 1 item).

## Output Contract

```yaml
next-round-targets.yaml:
  schema_version: "1.0.0"
  round_id: integer
  candidates:
    - candidate_id: NRC-###
      title: string (>= 5 chars)
      rationale: string (>= 10 chars)
      linked_critiques: [CRT-###]
      linked_hypotheses: [HYP-###]
      priority: high | medium | low

round-summary.yaml:
  schema_version: "1.0.0"
  round_id: integer
  summary: string (>= 20 chars)
  all_stages_complete: true
  remaining_risks: [string] (>= 1 item)
  unresolved_human_decisions: [string] (empty if none)
```

## Failure Conditions
- Any hard validator fails.
- Transaction chain broken.
- Pending human decisions exist in review-disposition.yaml.
- Fewer than 3 next-round candidates.
- Any candidate missing rationale < 10 chars.
- round-summary summary < 20 chars.
- No remaining risks documented.

## Completion Checklist
- [ ] All 10 stages complete.
- [ ] All hard validators passed.
- [ ] Transaction chain intact.
- [ ] No pending human decisions.
- [ ] Knowledge written back.
- [ ] 3 next-round candidates documented.
- [ ] Remaining risks documented.

## Full-Experiment Coverage Requirement
Round closure must verify that the full experiment was covered across all stages, not just the primary target.

## Handoff
This is the final stage. After closure, the experiment round is complete and a new round can be opened.
