# Stage 1: Contract
# Proposal round: scope for one proposal document, target proposal sections.

## Knowledge Loading
Read `contract.yaml` → `read_only_context.global_knowledge_cards`.
Load each card from `_cr/knowledge/thinking/cards/<card_id>.md`.
Cards with `maturity: proven` MUST be applied as binding constraints
when setting proposal scope. Prefer knowledge that has survived
multiple rounds — it represents hard-won ground.

Record loaded cards and their influence in the contract rationale.

## Inputs
- `engine/core/transaction-rules.md`
- `workflows/proposal/workflow.yaml`
- `project.yaml`, `documents/registry.yaml`, `units/<proposal>.units.yaml`
- User's objective

## Task
Produce `contract.yaml` with workflow `id: proposal`, one `proposal`-type
mutable document, and target proposal-section units.

## Constraints
- Only the proposal document is mutable.
- If proposal changes imply design or paper changes, record next_round_candidates.
