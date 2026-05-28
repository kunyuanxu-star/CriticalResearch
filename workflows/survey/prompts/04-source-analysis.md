# Stage 4: Source Analysis

# Purpose

Find, read, verify, and analyze sources identified in `research-plan.yaml` in order to support a rigorous survey, taxonomy, comparison matrix, and gap analysis.

This stage is part of the **survey workflow**. Its goal is not to review the target paper's own claims. Its goal is to understand external systems, papers, artifacts, and documentation well enough to determine how they should be classified, compared, and positioned in the survey.

A source analysis is invalid if it only summarizes what a paper says. It must determine what the source implies for the survey's taxonomy, comparison dimensions, related-work structure, and research gaps.

## Inputs

* `research-plan.yaml` — prioritized source targets, critical-search targets, venue-norm targets, and stop conditions.
* `survey-state.yaml` — current taxonomy, gaps, weak spots, missing sources, and comparison dimensions.
* Target survey document — current survey text for context.
* Project knowledge — existing related work, known systems, and prior knowledge cards.
* `references/evidence-standards.md` — evidence quality and source reliability rules.
* `references/domain-profiles.md` — domain-specific expectations.
* `references/evaluation-contracts.md` — claim type to evidence type mapping, when source claims need evaluation interpretation.

## Allowed Writes

* `source-index.yaml`
* `raw-sources/`
* `evidence-ledger.yaml`
* `source-notes.md`
* `source-analysis-matrix.yaml`
* `taxonomy-impact.yaml`
* `dangerous-baselines.yaml`

No target survey document edits are allowed in this stage.

## Required Procedure

### Step 1: Locate and Verify Sources

For every Tier 1 and Tier 2 target in `research-plan.yaml`, locate the best available source.

Prefer sources in this order:

1. peer-reviewed paper from OSDI, SOSP, EuroSys, USENIX ATC, NSDI, ASPLOS, VEE, FAST, CCS, USENIX Security, IEEE S&P, NDSS, PLDI, POPL, OOPSLA, SIGMOD, VLDB, or comparable venues;
2. official artifact repository;
3. official system documentation;
4. author-maintained technical report;
5. maintainer issue, mailing-list discussion, design document, or postmortem;
6. secondary source only when primary sources are unavailable.

For every source, record:

* source ID
* title
* authors or maintainers
* venue or publication channel
* year
* URL or artifact location
* source type
* retrieval date
* source reliability level
* whether it is primary, secondary, or tertiary
* which research-plan target it satisfies

Write this into `source-index.yaml`.

If the source is accessible, preserve a raw note or metadata record under `raw-sources/`.

### Step 2: Extract Source-Level Research Object

For each source, identify the research object precisely.

Extract:

* system, mechanism, tool, abstraction, framework, protocol, algorithm, benchmark, or deployment studied;
* problem setting;
* target workload or threat model;
* isolation boundary, if relevant;
* resource boundary, if relevant;
* trust model;
* assumptions;
* claimed target properties;
* non-goals;
* limitations explicitly stated by the authors.

Do not classify a source before its object and assumptions are clear.

### Step 3: Extract Mechanism and Boundary

For each source, extract the concrete mechanism, not only the authors' high-level description.

Record:

* where the mechanism sits in the system stack;
* what boundary it introduces, moves, removes, or strengthens;
* what resource or state it isolates, multiplexes, virtualizes, verifies, or replicates;
* what authority model it assumes;
* what is trusted and untrusted;
* what policy decisions are centralized or delegated;
* what performance, security, or compatibility cost the mechanism introduces;
* what cases the mechanism does not handle.

For systems work, avoid vague labels such as "container-based", "VM-based", "language-based", or "lightweight" unless the source is decomposed into its actual enforcement mechanism.

### Step 4: Map Source to Current Taxonomy

For every source, determine how it relates to the current taxonomy in `survey-state.yaml`.

Classify the relation as:

* confirms existing category;
* refines existing category;
* spans multiple categories;
* creates a new category;
* contradicts current category boundary;
* exposes missing dimension;
* exposes overloaded dimension;
* should be treated as an edge case;
* should be excluded from the survey scope.

