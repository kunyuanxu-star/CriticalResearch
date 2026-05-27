# Stage 5: Scope Contribution

## Mission
Resolve the proposal's defensible contribution by synthesizing critique outcomes, novelty analysis, and feasibility evidence. Determine which goals are novel, which are feasible, and which constitute the irreducible contribution core. Produce a scope assessment and contribution statement that bounds what the proposal can credibly claim.

This stage enforces **Inv5**: Every proposal must have an explicit, evidence-backed contribution boundary.

## Inputs
- `round:critique-ledger.yaml` — structured critique entries
- `round:review-disposition.yaml` — per-critique dispositions
- `round:proposal-state.yaml` — frozen proposal baseline
- `round:evidence-ledger.yaml` — structured evidence
- `project:documents/proposal.md` — current proposal document

## Outputs
- `scope-assessment.yaml` — goal-by-goal novelty, feasibility, and contribution assessment
- `contribution-statement.yaml` — synthesized contribution boundary and justification

## Allowed Actions
- Read critique ledger, review disposition, proposal state, evidence, and proposal document.
- Classify each goal on novelty and feasibility axes.
- Identify goals that are preempted by prior art.
- Identify goals that face feasibility red flags.
- Determine the irreducible contribution core.
- Flag goals for deletion, rescoping, or strengthening.
- Write scope-assessment.yaml and contribution-statement.yaml.

## Forbidden Actions
- Do not edit proposal document.
- Do not generate patches.
- Do not apply patches.
- Do not silently drop critiques.
- Do not over-claim novelty without evidence support.

## Procedure

### 1. Goal Novelty Assessment
For each goal, assess novelty:
- Does prior art preempt this goal?
- Is the approach genuinely different from existing solutions?
- If novelty is incremental, is the delta defensible?
- Classify: novel | incremental | preempted | uncertain.

### 2. Goal Feasibility Assessment
For each goal, assess feasibility:
- Is there evidence the approach can work?
- Are resource estimates realistic given evidence benchmarks?
- Are there unresolved technical, resource, or timeline blockers?
- Classify: feasible | risky | infeasible | uncertain.

### 3. Contribution Core Identification
Identify the irreducible contribution core:
- Goals that are both novel AND feasible → contribution core.
- Goals that are novel but risky → conditional contribution.
- Goals that are feasible but not novel → support infrastructure.
- Goals that are neither → candidates for deletion or rescoping.

### 4. Scope Boundary Resolution
Based on the contribution core:
- Define minimum viable scope: what must be in the proposal.
- Define maximum defensible scope: the outermost defensible boundary.
- Identify scope tensions: goals that conflict, overlap, or dilute the contribution.
- Flag goals for rescoping with specific recommendations.

### 5. Write Contribution Statement
Produce a synthesized contribution statement:
- Primary contribution (one sentence).
- Supporting contributions (enumerated).
- Explicit non-contributions: what the proposal does NOT claim.
- Novelty justification with evidence refs.
- Feasibility justification with evidence refs.

## Output Contract

```yaml
scope-assessment.yaml:
  schema_version: "1.0.0"
  round_id: integer
  goal_assessments:
    - goal_id: GL-###
      novelty: novel | incremental | preempted | uncertain
      feasibility: feasible | risky | infeasible | uncertain
      evidence_refs: [E###]
      critique_refs: [CRT-###]
      recommendation: keep_as_is | strengthen | rescope | delete | defer
      rationale: string (>= 10 chars)
  contribution_core:
    primary: [GL-###]
    conditional: [GL-###]
    support: [GL-###]
    candidates_for_removal: [GL-###]
  scope_boundaries:
    minimum_viable: [string]
    maximum_defensible: [string]
    tensions: [string]

contribution-statement.yaml:
  schema_version: "1.0.0"
  round_id: integer
  primary_contribution: string (>= 20 chars)
  supporting_contributions: [string]
  explicit_non_contributions: [string]
  novelty_justification:
    statement: string (>= 20 chars)
    evidence_refs: [E###]
  feasibility_justification:
    statement: string (>= 20 chars)
    evidence_refs: [E###]
  scope_decision:
    retained_goals: [GL-###]
    removed_goals: [GL-###]
    rescoped_goals: [GL-###]
```

## Failure Conditions
- No goal assessed as novel.
- No contribution core identified (empty primary).
- Novelty justification missing evidence_refs.
- Feasibility justification missing evidence_refs.
- Primary contribution statement < 20 chars.
- Scope boundaries unresolved (minimum_viable overlap with out_of_scope).

## Completion Checklist
- [ ] Every goal assessed on novelty and feasibility axes.
- [ ] Contribution core identified with primary, conditional, support, and removal candidates.
- [ ] Scope boundaries resolved: minimum viable and maximum defensible.
- [ ] Contribution statement written with evidence-backed novelty and feasibility.
- [ ] Explicit non-contributions documented.

## Handoff
The next stage (`revision_plan`) converts scope decisions and outstanding critiques into concrete revision actions.
