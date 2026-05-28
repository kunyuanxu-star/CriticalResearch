# Stage 9: Knowledge Delta

# Purpose

Extract durable, reusable knowledge from this survey round and prepare it for project-level and global knowledge integration.

This stage is part of the **survey workflow**. Its purpose is not to summarize the round. Its purpose is to identify which findings should survive beyond this round and influence future survey, design, paper, proposal, or experiment workflows.

Knowledge written to `_cr/knowledge/` during `cr round close` is mechanically injected into future rounds via `contract.yaml` → `read_only_context.global_knowledge_cards`. Therefore, every knowledge item must be precise, evidence-backed, scoped, reusable, and safe to reuse.

A knowledge delta is invalid if it records transient notes, unsupported impressions, raw literature summaries, or overgeneralized conclusions.

## Knowledge Loop

Knowledge produced in this stage may affect future rounds automatically. Therefore:

* Do not store raw notes as knowledge.
* Do not store speculative claims as stable facts.
* Do not store one-round judgments without scope conditions.
* Do not store source summaries unless they encode reusable baseline knowledge.
* Do not store taxonomy decisions without evidence and applicability conditions.
* Do not store project-favorable interpretations unless dangerous baselines and counterevidence have been considered.

Every reusable knowledge item must specify:

* what was learned;
* why it matters;
* where it came from;
* when it applies;
* when it does not apply;
* what evidence supports it;
* what risk exists if future rounds misuse it.

## Inputs

* `contract.yaml` — round scope, target document, target units, and workflow mode.
* `workflow-state.yaml` — completed stage state.
* `research-plan.yaml` — planned source targets, critical-search targets, and stop conditions.
* `source-index.yaml` — verified source metadata.
* `evidence-ledger.yaml` — structured evidence items.
* `source-notes.md` — narrative source analysis.
* `source-analysis-matrix.yaml` — system/source comparison data.
* `taxonomy-update.yaml` — taxonomy changes and classification decisions.
* `comparison-matrix.yaml` — system × dimension comparison matrix.
* `gap-analysis-update.yaml` — filled, reframed, remaining, and new gaps.
* `taxonomy-rationale.md` — rationale for taxonomy decisions.
* `taxonomy-risks.yaml` — unresolved taxonomy risks.
* `dangerous-baselines.yaml` — dangerous baselines and their implications.
* `critical-review.yaml` — critique items and reviewer objections.
* `review-disposition.yaml` — critique dispositions.
* `revision-plan.yaml` — planned repairs.
* `patch-trace.yaml` — critique-to-patch trace.
* `document-diff.yaml` — actual document changes.
* `residual-risks.yaml` — unresolved risks.
* `next-round-targets.yaml` — future round candidates.
* Project knowledge directory — current claims, terminology, related work, design knowledge, evaluation obligations, and open questions.

## Allowed Writes

* `knowledge-delta.yaml`

This stage must not directly modify project knowledge files. Knowledge application is handled by round closure.


## Outputs

* `residual-risks.yaml`
* `taxonomy-risks.yaml`
* `workflow-state.yaml`

## Required Procedure

### Step 1: Identify Candidate Knowledge

Extract candidate reusable knowledge from all round artifacts.

Candidate types include:

* claim updates;
* terminology updates;
* taxonomy rules;
* classification criteria;
* related-work entries;
* dangerous baselines;
* design implications;
* evaluation obligations;
* failure modes;
* reviewer-objection patterns;
* writing or survey-structure patterns;
* open research questions;
* future round targets.

Do not include an item merely because it appeared in the round. It must be useful for future reasoning.

### Step 2: Filter for Durability

For each candidate item, decide whether it should become durable knowledge.

A candidate should be kept only if it is:

* evidence-backed;
* reusable beyond the current patch;
* specific enough to guide future work;
* scoped enough to avoid overgeneralization;
* not already represented in project knowledge;
* not contradicted by stronger evidence;
* not merely a raw source summary;
* not a temporary planning artifact.

