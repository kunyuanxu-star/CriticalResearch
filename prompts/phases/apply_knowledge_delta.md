# Phase: apply_knowledge_delta

## Mission
Merge literature and thinking knowledge deltas into a unified knowledge-delta.yaml and write back to the global knowledge base. Record every write in knowledge-apply-log.yaml with before/after hashes.

## Inputs
- `literature-knowledge-delta.yaml`
- `thinking-knowledge-delta.yaml`

## Outputs
- `knowledge-delta.yaml` (merged)
- `knowledge-apply-log.yaml` (writeback log)

## Allowed Actions
- Read literature and thinking deltas.
- Merge into unified knowledge-delta.
- Write to global knowledge base (_cr/knowledge/).
- Record writeback with before/after hashes.
- Update knowledge index.

## Forbidden Actions
- Do not create new knowledge not in the deltas.
- Do not modify existing cards without recording before_hash.
- Do not edit paper draft.

## Procedure
1. Merge literature-knowledge-delta and thinking-knowledge-delta into knowledge-delta.yaml.
2. For each update: write the card to the appropriate _cr/knowledge/ subdirectory.
3. Compute before_sha256 and after_sha256 for each modified file.
4. Record in knowledge-apply-log.yaml: file path, before_hash, after_hash, action.
5. Update _cr/knowledge/index.yaml with new/updated/deprecated card references.
6. If no writes needed, provide explicit no-op reason >=10 chars.

## Output Contract
```yaml
knowledge-delta.yaml:
  updates: merged from literature and thinking deltas
knowledge-apply-log.yaml:
  applied_updates[*]:
    card_id, action, path, before_sha256, after_sha256
```

## Failure Conditions
- Delta has updates but no apply-log entries.
- Apply-log entries have no before/after hashes.
- No writes AND no substantive no-op reason.


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
prepare_next_round uses the knowledge delta to inform next-round targets.
