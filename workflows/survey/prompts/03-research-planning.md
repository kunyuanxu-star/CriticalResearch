# Stage 3: OSDI/SOSP-Grounded Research Planning

# Purpose

Plan a research process that can support OSDI/SOSP-level critique, evidence grounding, related-work positioning, and writing review.

This stage does not merely decide which papers to search. It defines what must be investigated so that later stages can judge whether the target survey, design, or paper would survive top-tier systems review.

The plan must cover four dimensions:

1. **Source hunting**: what papers, systems, artifacts, documents, standards, issue discussions, and benchmarks must be found.
2. **Critical investigation**: what counterexamples, dangerous baselines, alternative explanations, and negative evidence must be searched.
3. **Venue-norm research**: what OSDI/SOSP standards and accepted papers must be studied to infer top-tier expectations.
4. **Writing-pattern research**: what exemplar papers must be inspected to learn how OSDI/SOSP papers construct problem statements, root causes, insights, contributions, evaluations, and related-work positioning.

A research plan is invalid if it only collects supportive sources. It must deliberately search for sources that could weaken, contradict, narrow, or invalidate the current analysis.

## Inputs

* `contract.yaml` — round scope, target document, target units, workflow mode, and mutable document.
* `survey-state.yaml` — current taxonomy, gaps, weak spots, missing related work, and unresolved assumptions.
* Project knowledge — existing related work, known systems, prior knowledge cards, and unresolved reviewer objections.
* Target document — current survey/paper/design text if available.
* `references/evidence-standards.md` — evidence quality rules.
* `references/domain-profiles.md` — domain-specific source and evaluation expectations.
* `references/evaluation-contracts.md` — claim type to evidence type mapping.

## Allowed Writes

* `research-plan.yaml`
* `source-hunting-plan.yaml`
* `critical-search-plan.yaml`
* `venue-norm-research-plan.yaml`
* `writing-pattern-research-plan.yaml`

No target document edits are allowed in this stage.

## Task

Produce a research plan that is strong enough to drive later OSDI/SOSP-level source analysis, critical review, writing audit, and revision planning.

## Required Procedure

### Step 1: Identify Research Gaps from Survey State

For every gap, weak spot, missing comparison, vague taxonomy dimension, unsupported claim, or unresolved assumption in `survey-state.yaml`, determine:

* What exactly is unknown?
* Why does this gap matter?
* Which later reviewer objection could arise if the gap remains unresolved?
* Is the gap about missing sources, missing taxonomy dimensions, missing evidence, missing baselines, weak problem framing, or weak writing pattern?
* What kind of source would resolve the gap?

Classify each gap as:

* taxonomy gap
* canonical related-work gap
* dangerous-baseline gap
* evidence gap
* counterexample gap
* evaluation-method gap
* venue-norm gap
* writing-pattern gap
* terminology gap
* scope/assumption gap

### Step 2: Plan Venue-Norm Research

The plan must include official OSDI/SOSP venue criteria and author instructions as required sources.

Extract planning targets for:

* novelty
* significance
* interest to systems community
* clarity
* relevance
* correctness
* problem importance
* compelling solution
* practicality and benefits
* contribution clarity
* advance beyond previous work
* accessibility to the broader systems community
* standalone submission requirements
* concision expectations
* artifact and reproducibility expectations
* author-response constraints, if relevant

The plan must specify how these criteria will later be used to evaluate the target document.

Output this part to `venue-norm-research-plan.yaml`.

### Step 3: Build an Exemplar Paper Search Plan

Identify OSDI/SOSP-level exemplar papers that should be studied not only for technical content but also for research style.

For each exemplar target, specify:

* why this paper is relevant
* which aspect it teaches:

  * problem framing
  * root-cause construction
  * technical insight
  * system design structure
  * implementation credibility
  * evaluation contract
  * baseline selection
  * related-work positioning
  * contribution wording
  * limitation wording
  * paragraph and sentence logic
