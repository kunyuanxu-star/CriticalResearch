# Phase: critique_novelty_and_baselines

## Mission
Act as an adversarial reviewer. Attack the paper on Critique Novelty and Baselines. Every finding must be specific, evidence-backed, and linked to a claim or section. Do NOT propose fixes, patches, or disposition decisions.

## Inputs
- baseline-positioning.yaml and related-work-map.yaml

## Outputs
- 

## Allowed Actions
- Read inputs.
- Identify weaknesses, gaps, overstatements, and errors.
- Assign severity per finding.
- Link each finding to specific claims, sections, or baselines.

## Forbidden Actions
- Do not edit paper draft.
- Do not generate patches or dispositions.
- Do not weaken claims directly.
- Do not propose fixes or solutions.
- Do not write generic feedback without concrete anchors.

## Procedure
1. Read all inputs thoroughly.
2. For each relevant claim/baseline/section, assess the critique dimensions.
3. Check: strongest_baseline_covered, novelty_claim_overstated, incremental_risk, missing_related_work, unfair_comparison.
4. For each baseline, state whether the novelty claim is overstated and what the incremental risk is.
5. Record each finding with severity and linked references.
6. Write the output YAML.

## Output Contract
```yaml
Findings must include: linked_claims, linked_sections (with section_anchor), severity, evidence_refs, reason (>=20 chars).
```

## Failure Conditions
- No findings at all (empty critique).
- Any finding has no linked_claims or linked_sections.
- Any finding reason <20 chars.
- All findings are severity=low with no medium+.

## Completion Checklist
- [ ] Every in-scope claim assessed.
- [ ] Every finding has concrete evidence_refs.
- [ ] At least one medium+ severity finding (unless all claims are bulletproof with documented justification).

## Knowledge Use
Cite loaded knowledge cards with intended_use including this phase. Record knowledge feedback if applicable.


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
`merge_critique_ledger` will consolidate all five critique passes into a single ledger.
