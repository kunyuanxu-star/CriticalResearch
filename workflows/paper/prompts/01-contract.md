# Stage 1: Round Contract

## Purpose

Establish the scope and constraints for this paper round. The contract defines what document is mutable, which units within it are targeted, what knowledge from prior rounds is binding, and what the round's objective is. This stage establishes the foundation that every subsequent stage depends on — sloppiness here cascades into unfixable problems later.

This stage must NOT:
- Begin modifying the paper document
- Load knowledge cards that are not in the contract's scope
- Decide revision strategy (that comes in stage 6)

## Stage Type

analysis-only

## Required Inputs

- `workflows/paper/workflow.yaml` — workflow definition, stage order, validators, patch types
- `workflows/paper/profile.md` — paper workflow research semantics
- `workflows/_shared/stage-protocol.md` — stage execution discipline
- `workflows/_shared/knowledge-discipline.md` — knowledge loading and maturity rules
- `project.yaml` — project configuration and metadata
- `documents/registry.yaml` — document inventory and unit registries
- The target paper document with unit anchors (read to confirm existence, not to analyze)

## Allowed Writes

- `contract.yaml` — and ONLY contract.yaml

## Required Procedure

### Step 1: Load Workflow Definition
Read `workflows/paper/workflow.yaml`. Confirm:
- `workflow_id: paper`
- `target_document_types: [paper]`
- The stage order, validators, patch types, and review rubric are present and well-formed

### Step 2: Load Project and Document Registry
Read `project.yaml` to identify the project's research object, problem setting, target property, and existing claims. Read `documents/registry.yaml` to locate the paper document and its unit registry.

### Step 3: Load Binding Knowledge
Read `contract.yaml` if it already exists (resuming a round), otherwise build from scratch. Identify `read_only_context.global_knowledge_cards`. For each card listed:
- Load the card from `_cr/knowledge/thinking/cards/<card_id>.md`
- Check `maturity`: `proven` cards are binding constraints — the round MUST respect them
- Cards with `maturity: stable` or `maturity: emerging` are advisory — note them but they may be challenged

### Step 4: Define Round Scope
From the user's objective and loaded knowledge, define:
- **Mutable document**: exactly one paper-typed document
- **Target units**: specific paper-section units within the mutable document that this round will modify
- **Round objective**: what this round aims to accomplish, in one concrete sentence
- **Read-only context**: other documents accessible for reference (design-doc, survey, proposal)

### Step 5: Write Contract
Produce `contract.yaml` with the structure defined in the Output Contract below. Every field must be populated — no placeholder values, no TODO markers.

### Step 6: Record Rationale
In the contract's `rationale` field, document:
- Which knowledge cards were loaded and how they influenced scope decisions
- Why the selected units were chosen as targets
- Any constraints the user's objective imposes

## Output Contract

```yaml
contract.yaml:
  schema_version: "1.0.0"
  round_id: integer
  workflow_id: paper
  mode: triage | standard | deep
  objective: string                # one sentence: what this round aims to accomplish
  mutable_document:
    doc_id: string                 # e.g., "paper"
    doc_type: paper
    target_units: [string]         # e.g., ["paper.introduction", "paper.evaluation"]
  read_only_context:
    documents: [string]            # e.g., ["design-doc", "survey"]
    global_knowledge_cards: [string]  # card IDs to load
  constraints:
    binding_knowledge: [string]    # constraints from proven cards
    user_constraints: [string]     # constraints from the user's objective
  rationale: string                # why these units, why this scope
  next_round_candidates: [string]  # optional: discovered future work
```

## Quality Gates

- [ ] `workflow_id` is `paper` — not another workflow
- [ ] Exactly one `mutable_document` declared, with type `paper`
- [ ] `target_units` is non-empty and every unit exists in the paper's unit registry
- [ ] All `global_knowledge_cards` exist on disk and have been read
- [ ] Binding knowledge from `proven` cards is explicitly recorded in `constraints.binding_knowledge`
- [ ] `objective` is a single concrete sentence, not a vague aspiration
- [ ] `rationale` explains why these units were chosen over others
- [ ] No field contains placeholder text, TODO, or "TBD"

## Failure Conditions

- The paper document does not exist in the document registry — STOP, cannot proceed
- A `proven` knowledge card is missing from disk — STOP, the knowledge base is inconsistent
- The user's objective contradicts a `proven` knowledge constraint — STOP, flag for human decision
- No target units can be identified from the objective — STOP, ask user to clarify scope

## Forbidden Behavior

- Do not modify the paper document — this stage is analysis-only
- Do not load knowledge cards not listed in `global_knowledge_cards`
- Do not set `target_units` to units that don't exist in the unit registry
- Do not set `mutable_document.doc_type` to anything other than `paper`
- Do not skip a knowledge card because it seems irrelevant — read it and record the decision
- Do not fabricate knowledge card content if a card file is missing

## Advance Rule

After all quality gates pass and `contract.yaml` is written, run `cr stage advance`.
