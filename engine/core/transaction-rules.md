# CriticalResearch v2 — Transaction Rules

Shared across all workflows. These rules enforce structural constraints only.
They NEVER prescribe how to conduct a survey, design, paper, or proposal round.

---

## Single-Document Invariant (Inv3)

Every round has exactly **one** mutable document.

- A round may **read** any document as context.
- A round may **modify** exactly one document.
- All patches, diffs, and writes in a round MUST target the declared `mutable_document`.
- Modifying a second document in the same round is a **hard violation** — the round is invalid.

## Cross-Document Discipline (Inv5, Inv10)

- Read-only context documents MUST NOT be modified.
- If a round discovers that another document needs changes, it MUST record a `next_round_candidates` entry instead of modifying that document.
- The next-round candidate includes: workflow, document, target unit(s), and objective.

## Contract (Inv0, Inv1)

Every round begins with a **contract** (`contract.yaml`) that declares:

- `project_id` — exactly one project
- `workflow.id` — exactly one workflow
- `mutable_document` — exactly one target document
- `target_units` — at least one unit within the mutable document
- `read_only_context` — other documents and knowledge read but not modified
- `scope_policy` — structural constraints for this round
- `user_objective` — natural-language description of what the round should accomplish
- `success_criteria` — verifiable conditions for round completion

The contract is the round's control plane. Every subsequent stage operates within its bounds.

## Unit Scope (Inv4)

- Units are demarcated within documents by HTML anchor comments: `<!-- unit:<id>:start -->` and `<!-- unit:<id>:end -->`.
- A round may target one or more units, but all modified units MUST belong to the single mutable document.
- Patches declare which units they modify.

## Patch Traceability (Inv7, Inv8, Inv9)

- Every accepted critique MUST produce a workflow-specific patch, a deferred obligation, or an explicit no-patch decision.
- Every patch MUST trace to:
  - The round contract
  - The target unit(s)
  - The originating critique(s)
  - The disposition (applied / deferred / rejected)
  - A document diff showing what changed
- A patch CANNOT be marked `applied` unless the target document actually changed within the declared unit anchors.

## Knowledge Delta (Inv11)

- Every round MUST produce a `knowledge-delta.yaml` that updates project knowledge OR explicitly justify why no reusable knowledge was produced.
- Project knowledge includes: claims, terminology, related work, design decisions, evaluation obligations, open questions.

## Round Closure

Every round MUST produce:

1. `contract.yaml` — the initial contract
2. `workflow-state.yaml` — per-stage state tracking
3. Workflow-specific artifacts (evidence ledger, critique review, revision plan, etc.)
4. `patches/` — at least one patch YAML file
5. `document-diff.yaml` — unified or structured diff of document changes
6. `knowledge-delta.yaml` — knowledge updates or explicit justification
7. `closure.md` — round summary and remaining risks

## Prompt Loading Order

When executing a stage, load prompts in this order:

1. `engine/core/transaction-rules.md` — structural constraints (this file)
2. `workflows/<workflow>/workflow.yaml` — stage order, schemas, validators
3. `workflows/<workflow>/prompts/<stage>.md` — stage-specific instructions
4. `project.yaml` — project identity, venue, domain
5. `documents/registry.yaml` — which documents exist
6. `units/<target-document>.units.yaml` — unit boundaries, maturity
7. `<mutable document>` — the document being modified
8. `<read-only context documents>` — other documents, read-only
9. Project knowledge — claims, terminology, related work

## Invariant Summary

|Invariant|Rule|
|---|---|
|Inv0|Every round belongs to exactly one project|
|Inv1|Every round enters exactly one workflow|
|Inv2|Every workflow targets exactly one mutable document type|
|Inv3|Every round has exactly one mutable document|
|Inv4|All modified units belong to the mutable document|
|Inv5|Other documents read but never modified|
|Inv6|Workflow-specific prompts define review criteria, revision strategy, patch schema, closure|
|Inv7|Every accepted critique → patch, deferred obligation, or no-patch decision|
|Inv8|Every patch traces to contract, unit, critique, disposition, diff|
|Inv9|Patch not `applied` unless document changed within unit anchors|
|Inv10|Cross-document changes → next-round-candidate, never silent patch|
|Inv11|Every round updates project knowledge or justifies omission|
