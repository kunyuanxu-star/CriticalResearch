# Stage 9: Knowledge Delta

## Purpose

Extract durable, reusable knowledge from this paper round and prepare it for future rounds through the CriticalResearch knowledge loop.

This stage is part of the **paper workflow**. Its purpose is not to summarize the round. Its purpose is to distill reusable knowledge that should influence future paper critique, evidence grounding, writing strategy, revision planning, patch application, and claim alignment.

Knowledge written to `_cr/knowledge/` during `cr round close` may be mechanically injected into future rounds through `contract.yaml` → `read_only_context.global_knowledge_cards`. Therefore, every knowledge item must be precise, evidence-backed, scoped, reusable, and safe to apply.

A knowledge delta is invalid if it records transient round state, vague advice, raw critique summaries, unscoped claims, unsupported preferences, or project-favorable conclusions that would mislead future rounds.

## Stage Type

analysis-only

## Required Inputs

* `contract.yaml` — round scope, target document, target units, loaded knowledge cards, and objective.
* `workflow-state.yaml` — completed stage state.
* `paper-state.yaml` — original claim inventory, contribution inventory, and paper structure.
* `claim-evidence-grounding.yaml` — evidence strength, overclaims, evaluation obligations, and claim risks.
* `critical-review.yaml` — reviewer critiques, severity, reviewer objections, and recurring risk patterns.
* `reviewer-rejection-paths.yaml` — strongest rejection paths, if available.
* `writing-risk-audit.yaml` — sentence, paragraph, word-choice, or rhetorical risks, if available.
* `writing-strategy.yaml` — narrative, section, paragraph, sentence, and claim strategy.
* `revision-plan.yaml` — critique dispositions, patch goals, patch dependencies, and claim constraints.
* `patch-plan.yaml` — executable patch plan.
* `patch-trace.yaml` — applied patches, actual effect, repair status, and residual risk.
* `document-diff.yaml` — before/after document changes.
* `applied-patch-summary.md` — human-readable patch summary.
* `residual-risks.yaml` — unresolved or partially repaired risks.
* `claim-alignment.yaml` — post-patch claim alignment, contradictions, unsupported claims, and closure readiness.
* `next-round-targets.yaml` — recommended future work.
* Existing knowledge cards in `_cr/knowledge/thinking/cards/` — used to avoid duplicates and detect conflicts.
* `workflows/paper/profile.md` — paper workflow semantics.
* `workflows/_shared/stage-protocol.md` — stage execution discipline.
* `workflows/_shared/knowledge-discipline.md` — knowledge extraction rules, card format, maturity lifecycle, and merge policy.

## Allowed Writes

* `knowledge-delta.yaml`

No paper document edits are allowed in this stage. Do not directly modify `_cr/knowledge/`; round closure applies the delta.
## Outputs

* `residual-risks.yaml`
* `reviewer-rejection-paths.yaml`
* `workflow-state.yaml`
* `writing-risk-audit.yaml`

## Required Procedure

### Step 1: Review the Round as a Learning Source

Read all round artifacts systematically.

Extract candidate knowledge from:

* the most severe reviewer critiques;
* the strongest rejection paths;
* recurring claim-evidence failures;
* overclaim patterns;
* dangerous wording patterns;
* missing baseline or evaluation patterns;
* writing strategies that successfully repaired critique;
* patches that failed or only partially repaired critique;
* claim-alignment failures introduced by patching;
* residual risks and next-round targets.

Do not record what happened in the round. Record what future rounds should learn from it.

### Step 2: Identify Candidate Knowledge Types

Classify each candidate as one or more of:

* `claim_rule`: reusable rule about claim wording, claim scope, claim strength, or claim placement.
* `evidence_rule`: reusable rule about what evidence is required for a claim type.
* `reviewer_pattern`: recurring OSDI/SOSP-style reviewer objection and how to preempt it.
* `writing_pattern`: reusable rhetorical, paragraph, section, or word-choice pattern.
* `patch_pattern`: reusable rule about planning or applying patches.
* `failure_mode`: recurring way a paper round can fail.
* `evaluation_obligation`: reusable experiment, baseline, workload, metric, or ablation requirement.
* `related_work_positioning`: reusable rule about positioning against prior work.
* `terminology_rule`: reusable rule about technical term usage.
* `workflow_rule`: reusable rule about stage ordering, validation, or artifact discipline.
* `open_question`: unresolved issue that should be carried forward.

A candidate that does not fit any of these types is probably round-specific and should not become knowledge.

### Step 3: Filter for Durability

Keep a candidate only if it is:

* useful beyond this round;
* grounded in specific round artifacts;
* actionable in future stages;
* specific enough to guide behavior;
* scoped enough to avoid overgeneralization;
* not merely a source summary or patch summary;
* not duplicative of existing knowledge;
* not contradicted by stronger evidence;
* safe to inject into future rounds.

Reject candidates that are:

* local document edits;
* one-off paragraph decisions;
* vague writing advice;
* unsupported impressions;
* project-favorable interpretations without counterevidence;
* restatements of workflow rules already encoded elsewhere;
* generic lessons such as “be clearer” or “add more evidence.”

### Step 4: Determine Maturity and Scope

Every retained knowledge item must receive a maturity value:

* `emerging`: first observed in this round; useful but not yet stable.
* `reinforced`: already known and supported again by this round.
* `stable`: supported across multiple rounds or strong evidence and safe for regular reuse.
* `contested`: useful but weakened by conflicting evidence, dangerous baselines, or unresolved scope.
* `deprecated`: existing knowledge that should be weakened, replaced, or removed.
* `open_question`: not knowledge yet, but a reusable unresolved question.

New knowledge cards must normally start as `emerging`. Do not mark a new card as `stable` unless the knowledge discipline explicitly permits it and the evidence is unusually strong.

Each item must include:

* applicability conditions;
* non-applicability conditions;
* misuse risk;
* evidence basis;
* future-stage usage.

### Step 5: Extract Claim Rules

From `claim-evidence-grounding.yaml` and `claim-alignment.yaml`, identify reusable claim rules.

Examples of valid claim rules:

* A performance claim must specify workload, metric, baseline, and measured condition before it can be stated strongly.
* A novelty claim must be checked against dangerous related work before appearing in the introduction.
* A contribution claim cannot be broader than the strongest supported body claim.
* A claim weakened in patching must be rechecked after patch application because paragraph rewrites may accidentally reintroduce broad wording.

For each claim rule, record:

* claim type affected;
* triggering pattern;
* allowed wording;
* forbidden wording;
* required evidence;
* stage where the rule should be enforced.

### Step 6: Extract Evidence Rules and Evaluation Obligations

From evidence gaps, reviewer critiques, and evaluation obligations, extract reusable evidence requirements.

Examples:

* Tail-latency claims require tail metrics, not only average throughput.
* Security claims require attacker model, trust boundary, and failure condition.
* Compatibility claims require tested application or API scope.
* Scalability claims require load model, bottleneck analysis, and resource-limit behavior.
* Evaluation obligations should name baseline, workload, metric, and claim being tested.

Do not store vague obligations such as “run more experiments.”

### Step 7: Extract Reviewer Patterns

From `critical-review.yaml` and reviewer rejection paths, extract reusable reviewer-objection patterns.

Each reviewer pattern must include:

* objection template;
* trigger condition;
* likely severity;
* how to detect it early;
* how to preempt it;
* which stage should check it.

Examples:

* “The paper solves an unmotivated problem” occurs when motivation lacks a concrete deployment, workload, incident, or prior-system failure.
* “The insight is an implementation choice” occurs when the claimed insight does not explain why prior abstractions fail.
* “The evaluation does not test the central claim” occurs when experiments measure a weaker property than the introduction claims.

### Step 8: Extract Writing Patterns

From `writing-strategy.yaml`, `document-diff.yaml`, and `claim-alignment.yaml`, extract reusable writing rules.

