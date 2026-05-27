# Stage 2: Proposal State

## Mission
Validate and freeze the proposal state snapshot produced in Stage 1. This stage independently verifies the completeness of the proposal state, checks for internal consistency across goals, scope, assumptions, risks, and milestones, and produces a signed-off proposal-state.yaml that all subsequent stages will reference as the authoritative baseline.

This stage enforces **Inv2**: Every round must operate against a frozen, validated proposal state baseline.

## Inputs
- `round:round-contract.yaml` — formalized round contract
- `round:proposal-state.yaml` — initial state snapshot from Stage 1
- `project:documents/proposal.md` — current proposal document

## Outputs
- `proposal-state.yaml` — validated and frozen proposal snapshot (overwrites Stage 1 output)

## Allowed Actions
- Read round contract, proposal state snapshot, and proposal document.
- Validate problem statement substantiveness.
- Cross-check goals against proposal document for completeness.
- Verify scope boundaries are non-overlapping and exhaustive.
- Validate assumption rationale and failure consequences.
- Verify risk likelihood/impact pairings are coherent.
- Check milestone timeline feasibility and dependency chains.
- Freeze proposal-state.yaml as the authoritative round baseline.

## Forbidden Actions
- Do not search for external sources.
- Do not generate critique.
- Do not modify proposal document.
- Do not generate patches.
- Do not alter goal definitions beyond validation fixes.

## Procedure

### 1. Problem Statement Validation
Verify the problem statement exists, is substantive (>= 20 chars), and matches the proposal document's framing. If the statement is vague, placeholder, or inconsistent with the document, flag and repair.

### 2. Goal Completeness Check
For every goal:
- Verify it appears in the proposal document or is a well-defined sub-goal.
- Check that success_metric is concrete and falsifiable.
- Ensure priority is consistent with document emphasis.
- Add any goals present in the document but missing from the snapshot.

### 3. Scope Boundary Validation
Verify:
- In-scope and out-of-scope are non-overlapping.
- Every goal falls within in-scope.
- Scope boundaries match document content.
- No scope creep between contract and document.

### 4. Assumption Audit
For every assumption:
- Rationale is substantive (>= 10 chars).
- Failure consequence is explicit — what breaks if the assumption is wrong.
- Assumptions do not silently encode goals.

### 5. Risk Coherence Check
For every risk:
- Likelihood and impact pairings are plausible.
- Mitigation is specific and actionable (>= 10 chars).
- Risks align with fragile goals identified in Stage 1.

### 6. Milestone Feasibility Check
Verify:
- At least 3 milestones exist.
- Each has a concrete deliverable, timeline, and dependencies.
- Dependency chain is acyclic and logically ordered.
- Timelines are plausible given scope.

### 7. State Freeze
Write the validated proposal-state.yaml as the authoritative baseline. All subsequent stages reference this frozen snapshot.

## Output Contract

```yaml
proposal-state.yaml:
  validated: true
  validation_notes: [string]
  frozen_at: ISO8601
  schema_version: "1.0.0"
  round_id: integer
  problem_statement: string (>= 20 chars)
  goals:
    - goal_id: GL-###
      description: string (>= 10 chars)
      priority: high | medium | low
      success_metric: string (>= 10 chars)
  scope:
    in_scope: [string]
    out_of_scope: [string]
  assumptions:
    - assumption_id: ASM-###
      statement: string (>= 10 chars)
      rationale: string (>= 10 chars)
      failure_consequence: string
  risks:
    - risk_id: RSK-###
      description: string (>= 10 chars)
      likelihood: high | medium | low
      impact: high | medium | low
      mitigation: string (>= 10 chars)
  milestones:
    - milestone_id: MST-###
      title: string (>= 5 chars)
      deliverable: string (>= 10 chars)
      timeline: string
      dependencies: [string]
```

## Failure Conditions
- Problem statement fails validation (vague, placeholder, inconsistent).
- Goal missing from proposal document with no justification.
- Scope boundaries overlap or are incomplete.
- Any assumption missing rationale or failure consequence.
- Risk likelihood/impact pair implausible.
- Fewer than 3 milestones or cyclic dependency chain.
- proposal-state.yaml not marked as validated and frozen.

## Completion Checklist
- [ ] Problem statement validated as substantive.
- [ ] All goals verified against proposal document.
- [ ] Scope boundaries non-overlapping and exhaustive.
- [ ] Assumptions have rationale and failure consequences.
- [ ] Risks coherent and actionable.
- [ ] Milestones feasible and dependency chain acyclic.
- [ ] proposal-state.yaml frozen as authoritative baseline.

## Handoff
The next stage (`feasibility_research`) executes evidence gathering guided by the frozen proposal state.
