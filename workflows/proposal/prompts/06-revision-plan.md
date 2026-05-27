# Stage 6: Revision Plan

## Mission
Turn every accepted critique and scope decision into a concrete revision. Produce a revision-plan.yaml with goal-level, structure-level, and evidence-level revisions. Resolve human decisions for contribution-scope changes. No critique may idle.

This stage enforces **Inv6**: Every accepted critique must produce a revision decision.

## Inputs
- `round:critique-ledger.yaml` — structured critique entries
- `round:review-disposition.yaml` — per-critique dispositions
- `round:scope-assessment.yaml` — goal-level scope decisions
- `round:contribution-statement.yaml` — synthesized contribution boundary

## Outputs
- `revision-plan.yaml` — goal/structure/evidence-level revision decisions

## Allowed Actions
- Read critique ledger, review disposition, scope assessment, and contribution statement.
- Classify each accepted critique into revision level (goal | structure | resource | evidence).
- Write revision decisions with rationale.
- Flag human decisions for contribution-scope changes.
- Link revisions to source dispositions and critiques.

## Forbidden Actions
- Do not edit proposal document.
- Do not generate patches.
- Do not apply patches.
- Do not silently drop critiques.

## Procedure

### 1. Classify Revisions
For every disposition with status != rejected:
- Determine revision level: goal | structure | resource | evidence.
- goal: changes to goal text, scope, priority, success metric, or deletion.
- structure: changes to section order, argument flow, milestone structure.
- resource: changes to budget, timeline, personnel, infrastructure estimates.
- evidence: changes to citations, evidence presentation, or calls for new evidence.

### 2. Incorporate Scope Decisions
For goals marked for removal or rescoping in scope-assessment.yaml:
- Create revision entries that trace to the scope assessment.
- Ensure every scope decision has a corresponding revision.

### 3. Resolve Dependencies
If multiple revisions affect the same goal or section, order them:
- Weaken before delete.
- Rescope before strengthen.
- Resource before structure.

### 4. Human Decision Gates
If a revision affects the contribution core, primary contribution statement, or scope boundaries:
- Status = pending_human_decision.
- Document exact decision needed, why it matters, evidence found, options with benefit/risk, recommendation, affected goals, consequence of no decision.

### 5. Write Revision Plan
Each revision entry must have:
- revision_id, level, decision, rationale.
- source_dispositions (DSP-### refs).
- source_critiques (CRT-### refs).
- target_sections, target_goals.
- status: pending_human_decision | approved | blocked | implemented.

## Output Contract

```yaml
revision-plan.yaml:
  schema_version: "1.0.0"
  round_id: integer
  revisions:
    - revision_id: REV-###
      level: goal | structure | resource | evidence
      decision: string (>= 5 chars)
      rationale: string (>= 10 chars)
      source_dispositions: [DSP-###]
      source_critiques: [CRT-###]
      target_sections: [string]
      target_goals: [GL-###]
      status: pending_human_decision | approved | blocked | implemented
  no_revision_reason: string (>= 10 chars, optional)
```

## Failure Conditions
- Any accepted critique has no corresponding revision.
- Any revision missing rationale < 10 chars.
- Any contribution-core change not flagged for human decision.
- Revision plan empty when dispositions exist.
- Scope removal decisions lack corresponding revision entries.

## Completion Checklist
- [ ] Every accepted critique has a revision decision.
- [ ] Revisions classified by level (goal, structure, resource, evidence).
- [ ] Scope decisions incorporated as revisions.
- [ ] Human decisions flagged for contribution-core changes.
- [ ] Dependencies between revisions resolved.
- [ ] revision-plan.yaml is valid YAML.

## Handoff
The next stage (`apply_proposal_patch`) transforms revision decisions into concrete document patches and applies them to the proposal document.
