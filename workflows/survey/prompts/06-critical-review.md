# Stage 6: Critical Review

# Purpose

Critically review the updated survey taxonomy, comparison matrix, gap analysis, evidence base, and related-work positioning after taxonomy synthesis.

This stage is part of the **survey workflow**. Its goal is not to polish the survey. Its goal is to attack the survey as an OSDI/SOSP-level reviewer would: by testing whether the taxonomy is explanatory, evidence-backed, fair to competing systems, robust to edge cases, and strong enough to support later writing or project positioning.

A critical review is invalid if it only says the survey could be clearer or more complete. Every critique must identify a concrete failure mode, affected source/system/dimension/claim/paragraph, evidence basis, reviewer risk, and required repair.

## Inputs

* `taxonomy-update.yaml` — updated taxonomy, dimensions, category changes, system classifications, and gap updates.
* `comparison-matrix.yaml` — system × dimension comparison matrix.
* `gap-analysis-update.yaml` — filled, reframed, remaining, and newly discovered gaps.
* `taxonomy-rationale.md` — rationale for taxonomy design decisions.
* `taxonomy-risks.yaml` — unresolved taxonomy risks from synthesis.
* `evidence-ledger.yaml` — evidence backing classification, comparison dimensions, and gap claims.
* `source-index.yaml` — source metadata and source reliability.
* `source-analysis-matrix.yaml` — source-level mechanism, boundary, trust model, limitation, and taxonomy impact.
* `dangerous-baselines.yaml` — baselines that threaten taxonomy, novelty, gap analysis, or positioning.
* `source-notes.md` — narrative source analysis.
* `survey-state.yaml` — original gaps, weak spots, and previous taxonomy.
* Target survey document — current survey text and target units.
* Project knowledge — project claims, intended positioning, known related work, and unresolved reviewer objections.

## Allowed Writes

* `critical-review.yaml`
* `review-disposition.yaml`
* `coverage-risk.yaml`
* `taxonomy-attack-report.md`

No target survey document edits are allowed in this stage.

## Required Procedure

### Step 1: Reconstruct the Survey Argument

Before criticizing, reconstruct what the survey is trying to argue.

Identify:

* the main taxonomy claim;
* the main classification dimensions;
* the intended design-space explanation;
* the major comparison axes;
* the gap analysis;
* the project's intended position in the taxonomy, if any;
* the survey's implicit contribution to the paper or project.

This reconstruction must be charitable but precise. Do not attack a strawman. The critique must attack the strongest plausible version of the survey.

### Step 2: Attack Taxonomy Validity

Evaluate whether the taxonomy is structurally defensible.

Ask:

* Are classification dimensions semantically distinct?
* Are category boundaries clear enough to apply consistently?
* Does each dimension capture one concept, or does it mix mechanism, goal, implementation, and deployment?
* Are systems classified by evidence rather than intuition?
* Are hybrid systems handled explicitly?
* Are edge cases hidden or forced into categories?
* Are taxonomy-breaking systems treated as evidence for revision?
* Does the taxonomy explain design tradeoffs, or merely group papers by topic?
* Would a knowledgeable systems reviewer accept these categories?

For every weakness, record:

* affected dimension or category;
* affected systems;
* evidence that exposes the weakness;
* likely reviewer objection;
* required taxonomy repair.

### Step 3: Attack Orthogonality and Dimension Design

For every taxonomy dimension, test:

* Does it overlap with another dimension?
* Does it depend on another dimension in a way that makes it non-independent?
* Does it apply across most surveyed systems?
* Does it produce meaningful distinctions?
* Does it hide an important mechanism-level difference?
* Does it separate systems that should be separated?
* Does it collapse systems that should be distinguished?

Do not interpret orthogonality as “each system belongs to only one category.” In a multidimensional taxonomy, a system may occupy values across multiple dimensions. The issue is whether each dimension has a coherent meaning and whether values within the same dimension are distinguishable by evidence.

### Step 4: Attack Coverage

Evaluate whether the survey corpus is sufficient and unbiased.

Ask:

* Which canonical systems are still missing?
* Which recent systems are missing?
* Which dangerous baselines are missing or under-integrated?
* Does the corpus overrepresent systems similar to the project?
* Does the corpus ignore systems that would make the project look weaker?
* Are adjacent research lines excluded without justification?
* Are older systems that anticipated the current framing missing?
* Are production systems, artifacts, standards, or security advisories needed?
* Are OSDI/SOSP/EuroSys/ATC/NSDI/ASPLOS/VEE-level papers adequately represented for the topic?

