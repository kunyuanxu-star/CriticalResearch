# Phase: read_sources

## Mission
Read every included source deeply. Extract its problem, method, claims, assumptions, evaluation, baselines, limitations, and relation to the current paper. This phase converts raw sources into actionable understanding. It must NOT generate critique, patches, or draft edits.

## Inputs
- `source-index.yaml`
- `source-triage.yaml`
- `raw-sources/`

## Outputs
- `source-notes/` (one SRC-*.yaml per included source)

## Allowed Actions
- Read included raw sources deeply.
- Extract source-local claims, methods, evaluation, baselines, assumptions, limitations.
- Identify what the source supports, weakens, contradicts, contextualizes, or does NOT prove.
- Link source to affected claims and paper sections.

## Forbidden Actions
- Do not write critique-ledger.yaml.
- Do not write patches/.
- Do not edit writing/paper-draft.md.
- Do not generate experiment obligations.
- Do not update global knowledge.

## Procedure
1. For every source marked `include` in source-triage.yaml, create one source note.
2. Extract the source's own contribution BEFORE relating it to the paper.
3. Record: problem, method_or_mechanism, main_claims, assumptions, evaluation, baselines, limitations.
4. Identify: supports, weakens, contradicts, contextualizes (at least one must be non-empty).
5. Record does_not_prove: what this source explicitly does NOT prove.
6. Record affected_claims and affected_sections.

## Output Contract
```yaml
source_id: string
problem: string (>=50 chars)
method_or_mechanism: string (>=20 chars)
main_claims: [string]
assumptions: [string]
evaluation: string
baselines: [string]
limitations: [string]
supports: [claim_id]
weakens: [claim_id]
contradicts: [claim_id]
does_not_prove: string (>=10 chars)
affected_claims: [claim_id] (>=1)
affected_sections: [section_anchor]
```

## Failure Conditions
- Any included source lacks a source note.
- Any source note has problem <50 chars.
- Any source note has method <20 chars.
- Any source note lacks does_not_prove.
- Any source note has no affected_claims.

## Knowledge Use
Cite loaded knowledge cards with intended_use including `read_sources`.


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
`normalize_evidence` will convert these notes into structured evidence-ledger entries.