* what exact pattern should be extracted from it

The plan should include:

* recent OSDI/SOSP papers in the same area
* canonical OSDI/SOSP papers that shaped the research line
* adjacent systems papers from EuroSys, ATC, NSDI, ASPLOS, VEE, FAST, CCS, Security, or PLDI when directly relevant
* dangerous papers that reviewers are likely to know

Output this part to `writing-pattern-research-plan.yaml`.

### Step 4: Plan Canonical Source Hunting

For each technical gap, define concrete source targets:

* specific papers or systems that must be found
* likely venues
* likely keywords
* likely author groups or project names
* official documentation or artifact repositories
* production reports or postmortems, if relevant
* standards, RFCs, CVEs, mailing-list discussions, or issue trackers, if relevant

For each source target, record:

* expected contribution
* taxonomy dimension it may inform
* claim types it may support or weaken
* whether it is canonical, recent, dangerous, or peripheral
* what would happen if this source is missing

Classify source targets into:

* Tier 1: canonical or dangerous sources that could invalidate the analysis if missing
* Tier 2: recent sources that may shift the taxonomy or reviewer expectation
* Tier 3: edge cases, niche systems, or peripheral evidence for completeness

Output this part to `source-hunting-plan.yaml`.

### Step 5: Plan Critical Search

For every major claim, taxonomy dimension, and proposed gap, search planning must include adversarial queries.

The plan must explicitly search for:

* counterexamples
* negative results
* systems that solve the same problem differently
* systems that make the proposed taxonomy boundary ambiguous
* stronger baselines
* older papers that may already contain the claimed insight
* production systems that invalidate academic assumptions
* benchmarks or workloads where the claimed approach may fail
* security, performance, compatibility, or scalability limitations
* terminology conflicts
* cases where the current framing overgeneralizes

For each critical search target, state:

* what claim or taxonomy dimension it could weaken
* what evidence would count as contradiction
* what evidence would merely narrow the scope
* what evidence would require a taxonomy revision
* what evidence would force a reviewer-risk item

Output this part to `critical-search-plan.yaml`.

### Step 6: Define Analysis Framework

For each candidate source, define what later source analysis must extract:

* research object
* problem setting
* target property
* threat model or workload model
* core claim
* assumptions
* mechanism
* boundary or abstraction
* implementation scale
* evaluation method
* baselines
* limitations
* relation to target taxonomy
* relation to target paper claims
* relation to OSDI/SOSP acceptance criteria
* writing pattern, if the source is an exemplar paper

Each source must be assigned one or more analysis roles:

* taxonomy evidence
* claim support
* claim weakening
* baseline
* counterexample
* venue exemplar
* writing exemplar
* evaluation exemplar
* terminology source
* implementation feasibility source

### Step 7: Define Search Queries

For each gap and source target, generate concrete search queries.

Queries should include:

* venue-specific queries
* system-name queries
* problem-framing queries
* baseline queries
* counterexample queries
* artifact/documentation queries
* implementation/evaluation queries
* writing-pattern queries

Every Tier 1 gap must include at least one supportive query and one adversarial query.

Example query categories:

* `site:usenix.org OSDI <topic> <system>`
* `site:sosp.org <topic> operating systems`
* `"<problem term>" OSDI SOSP`
* `"<system name>" artifact evaluation`
* `"<claim keyword>" baseline`
* `"<approach>" limitations`
* `"<topic>" "SOSP" "evaluation"`
* `"<topic>" "OSDI" "root cause"`
* `"<topic>" "related work" "baseline"`

### Step 8: Define Stop Conditions

Searching may stop only when saturation criteria are met.

For each gap, define:

* minimum number of Tier 1 sources
* minimum number of recent sources
* minimum number of dangerous baselines
* minimum number of counterexample or weakening sources
* minimum number of exemplar papers, if writing or venue-norm analysis is required
* conditions under which no more search is useful
* conditions under which human judgment is required

