# Stage 5: OSDI/SOSP Writing and Rhetorical Strategy

## Purpose

Develop a writing strategy that satisfies OSDI/SOSP-level reviewer expectations at the level of section structure, paragraph logic, sentence claims, word choice, transitions, and rhetorical positioning.

This stage is not a generic polishing stage. It must judge whether the paper's language is defensible under top-tier systems review. A sentence is unacceptable if it is vague, overclaimed, unsupported, rhetorically weak, logically misplaced, or inconsistent with the evidence and venue norms.

This stage must perform two tasks:

1. **Venue writing-norm research**: study how OSDI/SOSP-level systems papers express problems, root causes, insights, contributions, mechanisms, limitations, and evaluation claims.
2. **Micro-level writing audit**: inspect the target paper at sentence, word, paragraph, and section levels to determine whether its logic and wording are appropriate for OSDI/SOSP review.

This stage defines what must change and why. It does not directly modify the paper document and does not generate final patches.

## Stage Type

research-grounded writing-strategy-only

## Required Inputs

* `critical-review.yaml` — reviewer critiques, severity, and grounding.
* `paper-state.yaml` — claim inventory, section structure, paragraph roles, and argument flow.
* `claim-evidence-grounding.yaml` — claim evidence map, overclaims, and evaluation obligations.
* `venue-norm-ledger.yaml` — OSDI/SOSP review criteria and writing expectations.
* `exemplar-paper-analysis.yaml` — OSDI/SOSP exemplar papers and extracted writing patterns.
* `contract.yaml` — target units, round objective, mutable document, and scope.
* Target paper document — the actual prose to inspect.
* `references/evidence-standards.md` — evidence strength and claim discipline.
* `references/evaluation-contracts.md` — claim-type to evidence-type mapping.
* `workflows/paper/profile.md` — paper workflow semantics.

## Allowed Writes

* `writing-strategy.yaml`
* `sentence-level-audit.yaml`
* `paragraph-logic-audit.yaml`
* `word-choice-audit.yaml`

No target document edits are allowed in this stage.

## Required Procedure

### Step 1: Research OSDI/SOSP Writing Norms

Using OSDI/SOSP official criteria and exemplar accepted papers, extract how top-tier systems papers write:

* problem statements
* root-cause claims
* insight sentences
* contribution lists
* mechanism descriptions
* comparison sentences
* limitation statements
* evaluation claims
* transition sentences
* paragraph openings
* section endings
* related-work positioning

The result must distinguish general academic writing from OSDI/SOSP systems writing. Do not use generic writing advice unless it is consistent with observed systems-paper practice.

Record the extracted norms in `writing-strategy.yaml.venue_writing_norms`.

### Step 2: Define the Paper's Required Argument Chain

Synthesize the intended top-level argument chain:

* problem
* root cause
* missed opportunity or design gap
* insight
* mechanism
* implementation realization
* evaluation contract
* contribution
* limitation

Then compare this intended chain against the current paper. Identify where the current prose breaks the chain.

A paragraph, sentence, or word choice is defective if it obscures this chain.

### Step 3: Sentence-Level Audit

For every sentence in the target units, classify its rhetorical role:

* problem claim
* root-cause claim
* insight claim
* mechanism claim
* evidence claim
* comparison claim
* limitation claim
* transition
* definition
* background
* filler
* unsupported assertion

For each sentence, evaluate:

* Is the claim explicit?
* Is the sentence necessary?
* Is the sentence placed in the right paragraph?
* Does it advance the argument?
* Does it contain unsupported or overstrong language?
* Does it hide an assumption?
* Does it use vague terms such as "efficient", "robust", "secure", "general", "lightweight", "scalable", "novel", or "significant" without defining the property?
* Does it make a claim stronger than the evidence permits?
* Would an OSDI/SOSP reviewer ask "compared to what?", "under what workload?", "under what threat model?", or "where is the evidence?"

Write the result into `sentence-level-audit.yaml`.

### Step 4: Word-Choice Audit

Inspect all technically loaded words and rhetorical intensifiers. For each suspicious word or phrase, determine whether it is justified.

Flag words and phrases such as:

* better
* efficient
* lightweight
* scalable
* secure
* robust
* general
* flexible
* practical
* low-overhead
* high-performance
* novel
* fundamentally
* significantly
* substantially
* efficiently
* safely
* transparently
* only
* first
* all
* any
* always
* never
* guarantee
* eliminate
* solve
* without sacrificing
* negligible
* minimal

For each flagged word, decide:

* keep
* define
* quantify
* weaken
* replace
* delete

A word is acceptable only if the paper defines it, measures it, proves it, or scopes it.

Write the result into `word-choice-audit.yaml`.

### Step 5: Paragraph-Level Logic Audit

For every paragraph in the target units, identify:

* paragraph role
* topic sentence
* paragraph claim
* supporting evidence
* logical progression
* transition from previous paragraph
* transition to next paragraph
* unnecessary background
* hidden assumption
* missing contrast
* missing reviewer answer

A good OSDI/SOSP paragraph should usually do one clear job. It should either motivate a problem, expose a root cause, introduce an insight, specify a mechanism, compare against prior work, state evidence, or delimit scope. A paragraph that mixes several jobs without ordering them is structurally weak.

For each paragraph, classify its status:

* keep
* reorder internally
* split
* merge
* move
* rewrite
* delete

Write the result into `paragraph-logic-audit.yaml`.

### Step 6: Section-Level Rhetorical Strategy

For each target section, determine whether it satisfies its expected role:

* Introduction: problem → limitation of existing approaches → root cause → insight → approach → contributions.
* Background: only the context needed to understand the problem and design; no tutorial filler.
* Design: mechanism before implementation detail; invariant before enforcement; interface before code path.
* Implementation: demonstrate feasibility and engineering realism; avoid drowning the contribution in incidental detail.
* Evaluation: claim-driven; every experiment must answer a specific claim or reviewer objection.
* Related Work: position against dangerous prior work; avoid literature dumping.
* Discussion/Limitations: scope the claims without undermining the contribution.

For each section, produce a writing strategy that states:

* what the section currently does
* what it must do for OSDI/SOSP reviewers
* which paragraphs must change
* which claims must be moved, weakened, strengthened, or deleted
* which transitions must be added
* which technical terms must be defined earlier

### Step 7: Reviewer-Style Writing Objections

For each major writing weakness, formulate the likely reviewer objection:

* "The motivation is not compelling because..."
* "The paper does not clearly distinguish itself from..."
* "The insight appears to be..."
* "The claim is too broad because..."
* "The evaluation does not support this wording because..."
* "The writing hides an assumption..."
* "The paragraph does not explain why this follows..."
* "The contribution statement is vague because..."

The output must not only say that writing is weak. It must explain how the weakness would be perceived by an OSDI/SOSP reviewer.

### Step 8: Define Concrete Writing Strategy

Translate all sentence, word, paragraph, and section audits into a concrete writing strategy:

* claims to rewrite
* words to weaken or quantify
* paragraphs to split or reorder
* transitions to add
* section openings to replace
* contribution statements to sharpen
* unsupported claims to delete
* vague terms to define
* evidence-dependent claims to defer until evaluation
* related-work contrasts to make explicit

Every strategy item must trace to at least one critique ID, sentence audit item, paragraph audit item, or word-choice audit item.

## Output Contract

* `exemplar-paper-analysis.yaml`
* `paragraph-logic-audit.yaml`
* `sentence-level-audit.yaml`
* `venue-norm-ledger.yaml`
* `word-choice-audit.yaml`

```yaml
writing-strategy.yaml:
  schema_version: "2.0.0"
  round_id: string

  venue_writing_norms:
    target_venues:
      - OSDI
      - SOSP
    extracted_norms:
      problem_statement: string
      root_cause_framing: string
      insight_statement: string
      contribution_statement: string
      mechanism_description: string
      evaluation_claim_wording: string
      related_work_positioning: string
      limitation_wording: string
      concision_standard: string

  narrative_strategy:
    one_sentence_story: string
    intended_argument_chain:
      problem: string
      root_cause: string
      insight: string
      approach: string
      evidence_contract: string
      contribution: string
    current_breakpoints:
      - location: string
        issue: string
        reviewer_consequence: string

  section_strategy:
    - unit_id: string
      current_role: string
      intended_role: string
      section_status: keep | reorder | split | merge | restructure | rewrite
      critiques_addressed: [string]
      paragraph_actions: [string]
      transition_actions: [string]
      claim_actions: [string]

  sentence_strategy:
    - sentence_id: string
      location: string
      current_sentence: string
      rhetorical_role: string
      issue_type: overclaim | vague | unsupported | misplaced | filler | logical_gap | transition_failure | acceptable
      reviewer_objection: string
      action: keep | weaken | strengthen | move | split | delete | rewrite
      target_intent: string

  word_choice_strategy:
    - location: string
      word_or_phrase: string
      issue: vague | overstrong | undefined | unquantified | unsupported | acceptable
      action: keep | define | quantify | weaken | replace | delete
      rationale: string

  paragraph_strategy:
    - paragraph_id: string
      location: string
      current_role: string
      intended_role: string
      topic_sentence_status: clear | missing | weak | misleading
      logical_flow_status: coherent | jumpy | circular | overloaded | misplaced
      action: keep | reorder_internally | split | merge | move | rewrite | delete
      rationale: string

  final_revision_priorities:
    fatal:
      - string
    high:
      - string
    medium:
      - string
    low:
      - string
```

## Quality Gates

* Every target paragraph must have a paragraph-level audit entry.
* Every sentence containing a technical claim must have a sentence-level audit entry.
* Every vague or strong adjective/adverb must be either justified, weakened, quantified, or deleted.
* Every section strategy must be grounded in OSDI/SOSP writing norms or exemplar-paper patterns.
* Every major critique from `critical-review.yaml` must have a corresponding writing response.
* The strategy must distinguish content weakness from prose weakness.
* The strategy must distinguish unsupported claim, vague wording, misplaced logic, weak transition, and excessive background.
* No recommendation may say only "improve clarity"; it must specify the sentence, paragraph, or section operation.
* No claim may be strengthened unless `claim-evidence-grounding.yaml` permits it.
* No paragraph may be kept if its topic sentence does not match its actual function.

## Failure Conditions

Stop and report a blocker if:

* The target unit text is unavailable.
* The sentence-level audit cannot be aligned to the paper text.
* The stage cannot identify any OSDI/SOSP writing norms or exemplar-paper patterns.
* A core claim is written in vague language and cannot be repaired without additional evidence.
* The introduction lacks a recoverable problem → root cause → insight → contribution chain.
* The contribution statement is generic, such as "We present a system for X", and no more specific contribution can be derived from the evidence.

## Forbidden Behavior

* Do not modify the paper document.
* Do not generate final patches.
* Do not merely polish language.
* Do not make unsupported claims sound stronger.
* Do not preserve vague words because they sound conventional.
* Do not treat transition sentences as cosmetic; they must encode argument logic.
* Do not ignore sentence-level problems because the section-level story seems correct.
* Do not use generic academic-writing advice without grounding it in OSDI/SOSP norms or exemplar systems papers.
* Do not recommend rhetorical changes that conflict with the evidence grounding.

## Advance Rule

After all required YAML files are produced and all quality gates pass, run `cr stage advance`.
