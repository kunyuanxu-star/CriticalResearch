# Phase: define_round_risk

## Mission
Define the single primary risk this round attacks. The risk must be concrete, bound to a claim or section, and describe the reviewer impact if unaddressed. Secondary risks may also be listed.

## Inputs
- `paper-state.yaml` — frozen paper snapshot
- `loaded-knowledge.yaml` — loaded knowledge cards

## Outputs
- `round-risk.yaml` — round risk definition

## Allowed Actions
- Read paper-state and loaded knowledge.
- Analyze paper claims and sections for vulnerabilities.
- Define primary risk type from valid enumeration.
- Bind risk to specific claim_id or section_anchor.
- Describe reviewer impact concretely.

## Forbidden Actions
- Do not search for external sources.
- Do not generate critique or patches.
- Do not edit paper draft.
- Do not propose solutions or fixes.

## Procedure
1. Review fragile_claims and at_risk_sections from paper-state.yaml.
2. Review loaded knowledge for known risk patterns.
3. Select the single most dangerous risk as primary_risk.
4. Classify the risk type: novelty_risk, baseline_risk, evidence_risk, evaluation_risk, writing_risk, assumption_risk, scope_risk, or thesis_risk.
5. Bind the risk to at least one claim_id or section_anchor.
6. Describe what happens if a reviewer exploits this risk (reviewer_impact).
7. Optionally list secondary_risks.

## Output Contract
```yaml
primary_risk:
  risk_type: string (must be from valid enum)
  linked_claim_id: string (or section_anchor, at least one required)
  linked_section_anchor: string
  description: string (>=20 chars)
  reviewer_impact: string (>=20 chars)
```

## Failure Conditions
- primary_risk.risk_type not in valid enum.
- No claim_id or section_anchor bound to primary risk.
- description or reviewer_impact is <20 chars.

## Completion Checklist
- [ ] Primary risk type from valid enumeration.
- [ ] Risk bound to claim_id or section_anchor.
- [ ] Reviewer impact described concretely.
- [ ] Round-risk.yaml is valid YAML.

## Handoff
The next phase (`freeze_round_scope`) will constrain which claims and sections are in scope based on this risk.