Valid writing knowledge includes:

* problem → root cause → insight → mechanism → evidence ordering rules;
* paragraph role rules;
* transition rules;
* contribution wording rules;
* word-choice constraints;
* anti-patterns that led to overclaiming;
* section structure patterns that improved reviewer safety.

Do not store generic writing advice. A writing pattern must be tied to paper-review function.

### Step 9: Extract Patch and Workflow Failure Modes

From `patch-trace.yaml`, `document-diff.yaml`, `residual-risks.yaml`, and `claim-alignment.yaml`, identify patch or workflow failures.

Examples:

* A paragraph rewrite can introduce new unsupported claims if claim alignment is not rerun.
* A contribution rewrite must depend on claim weakening/strengthening patches.
* A related-work repositioning patch can create novelty inconsistency if dangerous baselines are not rechecked.
* A patch that changes claim wording must record evidence-supported wording before application.

For each failure mode, record:

* trigger condition;
* detection rule;
* repair strategy;
* stage where it should be checked.

### Step 10: Extract Related-Work and Positioning Knowledge

If the round revealed durable related-work positioning lessons, record them.

Valid related-work knowledge includes:

* dangerous baseline to always consider;
* comparison axis required for future paper rounds;
* prior-work distinction that must be stated carefully;
* terminology that prior work uses differently;
* a baseline that weakens the project's novelty unless explicitly addressed.

Do not store full related-work summaries. Store only reusable positioning knowledge.

### Step 11: Extract Open Questions and Next-Round Knowledge

From `residual-risks.yaml`, `claim-alignment.yaml`, and `next-round-targets.yaml`, extract unresolved issues that should carry forward.

An open question should be included only if it affects:

* claim validity;
* paper positioning;
* evaluation design;
* related-work coverage;
* design argument;
* contribution wording;
* future workflow planning.

Each open question must specify:

* why it remains unresolved;
* what evidence or decision is needed;
* which workflow should resolve it;
* priority;
* risk if ignored.

### Step 12: Check Existing Knowledge for Duplicates and Conflicts

Read existing knowledge cards in `_cr/knowledge/thinking/cards/`.

For each candidate:

* If an identical card exists, do not create a duplicate. Update or reinforce the existing card.
* If a similar card exists, link to it and explain the difference.
* If the new candidate contradicts existing knowledge, record a knowledge conflict.
* If the new candidate narrows the scope of an existing card, propose a scope update.
* If an existing card is now unsafe or outdated, propose deprecation.

Do not silently overwrite prior knowledge.

### Step 13: Write Knowledge Delta

Produce `knowledge-delta.yaml`.

## Output Contract

