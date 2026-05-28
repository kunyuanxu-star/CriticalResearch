# Stage 5: Scope Strategy

## Mission
Convert the critical review findings into concrete scope decisions. This stage determines what stays in the proposal, what gets narrowed, and what gets deferred to a future round or a different workflow. The output is a scope strategy that the revision plan stage can translate directly into patches.

This stage is part of the **proposal workflow**. Its role is decision-making, not editing. Every scope decision must cite the critique or feasibility finding that motivates it. No decision may be made without documented rationale.

## Inputs
- `critical-review.yaml` — severity-graded critiques across all review dimensions
- `feasibility-research.yaml` — technical feasibility, resource estimates, comparable efforts
- `workflows/proposal/profile.md` — proposal workflow semantics and domain rules
- `workflows/proposal/workflow.yaml` — valid patch types and stage structure
- `workflows/_shared/evidence-discipline.md` — evidence adequacy rules
- `workflows/_shared/stage-protocol.md` — stage execution discipline

## Outputs
- `scope-strategy.yaml` — scope decisions with explicit boundaries, non-goals, deferred investigations, and rationale

## Allowed Actions
- Read critical review and feasibility research.
- Decide which scope elements stay, get narrowed, or get deferred.
- Define explicit non-goals with rationale.
- Identify deferred investigations with required future workflows.
- Record tradeoffs and decision rationale.
- Write scope-strategy.yaml.

## Forbidden Actions
- Do not modify the proposal document.
- Do not generate patches (that's Stage 7).
- Do not invent new goals or scope beyond what the proposal state defines.
- Do not defer a fatal critique without documenting why it cannot be addressed now.
- Do not narrow scope without citing the critique or feasibility finding that justifies it.

## Procedure

### 1. Load Critique and Feasibility Context
Read `critical-review.yaml` and `feasibility-research.yaml`. Build a decision matrix:
- Every critique maps to a scope decision (accept, narrow, defer, reject).
- Every feasibility finding maps to a scope constraint (must narrow, can proceed, requires data).

### 2. Triage Fatal and High Critiques
Fatal and high-severity critiques demand explicit decisions:
- Accept: the critique is valid and the proposal must change. Record what must change.
- Narrow: the critique is valid but can be addressed by reducing scope rather than changing approach.
- Defer: the critique is valid but requires investigation that belongs in a different round or workflow.
- Reject: the critique is invalid, out of scope, or contradicted by stronger evidence. Cite the counter-evidence.

A fatal critique cannot be deferred without documenting the specific obstacle that prevents addressing it now.

### 3. Define Scope Boundaries
From the decision matrix, produce scope boundaries:
- What stays in scope (and why).
- What is explicitly out of scope (with rationale citing which critique or feasibility constraint).
- What is narrowed (with the specific boundary reduction).
- What is deferred (with required future workflow and risk if skipped).

### 4. Define Non-Goals
Explicit non-goals protect against scope creep:
- Every non-goal must be concrete and falsifiable.
- Every non-goal must cite the critique or feasibility finding that makes it a non-goal.
- Non-goals must not be deferred goals in disguise.

### 5. Identify Deferred Investigations
Some critiques or feasibility findings cannot be resolved within a proposal round:
- Identify which investigations require a survey, experiment, or design round.
- For each: specify required workflow, required data or experiments, estimated effort, risk if deferred.
- Deferred investigations must have clear acceptance criteria for when they are sufficiently resolved.

### 6. Record Tradeoffs
Every scope decision involves a tradeoff:
- What is gained by the decision?
- What is lost or risked?
- What alternative was considered and why was it rejected?
- What would need to change to reverse the decision?

### 7. Cross-Check Against Contract
Verify scope decisions are consistent with:
- The round contract's target and intensity.
- The mutable document constraint (only the proposal document).
- The full-proposal coverage requirement (decisions must cover all affected sections).

### 8. Write Scope Strategy
Write `scope-strategy.yaml` with all decisions, boundaries, non-goals, deferred investigations, and tradeoffs.

## Output Contract

```yaml
scope-strategy.yaml:
  schema_version: "1.0.0"
  round_id: integer

  decision_summary:
    total_critiques: integer
    accepted: integer
    narrowed: integer
    deferred: integer
    rejected: integer
    strategy_status: actionable | partially_blocked | fully_blocked

  scope_boundaries:
    in_scope:
      - element: string
        rationale: string
        source_critiques: [string]
    out_of_scope:
      - element: string
        rationale: string
        source_critiques: [string]
    narrowed:
      - element: string
        original_boundary: string
        new_boundary: string
        rationale: string
        source_critiques: [string]

  non_goals:
    - non_goal: string
      rationale: string
      source_critiques: [string]
      falsifiable: boolean

  deferred_investigations:
    - investigation_id: string
      description: string
      required_workflow: survey | experiment | design | proposal
      required_data: string
      estimated_effort: string
      risk_if_skipped: string
      acceptance_criteria: string
      source_critiques: [string]

  tradeoffs:
    - decision_id: string
      description: string
      gain: string
      loss_or_risk: string
      alternative_considered: string
      alternative_rejected_because: string
      source_critiques: [string]

  critique_dispositions:
    - critique_id: string
      severity: fatal | high | medium | low
      disposition: accept | narrow | defer | reject
      rationale: string
      scope_impact: string
```

## Failure Conditions
- Any fatal critique left without explicit disposition.
- Any scope decision missing source critique or rationale.
- Any non-goal that is actually a deferred goal.
- Any deferred investigation missing required workflow.
- Scope strategy status is `fully_blocked` (no actionable decisions).
- Fewer than 1 non-goal defined.

## Completion Checklist
- [ ] All fatal and high critiques dispositioned.
- [ ] Scope boundaries defined: in-scope, out-of-scope, narrowed.
- [ ] Non-goals defined with rationale and falsifiability.
- [ ] Deferred investigations identified with required workflows.
- [ ] Tradeoffs documented for every scope decision.
- [ ] Cross-checked against contract for consistency.
- [ ] scope-strategy.yaml is valid YAML.

## Handoff
The next stage (`revision_plan`) converts scope decisions into an ordered, dependency-aware patch plan.