Reject candidates that are:

* local editing decisions;
* vague impressions;
* unverified claims;
* redundant with existing knowledge;
* one-off observations that do not generalize;
* unsupported interpretations;
* only useful for the current stage.

### Step 3: Classify Knowledge Maturity

Every retained knowledge item must receive a maturity level:

* `stable`: supported by strong evidence and safe for broad reuse within the project.
* `provisional`: useful but dependent on limited evidence or current taxonomy assumptions.
* `contested`: supported by some evidence but weakened by counterevidence or dangerous baselines.
* `open_question`: not knowledge yet, but a reusable unresolved question.
* `deprecated`: existing knowledge that should be weakened, replaced, or removed.

Do not mark knowledge as `stable` unless it is supported by strong evidence and has clear scope.

### Step 4: Update Claims

Identify reusable claim-level knowledge.

For each claim update, specify:

* new claim;
* existing claim revised;
* existing claim contradicted;
* claim weakened;
* claim deleted;
* claim split into narrower claims.

Every claim update must include:

* evidence IDs;
* source IDs;
* scope;
* confidence;
* allowed wording;
* forbidden wording;
* implications for future paper/design/evaluation work.

A claim is not reusable knowledge unless future rounds can cite or reason from it.

### Step 5: Update Terminology

Identify terminology learned or corrected during the survey.

For each term:

* definition;
* source basis;
* competing definitions;
* preferred project usage;
* forbidden ambiguous usage;
* related terms;
* taxonomy dimension affected;
* examples of systems using or challenging the term.

Terminology knowledge should prevent future rounds from using vague or overloaded terms.

### Step 6: Update Related Work Knowledge

Create or update structured related-work entries.

For each related-work item, record:

* source ID;
* system or paper name;
* venue/year;
* research object;
* problem setting;
* mechanism;
* boundary or abstraction;
* trust model or assumptions;
* evaluation method;
* main strengths;
* limitations;
* taxonomy position;
* dangerous-baseline status;
* relevance to the project;
* required future comparison.

Do not store full literature summaries. Store comparison-relevant knowledge.

### Step 7: Extract Taxonomy Knowledge

Record taxonomy decisions that should persist.

For each taxonomy rule or dimension:

* dimension name;
* definition;
* classification criteria;
* inclusion/exclusion rules;
* evidence basis;
* edge cases;
* known limitations;
* dangerous baselines that shaped the rule;
* when this taxonomy rule should be reconsidered.

This prevents future rounds from rebuilding the same taxonomy logic from scratch.

### Step 8: Extract Design Implications

Identify survey findings that affect future system or paper design.

Design implications may include:

* baselines to beat;
* mechanisms to avoid;
* assumptions that must be made explicit;
* resource dimensions that must be modeled;
* security boundaries that must be justified;
* performance tradeoffs that must be evaluated;
* compatibility requirements that prior work treats as important;
* fault or policy isolation dimensions that future designs must address.

Each design implication must trace to evidence or dangerous baselines.

### Step 9: Extract Evaluation Obligations

Identify evaluation knowledge reusable in future experiment or paper workflows.

For each obligation:

* claim or gap it supports;
* baseline required;
* workload required;
* metric required;
* comparison dimension;
* expected reviewer objection;
* evidence currently missing;
* whether it is mandatory for top-tier submission;
* whether the claim can instead be weakened.

Evaluation obligations should be specific enough to guide experiment planning.

### Step 10: Extract Failure Modes and Reviewer Patterns

Record reusable failure modes discovered during critical review.

Examples:

* taxonomy too coarse;
* dangerous baseline ignored;
* gap inferred from unknown matrix cell;
* author claim treated as evidence;
* category based on terminology rather than mechanism;
* comparison dimension not applicable across systems;
* related work reads like bibliography;
* project positioning overstates novelty;
* source classification relies on inference.

For each failure mode, record:

* trigger condition;
* reviewer objection;
* detection rule;
* repair strategy;
* stage where it should be checked in future rounds.

### Step 11: Extract Open Questions

Record unresolved but reusable open questions.

An open question should be included only if it affects future research direction, taxonomy scope, evaluation design, or project positioning.

For each open question:

* question;
* why it remains unresolved;
* evidence already checked;
* evidence still needed;
* likely workflow to resolve it;
* priority;
* risk if ignored.

### Step 12: Detect Knowledge Conflicts

Compare new knowledge against existing project knowledge.

For each conflict:

* existing knowledge item;
* new evidence;
* conflict type:

  * contradiction;
  * refinement;
  * scope narrowing;
  * terminology conflict;
  * baseline update;
  * taxonomy revision;
* recommended action:

  * replace;
  * weaken;
  * split;
  * deprecate;
  * keep both with scope conditions;
  * human decision required.

Do not silently overwrite prior knowledge.

### Step 13: Produce Knowledge Delta

Write `knowledge-delta.yaml` using the output contract below.

## Output Contract

```yaml id="w44lei"
knowledge-delta.yaml:
  schema_version: "1.0.0"
  round_id: string
  project_id: string
  workflow: survey
  target_document: string
  target_units:
    - string

  delta_summary:
    produced_reusable_knowledge: boolean
    knowledge_types:
      - claims
      - terminology
      - related_work
      - taxonomy
      - design_implications
      - evaluation_obligations
      - failure_modes
      - reviewer_patterns
      - open_questions
    overall_maturity: stable | provisional | contested | mixed
    summary: string

  claim_updates:
    - update_id: string
      action: add | revise | weaken | split | contradict | deprecate
      claim: string
      previous_claim_ref: string | null
      evidence_ids:
        - string
      source_ids:
        - string
      maturity: stable | provisional | contested | open_question | deprecated
      confidence: high | medium | low
      scope: string
      allowed_wording: string
      forbidden_wording: string
      implication_for_future_rounds: string

  terminology_updates:
    - term_id: string
      term: string
      action: add | revise | disambiguate | deprecate
      definition: string
      competing_definitions:
        - string
      preferred_usage: string
      forbidden_usage:
        - string
      evidence_ids:
        - string
      source_ids:
        - string
      affected_taxonomy_dimensions:
        - string
      maturity: stable | provisional | contested

  related_work_updates:
    - related_work_id: string
      action: add | revise | mark_dangerous | deprecate | scope_out
      source_id: string
      system_or_paper: string
      venue_or_channel: string
      year: integer | null
      research_object: string
      problem_setting: string
      mechanism: string
      boundary_or_abstraction: string
      assumptions:
        - string
      strengths:
        - string
      limitations:
        - string
      taxonomy_position: string
      dangerous_baseline: boolean
      required_future_comparison: string | null
      relevance_to_project: high | medium | low
      maturity: stable | provisional | contested

  taxonomy_updates:
    - taxonomy_knowledge_id: string
      action: add_dimension | revise_dimension | add_category | revise_category | add_edge_case | narrow_scope | deprecate_rule
      name: string
      definition: string
      classification_rule: string
      inclusion_criteria:
        - string
      exclusion_criteria:
        - string
      edge_cases:
        - string
      evidence_ids:
        - string
      source_ids:
        - string
      known_limitations:
        - string
      reconsider_when: string
      maturity: stable | provisional | contested

  design_implications:
    - implication_id: string
      implication_type: baseline_to_beat | approach_to_avoid | design_rule | assumption_to_make_explicit | mechanism_requirement | risk_to_account_for
      statement: string
      rationale: string
      evidence_ids:
        - string
      source_ids:
        - string
      affected_project_component: string | null
      risk_if_ignored: fatal | high | medium | low
      maturity: stable | provisional | contested

  evaluation_obligations:
    - obligation_id: string
      obligation_type: baseline | workload | metric | ablation | security_analysis | performance_measurement | compatibility_test | scalability_test | artifact_validation
      statement: string
      linked_claim_or_gap: string
      required_baselines:
        - string
      required_workloads:
        - string
      required_metrics:
        - string
      reviewer_objection_addressed: string
      mandatory_for_top_tier_submission: boolean
      can_instead_weaken_claim: boolean
      evidence_ids:
        - string
      maturity: stable | provisional | contested | open_question

  failure_modes:
    - failure_mode_id: string
      name: string
      trigger_condition: string
      reviewer_objection: string
      detection_rule: string
      repair_strategy: string
      should_check_in_stages:
        - research_planning
        - source_analysis
        - taxonomy_synthesis
        - critical_review
        - revision_plan
        - apply_survey_patch
      evidence_or_example_refs:
        - string

  reviewer_patterns:
    - pattern_id: string
      pattern_type: taxonomy_attack | coverage_attack | evidence_attack | gap_attack | positioning_attack | writing_attack
      reviewer_objection_template: string
      when_it_applies: string
      how_to_preempt: string
      source_or_critique_refs:
        - string

  open_questions:
    - question_id: string
      question: string
      why_unresolved: string
      evidence_already_checked:
        - string
      evidence_needed:
        - string
      suggested_future_workflow: survey | design | paper | proposal | experiment
      suggested_target_unit: string | null
      priority: high | medium | low
      risk_if_ignored: fatal | high | medium | low

  knowledge_conflicts:
    - conflict_id: string
      existing_knowledge_ref: string
      new_knowledge_ref: string
      conflict_type: contradiction | refinement | scope_narrowing | terminology_conflict | baseline_update | taxonomy_revision
      recommended_action: replace | weaken | split | deprecate | keep_both_with_scope | human_decision_required
      rationale: string

  no_knowledge_justification: null | string
```

