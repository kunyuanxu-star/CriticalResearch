# Phase: load_project_knowledge

## Mission
Load relevant global knowledge cards for this round. Each loaded card must have a usage contract (intended_use mapping to specific phases). Cards that are not relevant must be explicitly rejected with reasons. This phase MUST NOT create new knowledge.

## Inputs
- `_cr/knowledge/` — global knowledge base
- `paper-state.yaml` — frozen paper snapshot

## Outputs
- `loaded-knowledge.yaml` — knowledge load manifest

## Allowed Actions
- Read global knowledge cards.
- Select cards relevant to this round's claims, risks, and sections.
- Record intended_use per selected card (which phases will use it).
- Reject cards that are not relevant, with reasons.

## Forbidden Actions
- Do not modify global knowledge base.
- Do not create new knowledge cards or deltas.
- Do not search for external sources.
- Do not generate critique or patches.

## Procedure
1. Inspect paper-state.yaml for claims, risks, and affected sections.
2. Scan `_cr/knowledge/index.yaml` for relevant cards.
3. For each relevant card, specify which phase(s) will use it and why.
4. For cards that seem related but are NOT applicable, record rejection reason.
5. Identify knowledge gaps (missing_knowledge entries).

## Output Contract
```yaml
loaded_cards[*]:
  card_id: string
  reason: string (why loaded, >=10 chars)
  intended_use: [phase_name, ...]
rejected_cards[*]:
  card_id: string
  reason: string (why not applicable, >=10 chars)
missing_knowledge[*]:
  description: string (what knowledge is missing)
  needed_in_phase: phase_name
```

## Failure Conditions
- Selected card has no intended_use or intended_use is empty.
- Rejected card has no reason or reason is <10 chars.
- Knowledge base exists but loaded-knowledge.yaml is empty with no explanation.

## Completion Checklist
- [ ] All selected cards have intended_use mapping to specific phases.
- [ ] All rejected cards have substantive reasons.
- [ ] Missing knowledge gaps identified if applicable.
- [ ] No new knowledge cards created.

## Handoff
Subsequent phases must cite loaded card IDs when their intended_use matches the current phase.
