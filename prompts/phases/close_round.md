# Phase: close_round

## Mission
Validate the entire round: run the full validator pipeline, verify transaction chain integrity, produce closure report. This phase does NO new work — only validation and reporting.

## Inputs
- All round artifacts (S01-S36 outputs)

## Outputs
- `closure-report.yaml`

## Allowed Actions
- Read all round artifacts.
- Run full validator pipeline.
- Verify transaction chain integrity.
- Produce closure report with summary and remaining risks.

## Forbidden Actions
- Do not modify any artifact.
- Do not create new content.
- Do not edit paper draft.
- Do not close if validators fail.

## Procedure
1. Run `cr close-round <project>` which executes all 22 hard validators.
2. If any hard gate fails: do NOT close. Report failures.
3. Verify transaction chain: source→note→evidence→matrix→critique→disposition→patch→diff→knowledge.
4. Write closure-report.yaml with summary and remaining_risks.
5. Only after all validators pass: mark round complete.

## Output Contract
```yaml
summary: string (>=20 chars)
all_phases_complete: true
remaining_risks: [string] (>=1)
```

## Failure Conditions
- Any hard validator fails.
- Transaction chain broken.
- closure-report summary <20 chars.
- No remaining risks documented.

## Completion Checklist
- [ ] All 37 phases complete.
- [ ] All 22 hard validators passed.
- [ ] Transaction chain intact.
- [ ] Knowledge written back.
- [ ] Next-round targets documented.


## Full-Paper Coverage Requirement

This phase must operate over the entire paper, not only over the current round objective.

You must inspect all required sections, claims, assumptions, baselines, and evaluation items listed in `full-paper-coverage-plan.yaml`.

The current round objective determines priority and emphasis, but it must not narrow coverage.

Your output artifact must include:

```yaml
full_paper_coverage:
  sections_checked: []
  claims_checked: []
  assumptions_checked: []
  baselines_checked: []
  evaluation_items_checked: []
  omissions: []

objective_relevance:
  level: direct | indirect
  explanation: ""
  objective_specific_findings: []
```

If any required item is not checked, this phase must not be marked complete.

## Handoff
This is the final phase. After close_round, the round is complete and a new round can be opened.
