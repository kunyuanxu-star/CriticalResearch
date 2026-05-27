# Stage 4: Revision Strategy

## Mission
Turn every accepted critique into a concrete revision decision. Produce a revision-plan.yaml with claim-level, structure-level, and evidence-level revisions. Resolve human decisions for thesis-level changes. No critique may idle.

This stage enforces **Inv3**: Every accepted critique must produce a revision decision.

## Inputs
- `round:critique-ledger.yaml` — structured critique entries
- `round:review-disposition.yaml` — per-critique dispositions

## Outputs
- `revision-plan.yaml` — claim/structure/evidence-level revision decisions

## Allowed Actions
- Read critique ledger and review disposition.
- Classify each accepted critique into revision level (claim | structure | evidence).
- Write revision decisions with rationale.
- Flag human decisions for thesis-level changes.
- Link revisions to source dispositions and critiques.

## Forbidden Actions
- Do not edit paper draft.
- Do not generate patches.
- Do not apply patches.
- Do not silently drop critiques.

## Procedure

### 1. Classify Revisions
For every disposition with status != rejected:
- Determine revision level: claim | structure | evidence.
- claim: changes to claim text, scope, strength, or deletion.
- structure: changes to section order, paragraph structure, figure/table placement.
- evidence: changes to citations, evidence presentation, or calls for new evidence.

### 2. Resolve Dependencies
If multiple revisions affect the same claim or section, order them:
- Weaken before delete.
- Reframe before strengthen.
- Structure before evidence.

### 3. Human Decision Gates
If a revision affects thesis, baseline, assumptions, contribution, or evaluation priority:
- Status = pending_human_decision.
- Document exact decision needed, why it matters, evidence found, options with benefit/risk, recommendation, affected sections, consequence of no decision.

### 4. Write Revision Plan
Each revision entry must have:
- revision_id, level, decision, rationale.
- source_dispositions (DSP-### refs).
- source_critiques (CRT-### refs).
- target_sections, target_claims.
- status: pending_human_decision | approved | blocked | implemented.

## Output Contract

```yaml
revision-plan.yaml:
  schema_version: "1.0.0"
  round_id: integer
  revisions:
    - revision_id: REV-###
      level: claim|structure|evidence
      decision: string (>= 5 chars)
      rationale: string (>= 10 chars)
      source_dispositions: [DSP-###]
      source_critiques: [CRT-###]
      target_sections: [string]
      target_claims: [CLM-###]
      status: pending_human_decision|approved|blocked|implemented
  no_revision_reason: string (>= 10 chars, optional)
```

## Failure Conditions
- Any accepted critique has no corresponding revision.
- Any revision missing rationale < 10 chars.
- Any thesis-level change not flagged for human decision.
- Revision plan empty when dispositions exist.

## Completion Checklist
- [ ] Every accepted critique has a revision decision.
- [ ] Revisions are classified by level.
- [ ] Human decisions flagged for thesis-level changes.
- [ ] Dependencies between revisions resolved.
- [ ] revision-plan.yaml is valid YAML.

## Full-Paper Coverage Requirement
Revisions must address critiques across the full paper, not just the primary target area.

## Handoff
The next stage (`s5_writing_strategy`) turns revision decisions into a concrete writing and patch plan.
