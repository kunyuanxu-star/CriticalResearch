# Stage 8: Risk and Milestone Update

## Mission
Re-evaluate the risk register and milestone tracker against the patched proposal document. Update risk likelihood, impact, and mitigation based on new evidence and critique outcomes. Adjust milestone timelines, deliverables, and dependencies to reflect scope decisions and resource obligations. Produce authoritative risk-register.yaml and milestone-tracker.yaml for the round.

This stage enforces **Inv8**: Every round must produce updated risk and milestone tracking.

## Inputs
- `round:patch-trace.yaml` — traceability matrix
- `round:milestone-obligations.yaml` — milestone specs from patch application
- `round:proposal-state.yaml` — frozen proposal baseline
- `project:documents/proposal.md` — patched proposal document
- `round:scope-assessment.yaml` — scope decisions

## Outputs
- `risk-register.yaml` — updated risk tracking
- `milestone-tracker.yaml` — updated milestone tracking

## Allowed Actions
- Read patch trace, milestone obligations, proposal state, proposal document, and scope assessment.
- Re-evaluate each risk against patched document content.
- Update risk likelihood, impact, and mitigation as warranted.
- Add new risks surfaced by critique or scope decisions.
- Close risks that are no longer applicable.
- Adjust milestone timelines, deliverables, and dependencies.
- Add new milestones required by patch obligations.
- Remove or mark completed milestones no longer in scope.
- Write risk-register.yaml and milestone-tracker.yaml.

## Forbidden Actions
- Do not edit proposal document.
- Do not generate patches.
- Do not generate new critique.
- Do not fabricate risk data without evidence.
- Do not alter milestone timelines arbitrarily.

## Procedure

### 1. Risk Re-evaluation
For each risk from proposal-state.yaml:
- Check if the patched proposal mitigates the risk.
- Re-assess likelihood and impact based on new evidence.
- Update mitigation with specific actions (>= 10 chars).
- If a critique or scope decision introduces a new risk, add it with full detail.
- If a risk was specific to a deleted goal, close it with closure_reason.

### 2. Milestone Adjustment
For each milestone from proposal-state.yaml:
- Check if the patched proposal changes the deliverable.
- Adjust timeline based on scope decisions and resource obligations.
- Update dependencies to reflect new or removed goals.
- Verify dependency chain remains acyclic.
- If a milestone was for a removed goal, mark it as cancelled.

### 3. New Milestone Creation
For each milestone-obligations.yaml entry:
- Create a corresponding milestone in milestone-tracker.yaml.
- Link to the obligation and target goal.
- Ensure timeline is consistent with existing milestone schedule.

### 4. Cross-Validation
- Verify risk register covers all fragile goals from proposal state.
- Verify milestone tracker has at least 3 active milestones.
- Verify milestone dependency chain is acyclic.
- Verify no milestone depends on a cancelled milestone.

## Output Contract

```yaml
risk-register.yaml:
  schema_version: "1.0.0"
  round_id: integer
  risks:
    - risk_id: RSK-###
      description: string (>= 10 chars)
      likelihood: high | medium | low
      impact: high | medium | low
      mitigation: string (>= 10 chars)
      source: proposal_state | critique | scope_assessment | patch_trace
      source_refs: [CRT-### | GL-###] (optional)
      status: open | mitigated | closed | accepted
      closure_reason: string (optional, required if closed)

milestone-tracker.yaml:
  schema_version: "1.0.0"
  round_id: integer
  milestones:
    - milestone_id: MST-###
      title: string (>= 5 chars)
      deliverable: string (>= 10 chars)
      timeline: string
      dependencies: [MST-###]
      source: proposal_state | milestone_obligation
      source_obligation: MOB-### (optional)
      target_goal: GL-### (optional)
      status: planned | in_progress | completed | cancelled | blocked
```

## Failure Conditions
- Risk register empty.
- Milestone tracker has fewer than 3 active (non-cancelled) milestones.
- Any risk missing mitigation < 10 chars.
- Any milestone missing deliverable or timeline.
- Cyclic milestone dependency chain detected.
- Risk closed without closure_reason.

## Completion Checklist
- [ ] All base risks re-evaluated against patched proposal.
- [ ] New risks from critique/scope decisions added.
- [ ] All milestones adjusted for scope and resource changes.
- [ ] New milestones created from milestone obligations.
- [ ] Risk register and milestone tracker are coherent and internally consistent.
- [ ] At least 3 active milestones remain after adjustments.

## Handoff
The next stage (`knowledge_delta`) distills round-local learning into reusable global knowledge.