```yaml id="n4wj98"
knowledge-delta.yaml:
  schema_version: "1.0.0"
  round_id: string
  project_id: string
  workflow: paper
  target_document: string
  target_units:
    - string

  delta_summary:
    produced_reusable_knowledge: boolean
    no_delta: boolean
    no_delta_justification: string | null
    new_cards: integer
    updated_cards: integer
    deprecated_cards: integer
    conflicts: integer
    open_questions: integer
    overall_maturity: emerging | reinforced | stable | contested | mixed | none
    key_insight: string | null

  new_cards:
    - card_id: string
      title: string
      card_type: claim_rule | evidence_rule | reviewer_pattern | writing_pattern | patch_pattern | failure_mode | evaluation_obligation | related_work_positioning | terminology_rule | workflow_rule | open_question
      claim: string
      maturity: emerging | contested | open_question
      domain:
        - string
      source_round: string
      evidence_basis:
        artifact_refs:
          - artifact: string
            ids:
              - string
        critique_ids:
          - string
        claim_ids:
          - string
        patch_ids:
          - string
        diff_ids:
          - string
        finding_ids:
          - string
      applicability:
        applies_when:
          - string
        does_not_apply_when:
          - string
        misuse_risk: string
      rule:
        trigger_condition: string
        required_action: string
        forbidden_action: string
        stage_to_apply:
          - paper_state
          - claim_evidence_grounding
          - reviewer_critique
          - writing_strategy
          - revision_plan
          - apply_paper_patch
          - claim_alignment
          - knowledge_delta
      examples:
        positive_example: string | null
        negative_example: string | null
      future_use: string

  updated_cards:
    - card_id: string
      update_type: reinforce | revise | narrow_scope | broaden_scope | link_related | increase_maturity
      previous_maturity: emerging | reinforced | stable | contested | open_question
      new_maturity: emerging | reinforced | stable | contested | open_question
      update_rationale: string
      new_evidence_basis:
        artifact_refs:
          - artifact: string
            ids:
              - string
      scope_change: string | null

  deprecated_cards:
    - card_id: string
      reason: contradicted | too_vague | unsafe_to_reuse | superseded | duplicate | out_of_scope
      evidence_basis:
        artifact_refs:
          - artifact: string
            ids:
              - string
      replacement_card_id: string | null

  knowledge_conflicts:
    - conflict_id: string
      existing_card_id: string
      new_candidate_or_card_id: string
      conflict_type: contradiction | scope_mismatch | terminology_conflict | evidence_update | duplicate | unsafe_generalization
      description: string
      recommended_resolution: keep_existing | replace_existing | merge | split_scope | human_decision_required | deprecate_existing
      rationale: string

  open_questions:
    - question_id: string
      question: string
      source_artifacts:
        - string
      why_unresolved: string
      evidence_or_decision_needed: string
      suggested_future_workflow: paper | survey | design | proposal | experiment
      suggested_target_unit: string | null
      priority: high | medium | low
      risk_if_ignored: fatal | high | medium | low

  card_files_to_write:
    - card_id: string
      action: create | update | deprecate
      path: string
```

## Quality Gates

* `knowledge-delta.yaml` must be produced.
* At least one new, updated, deprecated, conflict, or open-question entry must exist unless `no_delta: true`.
* `no_delta: true` requires a specific justification explaining what was examined and why no durable knowledge was produced.
* Every new card must have a one-sentence claim.
* Every new card must include applicability and non-applicability conditions.
* Every new card must cite specific round artifacts, not vague phrases such as “from the critique.”
* Every rule must specify trigger condition, required action, forbidden action, and stage where it applies.
* Every knowledge item must be reusable beyond this round.
* Every dangerous reviewer pattern, evidence failure, or claim-alignment failure marked high/fatal must either become a card, update an existing card, become an open question, or be explicitly excluded with rationale.
* Duplicate check against existing cards must be performed.
* Knowledge conflicts must be recorded.
* New cards must not be marked `stable` unless explicitly permitted by knowledge discipline.
* No raw source summary, patch summary, or round-specific edit may be stored as durable knowledge.
* `key_insight` must be one sentence and must capture the most transferable lesson of the round.

## Failure Conditions

Stop and report a blocker if:

* existing knowledge cards cannot be inspected and duplicate checking is required;
* no knowledge delta and no no-delta justification are produced;
* a new card duplicates an existing card without update rationale;
* a card lacks artifact trace;
* a card is too vague to guide future behavior;
* stable knowledge is proposed without sufficient maturity basis;
* a high/fatal residual risk is omitted from knowledge, conflict, or open-question handling;
* knowledge would mislead future rounds if injected automatically.

## Forbidden Behavior

* Do not summarize the round.
* Do not create cards for local patch details.
* Do not create vague cards such as “make claims clearer.”
* Do not store unsupported opinions.
* Do not store project-favorable conclusions without scope.
* Do not inflate maturity.
* Do not skip duplicate checking.
* Do not silently overwrite existing knowledge.
* Do not convert every critique into a card.
* Do not create cards that future rounds cannot act on.
* Do not modify the paper document.
* Do not directly modify `_cr/knowledge/`.

## Advance Rule

After `knowledge-delta.yaml` is produced and all quality gates pass, run `cr stage advance`.

```
```