For each classification, provide the reason.

Do not force a source into the existing taxonomy if it breaks the taxonomy. Taxonomy-breaking sources are high-value findings.

Write this into `taxonomy-impact.yaml`.

### Step 5: Extract Evidence for Comparison Dimensions

For each source, extract evidence relevant to comparison dimensions such as:

* isolation boundary;
* threat model;
* trusted computing base;
* resource accounting;
* scheduling model;
* memory isolation;
* I/O isolation;
* device model;
* compatibility;
* performance overhead;
* deployment model;
* programmability;
* fault containment;
* policy isolation;
* heterogeneity;
* implementation complexity;
* evaluation methodology.

Each evidence item must include:

* source ID;
* evidence text or paraphrase;
* evidence type;
* confidence level;
* whether it is direct evidence, inference, or secondary interpretation;
* taxonomy dimension affected;
* comparison dimension affected;
* relation to the survey: supports, weakens, contradicts, contextualizes, or narrows scope.

Write this into `evidence-ledger.yaml`.

### Step 6: Identify Dangerous Baselines

For every source, decide whether it is a dangerous baseline for the survey's target idea or taxonomy.

A source is dangerous if:

* it solves a similar problem with a different abstraction;
* it weakens the novelty of the target framing;
* it makes one taxonomy category ambiguous;
* it provides a stronger comparison point than currently discussed;
* it shows that a claimed gap is already partially solved;
* it suggests that the survey's proposed distinction is too coarse;
* it would likely be raised by an OSDI/SOSP reviewer.

For each dangerous baseline, record:

* baseline source ID;
* why it is dangerous;
* which survey claim, gap, or taxonomy dimension it threatens;
* what comparison must be added;
* what wording or classification may need to change.

Write this into `dangerous-baselines.yaml`.

### Step 7: Search for Counterevidence and Edge Cases

For each major taxonomy dimension and gap, actively identify sources that may weaken or contradict the current analysis.

Look for:

* systems that do not fit cleanly into current categories;
* systems that combine categories;
* systems that achieve similar goals with a different boundary;
* negative results;
* limitations in artifacts or documentation;
* production systems that violate academic assumptions;
* security advisories or failure cases;
* benchmarks showing different tradeoffs;
* old systems that anticipated the claimed idea.

Record whether each finding:

* invalidates a taxonomy boundary;
* narrows a claim;
* requires adding a new comparison dimension;
* requires adding a limitation;
* requires changing gap analysis;
* can be safely treated as out of scope.

### Step 8: Analyze OSDI/SOSP Survey-Relevant Patterns

When a source is an OSDI/SOSP paper or a comparable top-tier systems paper, also extract survey-relevant rhetorical and structural patterns.

Do not perform a sentence-level writing audit here. Instead, extract patterns useful for later related-work and taxonomy writing:

* how the paper frames its problem;
* how it states the root cause;
* how it positions against prior systems;
* how it defines baselines;
* how it states limitations;
* how it names abstractions;
* how it organizes evaluation claims;
* how it distinguishes mechanism from implementation;
* how it avoids or commits overclaiming.

These patterns should be used later when rewriting the survey's taxonomy narrative or related-work section.

### Step 9: Produce Source Notes

Write `source-notes.md` as a narrative analysis, not a bibliography.

For each source, include:

* what the source is actually about;
* why it matters to the survey;
* where it fits in the taxonomy;
* what dimension it supports;
* what dimension it challenges;
* what comparison it enables;
* what limitation or assumption must be remembered;
* whether it changes the current survey structure;
* whether it is a dangerous baseline;
* whether it should affect gap analysis.

### Step 10: Produce Source Analysis Matrix

Write `source-analysis-matrix.yaml` to make comparison explicit.

Each source must be mapped to:

* taxonomy category;
* comparison dimensions;
* mechanism type;
* boundary placement;
* target property;
* evidence strength;
* baseline role;
* limitation;
* taxonomy impact;
* gap impact.

This matrix will be used by the next stage, `taxonomy_synthesis`.

## Output Contract

