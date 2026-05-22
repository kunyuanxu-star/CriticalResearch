# Phase: generate_paper_patches

## Mission
Convert accepted dispositions into concrete paper patches. Each patch must specify before_text_or_anchor, after_text_or_structural_change, claim_effect, evidence_refs, and lifecycle_status=proposed. Patches must NOT be applied yet.

## Inputs
- `dispositions.yaml`
- `human-decisions.yaml`

## Outputs
- `patches/PP-*.yaml` (one per accepted disposition)

## Allowed Actions
- Read dispositions and human decisions.
- Create patch files for accepted dispositions.
- Specify exact text changes with before/after anchors.
- Record claim_effect, evidence_refs, experiment_obligation_needed.

## Forbidden Actions
- Do not edit paper draft (that is M6).
- Do not apply patches.
- Do not create patches for rejected/deferred dispositions.

## Procedure
1. For each accept_patch, weaken_claim, split_claim, or add_evaluation disposition, create a patch.
2. Each patch must specify: patch_id, linked_critiques, linked_claims, affected_sections.
3. Record before_text_or_anchor and after_text_or_structural_change.
4. Specify claim_effect, evidence_refs, knowledge_implication.
5. Set lifecycle_status=proposed.
6. If no patches needed, create patches/.no-patch.yaml with substantive reason.

## Output Contract
```yaml
patch_id, linked_critiques, linked_claims, affected_sections
before_text_or_anchor (>=10 chars), after_text_or_structural_change (>=10 chars)
claim_effect, evidence_refs, knowledge_implication
experiment_obligation_needed: bool, lifecycle_status: proposed
```
Or .no-patch.yaml with no_patch_reason >=20 chars and checked_critiques.

## Failure Conditions
- Accept_patch disposition has no corresponding patch.
- Any patch has before_text identical to after_text.
- No patches AND no substantive .no-patch.yaml.


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
generate_experiment_obligations will create experiment obligations for claim-affecting patches.
