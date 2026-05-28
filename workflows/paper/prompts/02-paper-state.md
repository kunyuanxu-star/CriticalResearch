# Stage 2: Paper State

## Purpose

Produce a frozen snapshot of the paper's current state: its structure, claims, argument flow, writing quality, and positioning. This snapshot is the baseline against which all subsequent critique and revision is measured. It must be comprehensive enough that a reviewer reading only this snapshot could understand the paper's architecture without reading the paper itself.

This stage must NOT:
- Critique the paper (that's stage 4)
- Propose changes (that's stage 5)
- Evaluate evidence quality (that's stage 3)

## Stage Type

analysis-only

## Required Inputs

- `contract.yaml` — round scope, target units, read-only context
- `workflows/paper/profile.md` — paper workflow research semantics
- `workflows/_shared/stage-protocol.md` — stage execution discipline
- `workflows/_shared/evidence-discipline.md` — evidence types and strength (for claim inventory)
- The target paper document — read in full, not selectively
- `units/<paper>.units.yaml` — unit registry with section boundaries and anchors

## Allowed Writes

- `paper-state.yaml` — and ONLY paper-state.yaml

## Required Procedure

### Step 1: Load Contract and Paper
Read `contract.yaml` to confirm target units and the paper document. Read the full paper document. Read the unit registry to identify unit boundaries and anchors.

### Step 2: Extract Section Structure
For every section in the paper (whether targeted or not):
- Section title and position in document
- Word count and paragraph count
- Unit ID from the unit registry (if any)
- Rhetorical role: what function does this section serve? (motivation, background, design, evaluation, related work, conclusion)

### Step 3: Inventory Claims
Extract every claim the paper makes. A claim is any falsifiable statement the paper asserts as true. For each claim:
- **Claim ID**: assign a unique identifier (C-001, C-002, ...)
- **Claim text**: the exact claim wording from the paper
- **Claim type**: core, supporting, assumption, comparison, or scope
- **Location**: section and paragraph
- **Evidence status (initial)**: does the paper point to evidence for this claim? (yes/no/unclear)
- **Claim strength**: how strongly worded is the claim? (absolute, qualified, hedged)

### Step 4: Assess Argument Flow
Trace the logical progression through the paper:
- Does the paper follow problem → root cause → insight → approach → evaluation → contribution?
- Are there argument gaps — places where the reader must fill in missing reasoning?
- Are there redundant passages — the same point made multiple times?
- Are transitions between sections explicit and logical?

### Step 5: Assess Writing Quality
Rate the paper's writing against top-venue standards:
- **Claim-up-front**: does each section and paragraph lead with its claim?
- **Concrete vs. abstract**: are claims quantified where possible?
- **Defined-before-use**: are terms defined before they're used?
- **Throat-clearing**: are there filler openings ("In recent years...")?
- **Figure integration**: do figures advance the argument?

### Step 6: Assess Positioning
Evaluate how the paper situates itself:
- Is the contribution clearly distinguishable from prior work?
- Does the related work section compare or merely list?
- Is novelty overstated, understated, or accurately stated?
- Are baselines identified (even if not evaluated)?

### Step 7: Identify Writing Risks
Flag sections where writing quality creates risk:
- Claims buried in dense prose that a reviewer might miss
- Ambiguous language that could be interpreted as a different claim
- Missing limitations or scope statements
- Passages where the argument is circular

### Step 8: Write Paper State
Produce `paper-state.yaml` capturing all of the above.

## Output Contract

```yaml
paper-state.yaml:
  schema_version: "1.0.0"
  round_id: integer
  document_id: string
  sections:
    - section_id: string
      title: string
      position: integer
      word_count: integer
      paragraph_count: integer
      unit_id: string | null
      rhetorical_role: motivation | background | design | evaluation | related_work | conclusion | other
      claims: [string]               # claim IDs in this section
      writing_quality:
        claim_up_front: strong | adequate | weak
        concrete_vs_abstract: strong | adequate | weak
        defined_before_use: strong | adequate | weak
        no_throat_clearing: strong | adequate | weak
        figure_integration: strong | adequate | weak | n/a
      writing_risks: [string]        # specific problems
  claim_inventory:
    - claim_id: string               # C-001, C-002, ...
      claim_text: string             # exact wording from paper
      claim_type: core | supporting | assumption | comparison | scope
      location: { section: string, paragraph: integer }
      evidence_referenced: yes | no | unclear
      claim_strength: absolute | qualified | hedged
  argument_flow:
    structure: problem-root-cause-insight-approach-evaluation-contribution | incomplete | other
    gaps: [string]                   # missing reasoning steps
    redundancies: [string]           # repeated passages
    transitions: strong | adequate | weak
  positioning:
    contribution_clarity: strong | adequate | weak
    related_work_quality: comparison | listing | missing
    novelty_assessment: accurately_stated | overstated | understated
    baselines_identified: [string]   # baseline approaches named
  overall_writing_risk: low | medium | high
```

## Quality Gates

- [ ] Every section in the paper has a corresponding entry in `sections`
- [ ] Every claim extracted has a unique claim ID, exact text, and location
- [ ] Claim text is copied verbatim from the paper — not paraphrased
- [ ] Argument flow assessment identifies at least one gap, redundancy, or transition issue (every paper has them)
- [ ] Writing quality is assessed for every section, not just the first few
- [ ] Positioning assessment explicitly names the closest prior work
- [ ] `overall_writing_risk` is backed by specific writing_risks entries

## Failure Conditions

- The paper document cannot be read — STOP, file is missing or malformed
- No claims can be extracted from the paper — STOP, the document is not a research paper
- The unit registry is missing or inconsistent with the paper's section structure — STOP, fix the unit registry first
- The paper has zero sections — STOP, malformed document

## Forbidden Behavior

- Do not critique claims — recording "this claim is weak" belongs in stage 4, not here
- Do not evaluate evidence — recording "evidence is missing" belongs in stage 3, not here
- Do not modify the paper document — analysis-only stage
- Do not skip sections — every section, including appendix and references, must be inventoried
- Do not paraphrase claims — copy the exact text from the paper

## Advance Rule

After all quality gates pass and `paper-state.yaml` is written, run `cr stage advance`.