The plan must distinguish:

* search saturation
* evidence saturation
* taxonomy saturation
* reviewer-risk saturation
* writing-pattern saturation

A search is not saturated merely because several papers have been found. It is saturated only when new sources stop changing the taxonomy, claim judgment, baseline set, reviewer-risk model, or writing strategy.

### Step 9: Define Failure Conditions

The research plan must explicitly identify blockers.

Stop and report a blocker if:

* no OSDI/SOSP-level exemplar can be found for the topic
* no dangerous baseline can be identified
* no source can support a core taxonomy dimension
* no source can test a major claim
* the topic appears outside OSDI/SOSP scope
* the current taxonomy is too vague to guide source search
* the current claim set is too vague to determine required evidence
* the search space is too broad and requires human narrowing
* key terminology is unstable or ambiguous

### Step 10: Produce Research Plan

Write `research-plan.yaml` with the following structure.

## Outputs
- `research-plan.yaml` — master research plan with gap analysis, queries, stop conditions, and blocker registry
- `source-hunting-plan.yaml` — canonical and dangerous source targets with tier classification
- `critical-search-plan.yaml` — adversarial search targets for counterexamples, baselines, and weakening evidence
- `venue-norm-research-plan.yaml` — venue criteria, author instructions, and acceptance-standard research targets
- `writing-pattern-research-plan.yaml` — exemplar paper search targets for studying OSDI/SOSP writing patterns