```yaml
source-index.yaml:
  schema_version: "1.0.0"
  sources:
    - source_id: string
      title: string
      authors_or_maintainers: string
      venue_or_channel: string
      year: integer | null
      url: string
      source_type: paper | artifact | documentation | technical_report | issue | mailing_list | standard | benchmark | postmortem | advisory | secondary
      source_level: S | A | B | C | D
      primary_source: boolean
      retrieved_at: string
      linked_research_plan_targets:
        - string

evidence-ledger.yaml:
  schema_version: "1.0.0"
  evidence:
    - evidence_id: string
      source_id: string
      evidence_text: string
      evidence_mode: direct_quote | paraphrase | inference | secondary_summary
      confidence: high | medium | low
      relation: supports | weakens | contradicts | contextualizes | narrows_scope
      taxonomy_dimension: string
      comparison_dimension: string
      affected_gap_ids:
        - string
      notes: string

taxonomy-impact.yaml:
  schema_version: "1.0.0"
  impacts:
    - source_id: string
      current_taxonomy_relation: confirms | refines | spans_categories | creates_category | contradicts_boundary | exposes_missing_dimension | exposes_overloaded_dimension | edge_case | out_of_scope
      affected_categories:
        - string
      required_taxonomy_change: none | rename_category | split_category | merge_category | add_dimension | add_category | add_edge_case | narrow_scope
      rationale: string

dangerous-baselines.yaml:
  schema_version: "1.0.0"
  baselines:
    - source_id: string
      baseline_name: string
      why_dangerous: string
      threatens:
        - taxonomy
        - novelty
        - gap_analysis
        - comparison_matrix
        - related_work_positioning
        - claim_scope
      required_comparison: string
      repair_implication: string

source-analysis-matrix.yaml:
  schema_version: "1.0.0"
  rows:
    - source_id: string
      research_object: string
      problem_setting: string
      mechanism: string
      boundary_or_abstraction: string
      trust_model: string
      target_property:
        - string
      taxonomy_category: string
      comparison_dimensions:
        - string
      limitations:
        - string
      evidence_strength: S | A | B | C | D
      baseline_role: canonical | dangerous | recent | edge_case | peripheral | out_of_scope
      taxonomy_impact: string
      gap_impact: string
```

## Quality Gates

* Every Tier 1 source target in `research-plan.yaml` must be resolved or explicitly marked as unresolved with a blocker.
* Every analyzed source must appear in `source-index.yaml`.
* Every evidence item must reference a valid `source_id`.
* Every direct quote must be traceable to a raw source record.
* Every source must have a taxonomy-impact judgment.
* Every source must have at least one comparison-dimension judgment unless marked out of scope.
* Every dangerous baseline must be explicitly recorded.
* At least one weakening, contradicting, narrowing, or taxonomy-breaking evidence item must be searched for in standard/deep mode.
* A source may not be treated as supportive unless its assumptions and scope match the survey claim it supports.
* A source may not be forced into an existing category when it exposes a missing or overloaded taxonomy dimension.
* Source notes must explain how the source changes, confirms, or challenges the current survey; simple summaries are insufficient.

## Failure Conditions

Stop and report a blocker if:

* a Tier 1 canonical source cannot be found;
* a source cannot be verified as primary or reliable enough for its intended role;
* a dangerous baseline is found but cannot be classified;
* a source contradicts the current taxonomy and no taxonomy revision path is clear;
* the research plan requires OSDI/SOSP exemplar sources but none can be found;
* the survey-state taxonomy is too vague to classify sources consistently;
* evidence is insufficient to support any comparison dimension for a source.

## Forbidden Behavior

* Do not summarize papers without extracting taxonomy impact.
* Do not collect only supportive evidence.
* Do not ignore sources that break the current taxonomy.
* Do not classify by keyword alone.
* Do not treat author claims as proven evidence without checking evaluation, assumptions, and scope.
* Do not use secondary summaries when primary sources are available.
* Do not collapse mechanism, abstraction, implementation, and evaluation into one vague description.
* Do not treat related work as a flat bibliography.
* Do not modify the target survey document in this stage.

## Advance Rule

After all required files are produced and all quality gates pass, run `cr stage advance`.
