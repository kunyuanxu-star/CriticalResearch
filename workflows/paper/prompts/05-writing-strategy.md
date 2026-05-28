# Stage 5: Writing Strategy

## Purpose

Develop a concrete writing strategy that addresses every critique from stage 4 — without modifying the paper document. This stage translates reviewer complaints into actionable writing decisions: what to strengthen, what to weaken, what to restructure, what to drop. The strategy is the bridge between critique and revision plan. It defines WHAT to change and WHY, not HOW to change it (that's stage 6).

This stage must NOT:
- Modify the paper document (that's stage 7)
- Generate actual patches (that's stage 7)
- Ignore critiques — every critique must have a strategic response

## Stage Type

planning-only

## Required Inputs

- `critical-review.yaml` — all critiques, severity, grounding
- `paper-state.yaml` — claim inventory, argument flow, writing quality, positioning
- `claim-evidence-grounding.yaml` — evidence map, overclaims, evaluation obligations
- `contract.yaml` — target units, round objective
- `workflows/paper/profile.md` — writing quality standards, argument flow patterns
- `workflows/_shared/stage-protocol.md` — stage execution discipline
- `workflows/_shared/evidence-discipline.md` — evidence adequacy for claim strategy

## Allowed Writes

- `writing-strategy.yaml` — and ONLY writing-strategy.yaml

## Required Procedure

### Step 1: Load Critique and Paper State
Read `critical-review.yaml` to get the full ranked critique list. Read `paper-state.yaml` for the current paper architecture. Read `claim-evidence-grounding.yaml` for evidence constraints. Read `contract.yaml` to confirm which units are in scope.

### Step 2: Define Narrative Strategy
Synthesize the paper's one-sentence story:
- Problem: what is broken and why does it matter?
- Root cause: why do existing solutions fail?
- Insight: what non-obvious observation enables the solution?
- Approach: how does the insight translate to a system/method?
- Contribution: what does the reader now know?

If the current paper does not tell this story clearly, define how it should. This becomes the north star for all section-level strategy.

### Step 3: Per-Section Strategy
For each target unit defined in the contract:
- **Current state**: what does this section do now? (from paper-state)
- **Critique addressed**: which critique IDs does this section need to resolve?
- **Strategic goal**: what must this section accomplish for the reader after revision?
- **Rhetorical pattern**: what pattern should this section use? (problem-root-cause-insight, claim-evidence, compare-contrast, motivation-design-evaluation)
- **Structural change**: should this section be reordered, split, merged, or kept as-is?

### Step 4: Claim Strategy
For every claim flagged in critiques or evidence grounding:
- **Claims to strengthen**: which claims need stronger wording or more evidence? What does "stronger" mean — broader scope, more definitive language, more backing?
- **Claims to weaken**: which claims overreach? What is the new, defensible wording?
- **Claims to drop**: which claims cannot be defended and should be removed?
- **Claims to add**: are there missing claims the paper SHOULD make based on available evidence?

### Step 5: Writing Tactics
Define specific tactics for top-venue writing quality:
- **Claim-up-front**: ensure every section and paragraph opens with its claim
- **Transitions**: define explicit transitions between sections — what does the reader need to know to move from section N to section N+1?
- **Signposting**: where should the paper explicitly tell the reviewer what is coming? ("In this section, we...")
- **Throat-clearing elimination**: identify and rewrite any filler openings
- **Figure strategy**: should any claims move from text to figures? Should any figures be restructured?

### Step 6: Positioning Strategy
Define how to improve the paper's positioning:
- **Contribution clarity**: rewrite the contribution statement to be unmistakable
- **Related work repositioning**: how should prior work be discussed — compared, contrasted, or built upon?
- **Novelty framing**: how to frame the contribution so it is clearly distinguishable from closest prior work

### Step 7: Write Writing Strategy
Produce `writing-strategy.yaml` capturing the complete strategy. Every strategic decision must trace to at least one critique ID.

## Output Contract

```yaml
writing-strategy.yaml:
  schema_version: "1.0.0"
  round_id: integer
  narrative_strategy:
    one_sentence_story: string      # problem → root cause → insight → approach → contribution
    current_gaps: [string]          # where the current paper deviates from this story
  section_strategy:
    - unit_id: string               # from contract target_units
      current_state: string         # what this section does now
      critiques_addressed: [string] # critique IDs
      strategic_goal: string        # what this section must accomplish
      rhetorical_pattern: problem-root-cause-insight | claim-evidence | compare-contrast | motivation-design-evaluation | other
      structural_change: keep | reorder | split | merge | restructure
      structural_detail: string     # specific instructions if not "keep"
  claim_strategy:
    strengthen:
      - claim_id: string
        current_wording: string
        target_wording: string
        rationale: string
    weaken:
      - claim_id: string
        current_wording: string
        target_wording: string
        rationale: string
    drop:
      - claim_id: string
        rationale: string
    add:
      - claim_text: string
        claim_type: core | supporting | assumption | comparison | scope
        rationale: string
        evidence_available: string
  writing_tactics:
    claim_up_front: [string]        # specific changes to achieve this
    transitions: [string]           # section-to-section transition text
    signposting: [string]           # explicit navigation cues to add
    throat_clearing_elimination: [string]  # passages to rewrite
    figure_strategy: [string]       # changes to figure/text relationship
  positioning_strategy:
    contribution_statement: string  # the revised one-sentence contribution
    related_work_approach: string   # how to frame prior work
    novelty_framing: string         # how to make novelty unmistakable
```

## Quality Gates

- [ ] Every fatal and major critique from `critical-review.yaml` has a corresponding entry in this strategy
- [ ] `narrative_strategy.one_sentence_story` is a single sentence, not a paragraph
- [ ] Every target unit from the contract has a `section_strategy` entry
- [ ] Every claim in `claim_strategy.strengthen` or `claim_strategy.weaken` shows both current and target wording
- [ ] `claim_strategy.drop` is not empty unless no claims should be dropped — every paper has at least one overclaimed statement
- [ ] Writing tactics are concrete — "improve transitions" is not a tactic; specific transition language is

## Failure Conditions

- A fatal critique has no strategic response — STOP; the strategy is incomplete
- The narrative strategy is circular (the "insight" is just a restatement of the "approach")
- A claim is marked for strengthening but no evidence exists to support the stronger wording — STOP; cannot fabricate strength
- `positioning_strategy.contribution_statement` is vague ("We present a system for X") — STOP; rewrite with specificity

## Forbidden Behavior

- Do not modify the paper document — planning-only stage
- Do not generate patches — that's stage 6 (plan) and stage 7 (apply)
- Do not ignore minor critiques — every critique gets a strategy, even if the strategy is "no change needed"
- Do not strengthen claims beyond what evidence supports — the evidence grounding from stage 3 is a hard constraint
- Do not propose strategy for units not in `target_units` — out of scope for this round

## Advance Rule

After all quality gates pass and `writing-strategy.yaml` is written, run `cr stage advance`.
