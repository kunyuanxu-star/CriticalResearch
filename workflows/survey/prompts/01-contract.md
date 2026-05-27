# Stage 1: Contract
# Purpose: Establish the round's scope, mutable document, target units,
# and success criteria.

## Inputs
You are given:
- `engine/core/transaction-rules.md` — structural constraints (MUST follow)
- `workflows/survey/workflow.yaml` — survey workflow definition
- `project.yaml` — project identity and venue
- `documents/registry.yaml` — all project documents
- `units/<target>.units.yaml` — unit boundaries for target survey document
- User's objective (natural language)

## Task
Produce `contract.yaml` for this survey round with:
1. **Workflow**: `id: survey`, `version: "1.0.0"`
2. **Mutable document**: exactly one `survey`-type document
3. **Target units**: identify which survey units need modification based on the user's objective
4. **Read-only context**: list other documents and knowledge that may inform the survey but must not be modified
5. **Scope policy**: enforce single-document constraint
6. **Required outputs**: evidence-ledger.yaml, source-notes.md, taxonomy-update.yaml, critical-review.yaml, revision-plan.yaml, patches/, document-diff.yaml, knowledge-delta.yaml, closure.md
7. **Success criteria**: specific, verifiable conditions

## Constraints
- `mutable_document` MUST be exactly one survey document.
- All target units MUST belong to that document.
- If the objective requires changes to a design doc or paper, record a `next_round_candidates` entry — do NOT add those documents to the mutable scope.
- Keep target unit selection focused: 1-3 primary units, 0-2 secondary.
