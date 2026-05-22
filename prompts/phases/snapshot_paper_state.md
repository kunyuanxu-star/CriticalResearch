# Phase: snapshot_paper_state

## Mission
Freeze the current paper state: thesis, research object, problem setting, target property, claims, assumptions, baselines, evaluation contract, fragile claims, and at-risk sections. This phase creates the baseline against which all subsequent phases operate.

## Inputs
- `writing/paper-draft.md` — current paper draft
- `state/claim-ledger.yaml` — existing claim definitions

## Outputs
- `paper-state.yaml` — frozen paper snapshot

## Allowed Actions
- Read paper draft and claim ledger.
- Extract and structure the paper's thesis, claims, assumptions, baselines, evaluation contract.
- Identify fragile claims and at-risk sections.
- Write paper-state.yaml only.

## Forbidden Actions
- Do not search for external sources.
- Do not generate critique.
- Do not modify paper draft.
- Do not generate patches.
- Do not create new knowledge.

## Procedure
1. Read `writing/paper-draft.md` and `state/claim-ledger.yaml`.
2. Extract the thesis statement. Ensure it is one sentence.
3. List every core claim with claim_id, text, scope, assumption, and evidence_status.
4. Identify the research object type (system, measurement, theory, etc.).
5. Document current baselines and the evaluation contract.
6. Flag at least one fragile claim with a specific fragility_reason (>=10 chars).
7. Flag at-risk sections with specific vulnerabilities.

## Output Contract
```yaml
core_claims[*]:
  claim_id: string (non-empty)
  scope: string (non-empty, >=10 chars)
  assumption: string (non-empty, >=10 chars)
  evidence_status: none|anecdotal|partial|strong|conclusive
fragile_claims[*]:
  claim_id: string
  fragility_reason: string (>=10 chars)
at_risk_sections[*]:
  section_anchor: string
  risk_type: string
  vulnerability: string (>=10 chars)
```

## Failure Conditions
- No core claims extracted.
- Any claim missing scope, assumption, or evidence_status.
- No fragile claim identified or fragility_reason is <10 chars.
- Thesis statement is empty or placeholder text.

## Completion Checklist
- [ ] Every core claim has claim_id, scope, assumption, evidence_status.
- [ ] At least one fragile claim with substantive reason.
- [ ] Thesis statement is one sentence.
- [ ] Evaluation contract documented.
- [ ] paper-state.yaml is valid YAML.


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
The next phase (`load_project_knowledge`) will load knowledge cards relevant to the claims and risks identified here.
