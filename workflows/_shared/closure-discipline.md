# Closure Discipline

This is a shared discipline document referenced by stage prompts across all workflows. It defines the validator pipeline, round closure checklist, and next-round-targets generation rules.

## Core Principle

A round is not complete until every validator passes. "Close enough" is not closed. Validators are the gate — they enforce invariants that the stage prompts alone cannot guarantee.

## Validator Pipeline

Closure runs validators in this order:

### Engine Validators (all workflows)
1. **Project validator** — project.yaml is valid, document registry is consistent
2. **Round contract validator** — contract.yaml is well-formed, workflow_id is valid, mutable_document exists
3. **Workflow state validator** — all stages are complete, no blockers without disposition
4. **Single mutable document validator** — exactly one document received writes this round
5. **Target units validator** — all modified units exist in the unit registry
6. **Read-only context validator** — no read-only documents received writes
7. **Patch trace validator** — every patch has a complete critique→disposition→revision→diff chain
8. **Document diff validator** — every text change in the mutable document has a corresponding diff entry
9. **Knowledge delta validator** — knowledge-delta.yaml exists and is well-formed
10. **Round closure validator** — all required outputs are present

### Workflow-Specific Validators
After engine validators pass, the workflow's own validators run. These enforce workflow-specific invariants (e.g., paper: claim alignment, evidence grounding; survey: taxonomy coherence, comparison fairness).

## Closure Checklist

Before calling `cr round close`, confirm:

- [ ] All stages in `stage_order` are marked `complete`
- [ ] No stage is `blocked` without a recorded human decision
- [ ] `patch-trace.yaml` has an entry for every applied patch
- [ ] `document-diff.yaml` has a before/after entry for every text change
- [ ] `knowledge-delta.yaml` exists (or an explicit no-delta justification)
- [ ] All required outputs from the round contract are present
- [ ] No validator failures remain
- [ ] `next-round-targets.yaml` is generated if the round identified follow-up work

## Next-Round Targets

If the round discovered work that belongs in a future round, generate `next-round-targets.yaml`:

```yaml
next_round_targets:
  - document: paper
    units: [paper.evaluation]
    objective: "Add sensitivity analysis for workload skew parameter"
    priority: high
    rationale: "Reviewer critique CR-007 identified missing sensitivity analysis"
  - document: design-doc
    units: [design.caching]
    objective: "Update cache eviction design to reflect paper's new claim about read-heavy workloads"
    priority: medium
    rationale: "Paper claim change implies design change"
```

Next-round targets are advisory — they inform the next round's contract but do not constrain it.

## Closure Failure

If `cr round close` fails:
1. Read the failing validator's output
2. Fix the artifact the validator flagged
3. Re-run `cr round close` — do not attempt to close manually
4. If the same validator fails repeatedly, check whether the fix addresses the root cause, not just the symptom

## Human Decision Required

If a stage recorded a blocker that requires human input:
- The round CANNOT close until the human decision is recorded
- Record the decision in the workflow state
- Re-run any stages affected by the decision
- Then retry closure

## Post-Closure

After successful closure:
- Knowledge cards are promoted to the project knowledge store
- Round artifacts are archived
- The mutable document is ready for the next round
