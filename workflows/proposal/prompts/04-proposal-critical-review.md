# Stage 4: Proposal Critical Review

## Mission
Critically review the proposal as a hostile but fair reviewer. This stage applies adversarial scrutiny to every claim the proposal makes: is the problem real? Is the scope controllable? Are the research questions clear? Is the contribution meaningful? Is the technical approach credible? Are the risks honestly assessed? Are the milestones executable?

This stage is part of the **proposal workflow**. It must produce a structured critical review that the revision plan stage can reason about directly. A critique that says "could be better" is worthless. Every critique must identify a specific defect, explain why it matters, and indicate what must change.

## Inputs
- `proposal-state.yaml` — frozen proposal baseline with problem, goals, scope, assumptions, risks, milestones
- `feasibility-research.yaml` — technical feasibility assessment, resource estimates, comparable efforts
- `workflows/proposal/profile.md` — proposal workflow semantics and domain rules
- `workflows/proposal/workflow.yaml` — valid patch types and stage structure
- `workflows/_shared/evidence-discipline.md` — evidence adequacy rules
- `workflows/_shared/stage-protocol.md` — stage execution discipline

## Outputs
- `critical-review.yaml` — structured critical review with severity-graded critiques across all review dimensions

## Allowed Actions
- Read proposal state and feasibility research.
- Apply reviewer heuristics: problem reality, scope controllability, research question clarity, contribution quality, technical credibility, risk identification, milestone executability.
- Cross-reference feasibility findings against proposal claims.
- Identify internal contradictions, overclaims, and missing dimensions.
- Write critical-review.yaml with severity-graded, evidence-grounded critiques.

## Forbidden Actions
- Do not modify the proposal document.
- Do not propose solutions (that's Stage 5 and 6).
- Do not generate patches.
- Do not accept weak justifications — this is adversarial review.
- Do not skip a review dimension because the proposal lacks content in that area — document the absence as a finding.

## Procedure

### 1. Problem Reality Review
Examine the problem statement:
- Is the problem demonstrably real, or is it hypothetical?
- Does the feasibility research support that this problem exists in practice?
- Are there concrete stakeholders who would benefit?
- Is the problem scope appropriate — not too broad, not too narrow?
- Would solving this problem change anything material?

### 2. Scope Controllability Review
Examine the scope declarations:
- Is the scope bounded by explicit, falsifiable criteria?
- Are in-scope and out-of-scope clearly delineated?
- Could scope creep occur between milestones without detection?
- Are the non-goals genuinely non-goals, or are they deferred goals in disguise?
- Does the feasibility research suggest scope adjustments?

### 3. Research Question Review
Examine the research questions:
- Are they well-formed: specific, falsifiable, non-trivial?
- Do they align with the problem statement and goals?
- Are there missing questions that should be asked?
- Are any questions answerable without the proposed work?
- Is the contribution statement clear and non-inflated?

### 4. Contribution Quality Review
Assess the claimed contribution:
- Is the contribution stated precisely, or is it vague and aspirational?
- Would achieving the contribution advance the field?
- Is the contribution scoped to what the milestones actually deliver?
- Are there hidden dependencies on unproven components?
- Is the contribution distinguishable from comparable efforts?

### 5. Technical Credibility Review
Cross-reference the technical approach against feasibility findings:
- Does the approach address the stated problem, or a different one?
- Are there gaps between what's proposed and what's feasible?
- Do the resource estimates support the timeline?
- Are technical assumptions validated or speculated?
- Are there technical risks not captured in the risk register?

### 6. Risk Identification Review
Audit the risk register:
- Are all feasibility-identified risks present?
- Are likelihood/impact assessments consistent with feasibility findings?
- Are mitigations concrete and actionable?
- Are there missing risk categories (people, schedule, external dependency)?
- Is the highest-severity risk appropriately flagged?

### 7. Milestone Executability Review
Evaluate milestone realism:
- Does each milestone have a concrete, verifiable deliverable?
- Are dependency chains complete and acyclic?
- Are timelines consistent with resource estimates?
- Are there milestones that gate on unproven components?
- Would a milestone failure cascade into later milestones?

### 8. Internal Consistency Review
Check for contradictions:
- Goals that depend on out-of-scope work.
- Risks that contradict assumptions.
- Milestone deliverables that exceed scope.
- Resource estimates inconsistent with timeline.

### 9. Grade and Prioritize
Assign severity to every finding:
- `fatal`: blocks the proposal — must be resolved before proceeding.
- `high`: substantially weakens the proposal — should be resolved in this round.
- `medium`: moderate concern — should be addressed but not blocking.
- `low`: minor — can be noted and deferred.

### 10. Write Critical Review
Write `critical-review.yaml` with all findings, severity, evidence refs, and required actions.

## Output Contract

```yaml
critical-review.yaml:
  schema_version: "1.0.0"
  round_id: integer

  review_summary:
    total_findings: integer
    fatal: integer
    high: integer
    medium: integer
    low: integer
    review_status: passed | conditional | blocked

  critiques:
    - critique_id: string
      dimension: problem_reality | scope_controllability | research_question | contribution_quality | technical_credibility | risk_identification | milestone_executability | internal_consistency
      severity: fatal | high | medium | low
      finding: string (>= 20 chars)
      evidence_refs: [string]
      required_action: string (>= 20 chars)
      affected_goals: [string]
      affected_milestones: [string]
```

## Failure Conditions
- Fewer than 3 findings across all review dimensions.
- No finding with severity fatal or high.
- Any fatal finding without evidence refs.
- Any finding with finding text < 20 chars.
- Any finding with no required_action.

## Completion Checklist
- [ ] Problem reality reviewed with evidence grounding.
- [ ] Scope controllability assessed with explicit boundaries.
- [ ] Research questions evaluated for clarity and falsifiability.
- [ ] Contribution quality assessed against comparable efforts.
- [ ] Technical credibility cross-referenced with feasibility.
- [ ] Risk register audited for completeness and coherence.
- [ ] Milestone executability validated against resource estimates.
- [ ] Internal consistency checked for contradictions.
- [ ] All findings severity-graded with evidence refs.
- [ ] critical-review.yaml is valid YAML.

## Handoff
The next stage (`scope_strategy`) uses the critical review to make scope decisions — what stays, what gets narrowed, and what gets deferred.
