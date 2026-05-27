# Stage 10: Closure

## Mission
Validate the entire round, verify transaction chain integrity, document unresolved issues and open risks, and produce structured next-round candidates. The round must be a gateway, not a wall. A closed round must expose its remaining work and point clearly toward the next increment.

This stage enforces **Inv10**: Every closure must expose unresolved issues and next-round candidates.

## Inputs
- `round:knowledge-delta.yaml` — structured knowledge transaction
- `round:milestone-obligations.yaml` — milestone specs
- `round:review-disposition.yaml` — per-critique dispositions
- `round:risk-register.yaml` — updated risk tracking
- `round:milestone-tracker.yaml` — updated milestone tracking
- `round:patch-trace.yaml` — traceability matrix
- `round:proposal-state.yaml` — frozen proposal baseline
- `project:documents/proposal.md` — patched proposal document

## Outputs
- `next-round-targets.yaml` — 3 structured next-round options with rationale
- `round-summary.yaml` — round summary and remaining risks

## Allowed Actions
- Read all round artifacts and proposal document.
- Run full validator pipeline.
- Verify transaction chain integrity across all 10 stages.
- Check for unresolved human decisions in review-disposition.yaml.
- Verify proposal document structural completeness.
- Produce next-round-targets.yaml with 3 candidates.
- Write round-summary.yaml with summary and remaining_risks.

## Forbidden Actions
- Do not modify any artifact.
- Do not create new content beyond summary and targets.
- Do not edit proposal document.
- Do not close if validators fail or human decisions are pending.

## Procedure

### 1. Run Validator Pipeline
Execute all hard validators:
- Schema validation for all YAML artifacts across 10 stages.
- Artifact presence per artifact registry.
- Stage manifest consistency (10 stages, correct stage order).
- Prompt existence and section checks.
- Proposal structural completeness (problem statement, goals, milestones, risks).
- Evidence-goal link validation.
- Critique ledger validation (medium+ have evidence_refs).
- Reference bidirectional link checks.
- Patch trace validation.
- Milestone obligation completeness.
- Risk register coherence (>= 1 open risk).
- Milestone tracker coherence (>= 3 active milestones).
- Knowledge delta quality and apply-log writeback.
- Human gate checks (no pending decisions in review-disposition.yaml).

### 2. Verify Transaction Chain
Ensure the causal chain is intact across the proposal-specific stage order:
source → evidence → goal-evidence-map → critique → disposition → scope_assessment → revision → patch → diff → risk_register → milestone_tracker → knowledge.

### 3. Check Human Decisions
Review review-disposition.yaml for any status == pending_human_decision.
If any exist, the round CANNOT close. Document them as blockers in unresolved_human_decisions.

### 4. Produce Next-Round Candidates
Create exactly 3 structured next-round candidates:
- candidate_id, title, rationale (>= 10 chars).
- linked_critiques, linked_goals.
- priority: high | medium | low.
- Candidates should address: remaining open risks, weakened goals, infeasible milestones, or unexplored evidence gaps.

### 5. Write Round Summary
Produce round-summary.yaml with:
- summary (>= 20 chars) covering document changes, scope decisions, and risk state.
- all_stages_complete: true.
- remaining_risks (>= 1 item).
- Proposal document delta summary.

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
      linked_goals: [GL-###]
      linked_risks: [RSK-###]
      priority: high | medium | low

round-summary.yaml:
  schema_version: "1.0.0"
  round_id: integer
  summary: string (>= 20 chars)
  all_stages_complete: true
  remaining_risks: [string] (>= 1 item)
  unresolved_human_decisions: [string] (empty if none)
  stages_executed:
    - contract
    - proposal_state
    - feasibility_research
    - proposal_critical_review
    - scope_contribution
    - revision_plan
    - apply_proposal_patch
    - risk_milestone_update
    - knowledge_delta
    - closure
```

## Failure Conditions
- Any hard validator fails.
- Transaction chain broken.
- Pending human decisions exist in review-disposition.yaml.
- Fewer than 3 next-round candidates.
- Any candidate missing rationale < 10 chars.
- round-summary summary < 20 chars.
- No remaining risks documented.
- All 10 stages not recorded in stages_executed.

## Completion Checklist
- [ ] All 10 stages complete and recorded.
- [ ] All hard validators passed.
- [ ] Transaction chain intact across proposal stage order.
- [ ] No pending human decisions.
- [ ] Knowledge written back to global base.
- [ ] Goal ledger updated.
- [ ] 3 next-round candidates documented.
- [ ] Remaining risks documented (>= 1).

## Handoff
This is the final stage. After closure, the round is complete and a new round can be opened.