Coverage critique must distinguish:

* missing canonical work;
* missing recent work;
* missing dangerous baseline;
* missing edge case;
* missing implementation evidence;
* missing evaluation methodology;
* missing terminology source;
* missing production evidence.

Write coverage-specific risks into `coverage-risk.yaml`.

### Step 5: Attack Evidence Quality

For every taxonomy claim, comparison-cell value, and gap claim, check whether the evidence is strong enough.

Ask:

* Is the evidence direct or inferred?
* Is the source primary or secondary?
* Is the source authoritative enough for the claim?
* Is the source current?
* Does the cited evidence actually support the classification?
* Does the evidence support the exact comparison dimension?
* Are author claims treated as proven facts without checking evaluation or scope?
* Are limitations and non-goals incorporated?
* Are contradictions and narrowing evidence recorded?
* Are direct quotes traceable to raw source records?

A critique must be raised when a classification or gap relies on weak evidence, inference, secondary summaries, or outdated sources.

### Step 6: Attack Gap Analysis

Evaluate whether each gap is real.

For every filled, remaining, reframed, or new gap, ask:

* Is this gap supported by the comparison matrix?
* Were dangerous baselines considered?
* Could the gap be solved under different terminology?
* Is the gap actually a missing source rather than a research opportunity?
* Is it an artifact of an overly narrow taxonomy?
* Is it technically meaningful?
* Would OSDI/SOSP reviewers care about this gap?
* Does the gap overstate the project's novelty or importance?
* Does the gap require additional evidence before being used in the survey?

A gap is not valid merely because a matrix cell is empty. Empty cells must be interpreted as true open problem, missing evidence, not applicable, terminology mismatch, already solved elsewhere, technically infeasible, or under-searched.

### Step 7: Attack Dangerous Baseline Integration

For every entry in `dangerous-baselines.yaml`, verify that it is properly handled.

Ask:

* Is the baseline compared explicitly?
* Is it assigned to the correct taxonomy position?
* Does it weaken a claimed gap?
* Does it require adding or splitting a dimension?
* Does it expose a missing comparison axis?
* Is it fairly represented?
* Would a reviewer object that this baseline is ignored, misclassified, or dismissed too quickly?

If a dangerous baseline is not integrated into taxonomy, comparison matrix, gap analysis, or positioning, mark it as high or fatal risk.

### Step 8: Attack Writing and Survey Structure

Review the target survey document as a survey artifact.

Ask:

* Does the survey read as an explanatory taxonomy or a literature dump?
* Does each system appear for a reason?
* Are transitions between systems based on design dimensions rather than chronology or loose similarity?
* Does each paragraph explain what the reader should learn from the comparison?
* Are category introductions clear?
* Are comparison dimensions introduced before being used?
* Are source discussions too summary-like?
* Is the project's own position stated too early, too strongly, or too defensively?
* Are limitations of the taxonomy acknowledged?
* Does the survey fairly represent competing approaches?

This is not a sentence-polishing stage. The writing critique should focus on whether the survey structure communicates the taxonomy and gap analysis convincingly.

### Step 9: Generate Reviewer Objections

For each high or fatal critique, write the likely reviewer objection.

Use reviewer-style forms such as:

* “The taxonomy is not convincing because...”
* “The classification boundary between X and Y is unclear because...”
* “The survey misses important prior work, especially...”
* “The comparison is unfair because...”
* “The claimed gap appears to be solved or partially addressed by...”
* “The evidence does not support this classification because...”
* “The survey reads like a list of papers rather than a design-space analysis because...”
* “The project positioning is overstated because...”

The objection must be specific enough that a later revision plan can answer it.

### Step 10: Assign Severity and Repair Type

Every critique item must receive a severity:

* `fatal`: invalidates taxonomy, gap analysis, or core positioning unless repaired.
* `high`: likely to trigger reviewer rejection or major concern.
* `medium`: weakens clarity, fairness, or evidence but does not invalidate the survey.
* `low`: local issue that should be repaired but does not threaten the survey structure.

Every critique item must also receive a repair type:

* taxonomy revision;
* dimension redefinition;
* system reclassification;
* coverage expansion;
* evidence replacement;
* dangerous baseline integration;
* gap weakening;
* gap deletion;
* comparison matrix update;
* paragraph rewrite;
* transition rewrite;
* scope clarification;
* terminology clarification;
* human decision required.