```yaml
schema_version: "2.0.0"
round_id: string
project_id: string
target_document: string
target_units:
  - string

planning_summary:
  objective: string
  target_venues:
    - OSDI
    - SOSP
  research_posture: adversarial
  planning_judgment: string

gap_inventory:
  - gap_id: string
    source: survey-state.yaml
    gap_type: taxonomy_gap | canonical_related_work_gap | dangerous_baseline_gap | evidence_gap | counterexample_gap | evaluation_method_gap | venue_norm_gap | writing_pattern_gap | terminology_gap | scope_assumption_gap
    description: string
    why_it_matters: string
    likely_reviewer_objection: string
    required_resolution: string
    priority: tier1 | tier2 | tier3

venue_norm_targets:
  - target_id: string
    venue: OSDI | SOSP
    source_type: official_cfp | author_instruction | review_policy | artifact_policy
    expected_extraction:
      - novelty
      - significance
      - clarity
      - correctness
      - contribution
      - advance_beyond_prior_work
      - standalone_requirement
      - concision
    later_use: string

exemplar_paper_targets:
  - target_id: string
    expected_paper_or_area: string
    venue_priority:
      - SOSP
      - OSDI
      - EuroSys
      - ATC
      - NSDI
      - ASPLOS
      - VEE
    why_needed: string
    pattern_to_extract:
      - problem_framing
      - root_cause
      - insight
      - design_structure
      - evaluation_contract
      - baseline_strategy
      - claim_wording
      - paragraph_logic
    danger_level: high | medium | low

source_hunting_targets:
  - target_id: string
    linked_gap_ids:
      - string
    target_description: string
    likely_sources:
      - string
    likely_venues:
      - SOSP
      - OSDI
      - EuroSys
      - ATC
      - ASPLOS
      - VEE
      - NSDI
      - FAST
      - CCS
      - Security
      - PLDI
    source_role:
      - taxonomy_evidence
      - claim_support
      - claim_weakening
      - baseline
      - counterexample
      - venue_exemplar
      - writing_exemplar
      - evaluation_exemplar
      - terminology_source
      - implementation_feasibility_source
    priority: tier1 | tier2 | tier3
    invalidation_risk_if_missing: fatal | high | medium | low

critical_search_targets:
  - target_id: string
    attacks:
      - claim
      - taxonomy
      - baseline
      - evaluation
      - scope
      - novelty
      - terminology
    adversarial_question: string
    evidence_that_would_weaken_current_analysis: string
    evidence_that_would_invalidate_current_analysis: string
    required_queries:
      - string

search_queries:
  - query_id: string
    linked_target_id: string
    query: string
    query_type: supportive | adversarial | venue_norm | exemplar | artifact | baseline | counterexample | terminology
    expected_result_type: paper | artifact | documentation | benchmark | standard | issue | mailing_list | cve | postmortem
    priority: tier1 | tier2 | tier3

analysis_framework:
  extraction_fields:
    - research_object
    - problem_setting
    - target_property
    - assumptions
    - mechanism
    - boundary_or_abstraction
    - implementation_scale
    - evaluation_method
    - baselines
    - limitations
    - taxonomy_relation
    - claim_relation
    - reviewer_risk
    - writing_pattern
  classification_rules:
    taxonomy_classification: string
    evidence_strength: string
    dangerous_baseline: string
    counterexample: string
    venue_exemplar: string

stop_conditions:
  per_gap:
    - gap_id: string
      minimum_tier1_sources: integer
      minimum_recent_sources: integer
      minimum_dangerous_baselines: integer
      minimum_counterexamples_or_weakening_sources: integer
      minimum_exemplar_papers: integer
      saturation_condition: string
  global:
    search_saturation: string
    evidence_saturation: string
    taxonomy_saturation: string
    reviewer_risk_saturation: string
    writing_pattern_saturation: string

blockers:
  - blocker_id: string
    condition: string
    required_human_decision: string

source-hunting-plan.yaml:
  schema_version: "2.0.0"
  round_id: string
  source_targets:
    - target_id: string
      gap_id: string
      tier: tier_1 | tier_2 | tier_3
      expected_contribution: string
      taxonomy_dimension: string
      claim_types: [string]
      source_category: canonical | recent | dangerous | peripheral
      queries: [string]
      stop_condition: string

critical-search-plan.yaml:
  schema_version: "2.0.0"
  round_id: string
  critical_targets:
    - target_id: string
      claim_or_dimension: string
      search_category: counterexample | negative_result | alternative_approach | baseline | older_insight | production_invalidation | benchmark_failure | limitation | terminology_conflict | overgeneralization
      weakening_target: string
      contradiction_evidence_criteria: string
      scope_narrowing_criteria: string
      taxonomy_revision_criteria: string
      reviewer_risk_criteria: string
      queries: [string]
```

## Quality Gates

* Every gap in `survey-state.yaml` must map to at least one source hunting target.
* Every Tier 1 gap must have at least one supportive query and one adversarial query.
* Every core taxonomy dimension must have at least one planned canonical source and one planned dangerous baseline.
* Every major claim must have a planned evidence source or a planned falsification search.
* The plan must include OSDI/SOSP official criteria as venue-norm sources.
* The plan must include OSDI/SOSP exemplar papers when later writing or reviewer-level analysis is required.
* The plan must include counterexample search, not only related-work search.
* The plan must define saturation criteria; “search until enough papers are found” is not acceptable.
* The plan must distinguish canonical sources, recent sources, dangerous baselines, edge cases, and writing exemplars.
* The plan must identify what evidence would force taxonomy revision or claim weakening.

## Forbidden Behavior

* Do not only search for papers that support the current framing.
* Do not treat related work as a bibliography collection task.
* Do not assume OSDI/SOSP norms without checking official venue criteria and accepted-paper exemplars.
* Do not use vague targets such as “find more papers about X” without specifying why those papers matter.
* Do not ignore dangerous baselines because they may weaken the current argument.
* Do not plan writing review without planning exemplar-paper writing-pattern extraction.
* Do not define stop conditions by source count alone.
* Do not let the current taxonomy determine the search space without also searching for sources that may break the taxonomy.

## Advance Rule

After all required planning files are produced and quality gates pass, run `cr stage advance`.
