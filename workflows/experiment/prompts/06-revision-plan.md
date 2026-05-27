# Stage 6: Revision Plan

## Mission
Turn every accepted critique and execution plan gap into a concrete revision decision. Produce a revision-plan.yaml with design-level, methodology-level, measurement-level, and analysis-level revisions. Resolve human decisions for experiment-level changes. No critique may idle.

Every accepted critique must produce a revision decision.

## Inputs
- `round:critique-ledger.yaml` — structured critique entries
- `round:review-disposition.yaml` — per-critique dispositions
- `round:experiment-execution-plan.yaml` — step-by-step execution plan

## Outputs
- `revision-plan.yaml` — design/methodology/measurement/analysis-level revision decisions

## Allowed Actions
- Read critique ledger, review disposition, and execution plan.
- Classify each accepted critique into revision level (design | methodology | measurement | analysis).
- Write revision decisions with rationale.
- Flag human decisions for experiment-level changes.
- Link revisions to source dispositions and critiques.

## Forbidden Actions
- Do not modify experiment plan.
- Do not generate patches.
- Do not apply patches.
- Do not silently drop critiques.

## Procedure

### 1. Classify Revisions
For every disposition with status != rejected:
- Determine revision level: design | methodology | measurement | analysis.
- design: changes to experimental design type, control structure, randomization.
- methodology: changes to protocols, procedures, sampling, power analysis.
- measurement: changes to instruments, schedule, validity, reliability plans.
- analysis: changes to statistical tests, models, effect sizes, corrections.

### 2. Resolve Dependencies
If multiple revisions affect the same component or hypothesis, order them:
- Design changes before methodology changes.
- Methodology changes before measurement changes.
- Measurement changes before analysis changes.
- Weaken claims before deleting them.

### 3. Human Decision Gates
If a revision affects primary hypothesis, experimental design type, core instrumentation, or ethical considerations:
- Status = pending_human_decision.
- Document exact decision needed, why it matters, evidence found, options with benefit/risk, recommendation, affected components, consequence of no decision.

### 4. Write Revision Plan
Each revision entry must have:
- revision_id, level, decision, rationale.
- source_dispositions (DSP-### refs).
- source_critiques (CRT-### refs).
- target_components, target_hypotheses.
- status: pending_human_decision | approved | blocked | implemented.

## Output Contract

```yaml
revision-plan.yaml:
  schema_version: "1.0.0"
  round_id: integer
  revisions:
    - revision_id: REV-###
      level: design | methodology | measurement | analysis
      decision: string (>= 5 chars)
      rationale: string (>= 10 chars)
      source_dispositions: [DSP-###]
      source_critiques: [CRT-###]
      target_components: [string]
      target_hypotheses: [HYP-###]
      status: pending_human_decision | approved | blocked | implemented
  no_revision_reason: string (>= 10 chars, optional)
```

## Failure Conditions
- Any accepted critique has no corresponding revision.
- Any revision missing rationale < 10 chars.
- Any experiment-level change not flagged for human decision.
- Revision plan empty when dispositions exist.

## Completion Checklist
- [ ] Every accepted critique has a revision decision.
- [ ] Revisions are classified by level.
- [ ] Human decisions flagged for experiment-level changes.
- [ ] Dependencies between revisions resolved.
- [ ] revision-plan.yaml is valid YAML.

## Full-Experiment Coverage Requirement
Revisions must address critiques across all experimental components, not just the primary target area.

## Handoff
The next stage (`apply_experiment_patch`) applies revisions to the experiment plan and records traceability.
