# Stage 3: Feasibility Research

## Mission
Research the technical feasibility of the proposed approach. This stage grounds the proposal in reality by validating technical assumptions, estimating required resources, and comparing against known comparable efforts. A proposal without feasibility research is a wish list, not a plan.

This stage is part of the **proposal workflow**. Every claim about technical feasibility must be evidenced — no assertion may rest on intuition alone. This stage must produce a falsifiable assessment: what can be built, with what resources, in what timeframe, and what could cause it to fail.

## Inputs
- `proposal-state.yaml` — frozen proposal baseline with problem statement, goals, scope, assumptions, risks, milestones
- `contract.yaml` — round scope, target units, intensity
- `workflows/proposal/profile.md` — proposal workflow semantics and domain rules
- `workflows/proposal/workflow.yaml` — valid patch types and stage structure
- `workflows/_shared/evidence-discipline.md` — evidence adequacy rules
- `workflows/_shared/stage-protocol.md` — stage execution discipline

## Outputs
- `feasibility-research.yaml` — technical feasibility assessment with resource estimates, comparable efforts, and risk-anchored feasibility judgments

## Allowed Actions
- Search for comparable efforts, prior art, and technical benchmarks.
- Estimate resources: compute, data, personnel, time, infrastructure.
- Compare proposed approach against known baselines and alternatives.
- Identify technical risks that could make the proposal infeasible.
- Document evidence sources for every feasibility claim.
- Write feasibility-research.yaml.

## Forbidden Actions
- Do not modify the proposal document.
- Do not generate critique (that's Stage 4).
- Do not make scope decisions (that's Stage 5).
- Do not assert feasibility without evidence.
- Do not fabricate resource numbers without a documented basis.

## Procedure

### 1. Load Proposal Context
Read `proposal-state.yaml` and `contract.yaml`. Extract:
- Problem statement and goals (what must be feasible).
- Technical approach description (how it's supposed to work).
- Assumptions (what feasibility depends on).
- Risks (what could make it infeasible).
- Milestones (what must be delivered).

### 2. Technical Assumption Audit
For every assumption in `proposal-state.yaml` that is technical in nature:
- Assess whether the assumption is testable before commitment.
- Identify what evidence would validate or invalidate the assumption.
- Flag assumptions that rest on no prior evidence.

### 3. Comparable Effort Search
Search for projects, papers, systems, or products that attempted similar goals:
- Identify at least 2 comparable efforts.
- For each: what was attempted, what was achieved, what failed, timeline, team size, resource profile.
- Compare the proposal's scope against these baselines.
- If no comparable effort exists, document why and flag as elevated risk.

### 4. Resource Estimation
For each milestone in the proposal state:
- Estimate compute requirements (if applicable).
- Estimate data requirements (if applicable).
- Estimate personnel: roles, skills, person-months.
- Estimate infrastructure: hardware, software, services.
- Estimate calendar time with explicit dependency assumptions.

### 5. Technical Risk Identification
Identify risks that could make the proposal technically infeasible:
- Dependency risks: reliance on unproven components or external systems.
- Scaling risks: approach works at small scale but may not generalize.
- Integration risks: components that must work together but haven't been tested.
- Expertise risks: skills required that the team may not possess.
- Data risks: data availability, quality, or licensing issues.

For each risk, provide a concrete failure mode and an evidence-grounded feasibility judgment.

### 6. Feasibility Judgment
Produce a structured feasibility assessment:
- Overall feasibility: feasible | feasible_with_mitigation | high_risk | infeasible.
- For each goal: independent feasibility with evidence.
- Confidence level: high | medium | low.
- Blockers: any showstoppers that must be resolved before proceeding.

### 7. Write Feasibility Research
Write `feasibility-research.yaml` with all findings, estimates, and judgments.

## Output Contract

```yaml
feasibility-research.yaml:
  schema_version: "1.0.0"
  round_id: integer

  technical_assumptions:
    - assumption_id: string
      statement: string
      testable: boolean
      evidence_status: validated | unvalidated | invalidated
      evidence_ref: string

  comparable_efforts:
    - effort_id: string
      description: string
      outcome: succeeded | partially_succeeded | failed | ongoing
      timeline: string
      team_size: integer
      resource_profile: string
      relevance: direct | partial | tangential
      lessons: string

  resource_estimates:
    compute: string
    data: string
    personnel:
      roles: [string]
      person_months: integer
    infrastructure: string
    calendar_time: string
    basis: string

  technical_risks:
    - risk_id: string
      category: dependency | scaling | integration | expertise | data
      description: string
      failure_mode: string
      likelihood: high | medium | low
      impact: high | medium | low
      mitigation: string
      feasibility_impact: string

  feasibility_judgment:
    overall: feasible | feasible_with_mitigation | high_risk | infeasible
    confidence: high | medium | low
    per_goal:
      - goal_id: string
        feasibility: feasible | feasible_with_mitigation | high_risk | infeasible
        evidence: string
    blockers:
      - description: string
        resolution_required: string
```

## Failure Conditions
- Fewer than 2 comparable efforts documented and none flagged as novel.
- Any technical assumption asserted as true without evidence.
- Resource estimates missing basis or justification.
- Feasibility judgment without per-goal breakdown.
- Any blocker identified without a resolution path.

## Completion Checklist
- [ ] All technical assumptions audited.
- [ ] At least 2 comparable efforts researched and documented.
- [ ] Resource estimates provided for every milestone.
- [ ] Technical risks identified with failure modes.
- [ ] Feasibility judgment produced per goal and overall.
- [ ] feasibility-research.yaml is valid YAML.

## Handoff
The next stage (`proposal_critical_review`) critically reviews the proposal using the feasibility findings as grounding.