## Quality Gates

* `knowledge-delta.yaml` must be produced unless an explicit `no_knowledge_justification` is provided.
* Survey rounds should normally produce reusable knowledge; no-delta justification must be exceptional.
* Every knowledge item must trace to evidence, source, critique, patch, or documented unresolved risk.
* Every stable knowledge item must include scope and evidence basis.
* Every contested or provisional item must include limitation or reconsideration condition.
* No raw source summary may be stored as knowledge.
* No vague lesson such as “consider related work more carefully” is acceptable.
* Every dangerous baseline discovered in the round must either update related-work knowledge, design implications, evaluation obligations, or open questions.
* Every new gap from `gap-analysis-update.yaml` must either become an open question, evaluation obligation, or deferred future target.
* Every residual high/fatal risk must appear in open questions, design implications, evaluation obligations, or knowledge conflicts.
* Knowledge conflicts with existing project knowledge must be recorded, not silently resolved.
* Future-round usefulness must be explicit for every item.

## Failure Conditions

Stop and report a blocker if:

* round artifacts are missing and knowledge cannot be traced;
* evidence IDs referenced by knowledge items do not exist;
* source IDs referenced by knowledge items do not exist;
* stable knowledge is unsupported or lacks scope;
* dangerous baselines are omitted from the knowledge delta;
* residual fatal or high risks are not captured;
* new knowledge contradicts existing project knowledge and no conflict action is proposed;
* knowledge would mislead future rounds if injected automatically.

## Forbidden Behavior

* Do not summarize the round.
* Do not store raw literature notes as durable knowledge.
* Do not store unsupported opinions.
* Do not store project-favorable conclusions without scope and counterevidence.
* Do not mark provisional knowledge as stable.
* Do not omit dangerous baselines because they weaken positioning.
* Do not convert every source into a knowledge card.
* Do not overwrite existing knowledge silently.
* Do not create vague design rules.
* Do not create evaluation obligations without baseline, workload, or metric when applicable.
* Do not advance if reusable knowledge cannot be traced to round artifacts.

## Advance Rule

After `knowledge-delta.yaml` is produced and all quality gates pass, run `cr stage advance`.

```
```