### Step 11: Produce Review Disposition

For each critique, propose an initial disposition:

* accept and repair;
* partially accept;
* reject with rationale;
* defer to next round;
* human decision required.

This is not the final revision plan, but it must give enough direction for Stage 7.

## Output Contract
* `taxonomy-risks.yaml`

```yaml
critical-review.yaml:
  schema_version: "1.0.0"
  round_id: string
  project_id: string
  target_document: string

  review_summary:
    overall_judgment: defensible | defensible_if_repaired | unstable | rejectable
    main_failure_mode: taxonomy | coverage | evidence | gap_analysis | dangerous_baseline | writing_structure | positioning | mixed
    top_risks:
      - string

  critiques:
    - critique_id: string
      critique_type: taxonomy | orthogonality | coverage | evidence | gap_analysis | dangerous_baseline | writing_structure | positioning | terminology | scope
      severity: fatal | high | medium | low
      target:
        target_type: dimension | category | system | source | evidence_item | matrix_cell | gap | paragraph | section | project_positioning
        target_id: string
        location: string | null
      finding: string
      reviewer_objection: string
      evidence_basis:
        evidence_ids:
          - string
        source_ids:
          - string
        matrix_refs:
          - string
      why_it_matters: string
      required_repair:
        repair_type: taxonomy_revision | dimension_redefinition | system_reclassification | coverage_expansion | evidence_replacement | dangerous_baseline_integration | gap_weakening | gap_deletion | matrix_update | paragraph_rewrite | transition_rewrite | scope_clarification | terminology_clarification | human_decision_required
        description: string
      disposition_proposal: accept | partially_accept | reject | defer | human_decision_required
      blocks_survey_patch: boolean
```

```yaml
coverage-risk.yaml:
  schema_version: "1.0.0"
  missing_or_weak_coverage:
    - risk_id: string
      risk_type: missing_canonical_work | missing_recent_work | missing_dangerous_baseline | missing_edge_case | missing_artifact | missing_evaluation_source | missing_terminology_source | biased_corpus
      affected_gap_or_dimension: string
      missing_source_or_area: string
      severity: fatal | high | medium | low
      why_it_matters: string
      required_search_or_repair: string
```

```yaml
review-disposition.yaml:
  schema_version: "1.0.0"
  dispositions:
    - critique_id: string
      proposed_action: accept_and_repair | partially_repair | reject_with_rationale | defer_to_next_round | require_human_decision
      rationale: string
      expected_stage7_action: string
```

## Quality Gates

* Every critique item must point to a concrete system, source, evidence item, dimension, matrix cell, gap, paragraph, or section.
* Every high or fatal critique must include a reviewer-style objection.
* Every critique must have evidence basis or explicit reasoning from taxonomy structure.
* Every dangerous baseline must be reviewed for integration.
* Every taxonomy-breaking source must be reviewed.
* Every original and new gap must be checked against dangerous baselines.
* Every comparison dimension must be checked for overlap, applicability, and evidence support.
* Every source with weak or inferred evidence must be flagged if used for a strong classification.
* Writing critique must distinguish taxonomy-communication failure from local prose polish.
* The review must produce actionable repairs for Stage 7.

## Failure Conditions

Stop and report a blocker if:

* evidence files are missing or inconsistent;
* taxonomy-update cannot be linked to evidence-ledger;
* comparison matrix is absent or too incomplete to review;
* dangerous baselines are missing despite being required by the research plan;
* the taxonomy is too unstable to support revision planning;
* gap analysis depends on under-sourced or unverified claims;
* the critical review cannot produce concrete, evidence-backed critique items.

## Forbidden Behavior

* Do not produce vague critique.
* Do not say “needs more clarity” without identifying the paragraph, dimension, or missing logic.
* Do not defend the survey by default.
* Do not ignore dangerous baselines.
* Do not treat taxonomy as valid because it is internally tidy.
* Do not treat author claims as evidence without checking source reliability and scope.
* Do not collapse coverage, evidence, taxonomy, and writing problems into one generic critique.
* Do not modify the target survey document in this stage.
* Do not defer all hard issues to later stages without recording blocker or human-decision status.

## Advance Rule

After `critical-review.yaml`, `coverage-risk.yaml`, `review-disposition.yaml`, and `taxonomy-attack-report.md` are produced and all quality gates pass, run `cr stage advance`.

```
```
