# Stage 9: Knowledge Delta

## Purpose

Extract reusable knowledge from this round that will compound across future rounds. The knowledge delta captures patterns, rules, failure modes, and insights that are independent of the specific paper state — things that should inform the next round's contract, critique, strategy, and execution. This stage directly enables the knowledge loop: cards written here are loaded as binding or advisory constraints in future rounds via `contract.yaml` → `read_only_context.global_knowledge_cards`.

This stage must NOT:
- Regurgitate round-specific state ("Round 3 weakened C-7")
- Create cards for trivial observations
- Skip the extraction — even a round that discovers nothing new must produce a no-delta justification

## Stage Type

analysis-only

## Required Inputs

- `critical-review.yaml` — reviewer patterns and recurring critique themes
- `patch-trace.yaml` — what was changed and why
- `document-diff.yaml` — concrete before/after changes
- `claim-evidence-grounding.yaml` — evidence patterns and gaps
- `claim-alignment.yaml` — post-patch claim state, contradictions found
- `writing-strategy.yaml` — strategic decisions that worked (or didn't)
- `contract.yaml` — round scope, loaded knowledge cards
- `workflows/paper/profile.md` — paper workflow semantics
- `workflows/_shared/stage-protocol.md` — stage execution discipline
- `workflows/_shared/knowledge-discipline.md` — extraction rules, card structure, maturity lifecycle
- `_cr/knowledge/thinking/cards/` — existing knowledge cards (to avoid duplicates)

## Allowed Writes

- `knowledge-delta.yaml` — and ONLY knowledge-delta.yaml

## Required Procedure

### Step 1: Review Round Artifacts
Read all stage outputs systematically. As you read, ask:
- What pattern caused the most severe critiques?
- What writing weakness recurred across multiple sections?
- What evidence gap was most damaging?
- What reviewer expectation was not met?
- What fix was most effective?

### Step 2: Extract Claim Patterns
From the claim evidence grounding and alignment:
- Are there claim types that consistently lack evidence? (e.g., "every performance claim without tail latency data was flagged")
- Are there wording patterns that trigger overclaim flags? (e.g., "any claim using 'always' or 'never' without proof")
- Are there evidence types that reviewers consistently demand? (e.g., "SOSP reviewers expect sensitivity analysis for every parameter")

### Step 3: Extract Reviewer Patterns
From the critical review:
- What critique categories produced the most entries? (motivation? evaluation? claims?)
- What rubric questions were most discriminating?
- What would a paper need to do differently to preempt these critiques in the next round?

### Step 4: Extract Writing Patterns
From the writing strategy and patches:
- Which writing tactics were effective? Which were not?
- What structural changes had the most impact?
- What rhetorical patterns worked for this venue?
- What throat-clearing or filler patterns should be avoided?

### Step 5: Extract Evidence Patterns
From the evidence grounding:
- What evidence types were most convincing?
- What evidence gaps recurred?
- What evaluation obligations were generated?
- What would make evidence gathering more efficient in the next round?

### Step 6: Extract Failure Modes
From validation failures, alignment issues, and patch problems:
- What invariants were violated?
- What dependencies were missed?
- What assumptions were wrong?

### Step 7: Draft Knowledge Cards
For each candidate insight, draft a knowledge card:
- **Card ID**: assign a unique ID
- **Claim**: one sentence — the rule, pattern, or constraint
- **Domain**: CS sub-area(s)
- **Maturity**: `emerging` (since this is the first round producing this insight)
- **Source**: this round's ID
- **Evidence**: what in the round supports this claim
- **Constraints**: when the rule applies vs. when it doesn't

### Step 8: Check for Duplicates
Compare each candidate card against existing cards in `_cr/knowledge/thinking/cards/`:
- If an identical insight exists: do not create a new card; increment maturity on the existing card
- If a similar but distinct insight exists: create a new card and reference the related card
- If no related card exists: create as new

### Step 9: Write Knowledge Delta
Produce `knowledge-delta.yaml`.

## Output Contract

```yaml
knowledge-delta.yaml:
  schema_version: "1.0.0"
  round_id: integer
  new_cards:
    - card_id: string                # e.g., "paper-claim-tail-latency"
      claim: string                  # one sentence: the rule, pattern, or constraint
      domain: [string]               # CS sub-area(s)
      maturity: emerging
      source_round: integer
      evidence: string               # what in this round supports this claim
      constraints: string            # when the rule applies vs. when it doesn't
  updated_cards:
    - card_id: string                # existing card ID
      previous_maturity: emerging | stable
      new_maturity: stable | proven
      update_rationale: string       # what new evidence supports the maturity change
  no_delta: boolean                  # true if no knowledge was gained
  no_delta_justification: string | null  # required if no_delta is true
  summary:
    new_cards: integer
    updated_cards: integer
    key_insight: string              # the single most important thing learned this round
  card_files_to_write:               # paths relative to _cr/knowledge/thinking/cards/
    - card_id: string
      path: string                   # e.g., "_cr/knowledge/thinking/cards/paper-claim-tail-latency.md"
```

## Quality Gates

- [ ] At least one new or updated knowledge card, OR a valid no-delta justification
- [ ] Every new card has a one-sentence claim, not a vague observation
- [ ] Every new card cites specific evidence from this round's artifacts
- [ ] No card duplicates an existing card's claim (verified by reading existing cards)
- [ ] `maturity` is `emerging` for all new cards (first round for this insight)
- [ ] `key_insight` is a single sentence that captures the round's most transferable learning
- [ ] If `no_delta: true`, `no_delta_justification` explains what was attempted and why it produced no transferable knowledge

## Failure Conditions

- No cards generated and no no-delta justification — STOP; every round must produce a delta or explain why not
- A new card duplicates an existing card's claim — STOP; update the existing card instead
- A new card has `maturity: stable` or `proven` — STOP; new cards always start at emerging
- A new card's `evidence` is vague ("from the critique") — STOP; cite specific critique IDs or findings

## Forbidden Behavior

- Do not create cards for round-specific state ("Round 3 changed introduction paragraphs 2-4")
- Do not create cards with vague claims ("Writing matters" — not actionable)
- Do not skip the duplicate check — always read existing cards before creating new ones
- Do not inflate maturity — new cards are always `emerging`
- Do not generate cards that are not supported by evidence from this round
- Do not modify the paper document — analysis-only stage

## Advance Rule

After all quality gates pass and `knowledge-delta.yaml` is written, run `cr stage advance`.
