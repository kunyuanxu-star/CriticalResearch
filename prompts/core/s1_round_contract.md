# Stage 1: Round Contract

## Mission
Formalize user intent into a signed Round Contract. This stage combines document state snapshot, knowledge loading, objective definition, and full-document coverage freeze into a single coherent contract. No research may proceed without a signed contract.

This stage enforces **Inv1**: Every round must start from an explicit Round Contract.

## Inputs
- `documents/<doc-id>.md` — current target document
- `state/claim-ledger.yaml` — existing claim definitions
- `workspace:_cr/knowledge/` — global knowledge cards

## Outputs
- `round-contract.yaml` — formalized contract with target, scope, intensity, required outputs, forbidden scope, success criteria
- `paper-state.yaml` — frozen paper snapshot (embedded in round state)

## Allowed Actions
- Read target document, claim ledger, and knowledge cards.
- Extract and structure thesis, claims, assumptions, baselines, evaluation contract.
- Identify fragile claims and at-risk sections.
- Write round-contract.yaml.
- Record loaded knowledge summary in state.

## Forbidden Actions
- Do not search for external sources.
- Do not generate critique.
- Do not modify target document.
- Do not generate patches.
- Do not limit paper scope beyond forbidden_scope declaration.

## Procedure

### 1. Document State Reconstruction
Read `documents/<doc-id>.md` and `state/claim-ledger.yaml`.
Extract:
- Thesis statement (one sentence).
- Every core claim with claim_id, text, scope, assumption, evidence_status.
- Research object type.
- Current baselines and evaluation contract.
- At least one fragile claim with fragility_reason >= 10 chars.
- At-risk sections with specific vulnerabilities.

### 2. Knowledge Loading
Read `workspace:_cr/knowledge/` cards relevant to the document's domain.
Record which cards were loaded and why they matter.
If knowledge base is empty, document why and proceed.

### 3. Round Objective Definition
From the user's objective and the document state, define:
- `target`: concrete, bound to a claim or section, >= 10 chars.
- `scope.sections`: all document sections (objective is weighting lens, not scope limiter).
- `scope.claims`: all core claims.
- `scope.forbidden_scope`: explicit boundaries the round must not cross.
- `intensity`: triage | standard | deep.
- `required_outputs`: minimum set of artifacts this round must produce.
- `success_criteria`: at least one criterion with statement >= 10 chars.

### 4. Coverage Freeze
Document that the round covers the full paper. The objective determines priority and emphasis, but must not narrow coverage.

## Output Contract

```yaml
schema_version: "1.0.0"
round_id: integer
contract:
  target: string (>= 10 chars)
  scope:
    sections: [string] (all sections)
    claims: [CLM-###] (all core claims)
    forbidden_scope: [string] (explicit boundaries)
  intensity: triage | standard | deep
  required_outputs:
    - evidence_ledger
    - critique_ledger
    - review_disposition
    - revision_plan
    - patch_plan
    - patch_trace
    - writing_diff
    - knowledge_delta
    - next_round_targets
  success_criteria:
    - criterion_id: SC-###
      statement: string (>= 10 chars)
      metric: string (optional)
      threshold: string (optional)
```

## Failure Conditions
- No core claims extracted.
- Any claim missing scope, assumption, or evidence_status.
- No fragile claim identified or fragility_reason < 10 chars.
- Thesis statement empty or placeholder.
- target < 10 chars.
- success_criteria empty.
- required_outputs missing mandatory artifacts.

## Completion Checklist
- [ ] Paper state reconstructed: thesis, claims, assumptions, baselines, evaluation.
- [ ] Knowledge cards loaded and documented.
- [ ] Round contract has target, scope, intensity, required_outputs, success_criteria.
- [ ] Full-paper coverage declared explicitly.
- [ ] round-contract.yaml is valid YAML.

## Full-Document Coverage Requirement
This stage must operate over the entire paper. The objective is a weighting lens, not a scope limiter. Document:

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

## Handoff
The next stage (`s2_evidence_grounding`) executes research guided by the Round Contract.
