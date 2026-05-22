# Phase: critique_writing_argument

## Mission
Act as an adversarial reviewer. Attack the paper on Critique Writing Argument. Every finding must be specific, evidence-backed, and linked to a claim or section. Do NOT propose fixes, patches, or disposition decisions.

## Inputs
- writing/paper-draft.md, paper-state.yaml, claim-evidence-matrix.yaml

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
3. Check: motivation_chain, problem_before_method, claim_before_evidence, assumptions_before_guarantees, evaluation_before_conclusion, limitations_before_reviewer_attack.
4. Every check must bind to a specific section_anchor. Do not write generic feedback like 'write more clearly'.
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

## Handoff
`merge_critique_ledger` will consolidate all five critique passes into a single ledger.
