# Stage 5: Taxonomy Synthesis

# Purpose

Synthesize analyzed sources into a coherent, defensible, and critique-resistant survey taxonomy.

This stage is part of the **survey workflow**. Its purpose is not to produce a flat list of systems. Its purpose is to derive a taxonomy that explains why systems differ, what design dimensions matter, where existing work clusters, which boundaries are unstable, and what research gaps remain.

A good taxonomy must survive adversarial scrutiny. It must not merely classify sources that fit the current framing; it must also account for hybrid systems, edge cases, dangerous baselines, taxonomy-breaking sources, and evidence that forces the taxonomy to change.

## Inputs

* `evidence-ledger.yaml` — structured evidence from source analysis.
* `source-notes.md` — narrative source analysis.
* `source-index.yaml` — verified source metadata.
* `source-analysis-matrix.yaml` — source × mechanism × boundary × dimension matrix.
* `taxonomy-impact.yaml` — how each source confirms, refines, breaks, or extends the current taxonomy.
* `dangerous-baselines.yaml` — sources that threaten current classification, novelty, or gap analysis.
* `survey-state.yaml` — initial taxonomy, known gaps, weak spots, and current comparison dimensions.
* Target survey document — current taxonomy structure and related-work framing.
* Project knowledge — prior taxonomy decisions, known terminology, and unresolved survey questions.

## Allowed Writes

* `taxonomy-update.yaml`
* `comparison-matrix.yaml`
* `gap-analysis-update.yaml`
* `taxonomy-rationale.md`
* `taxonomy-risks.yaml`

No target survey document edits are allowed in this stage.
## Outputs

* `taxonomy-risks.yaml`

## Required Procedure

### Step 1: Reconstruct the Current Taxonomy

Start by reconstructing the taxonomy currently implied by `survey-state.yaml` and the target survey document.

Identify:

* existing categories;
* existing classification criteria;
* existing comparison dimensions;
* systems already assigned to each category;
* gaps or weak spots already known;
* implicit assumptions behind the taxonomy;
* terms whose meaning is unstable or overloaded.

Do not modify the taxonomy yet. First make the current structure explicit.

### Step 2: Separate Categories from Dimensions

Distinguish between:

* **taxonomy categories**: named groups of systems or approaches;
* **classification criteria**: rules for deciding category membership;
* **comparison dimensions**: axes along which all systems can be compared;
* **mechanism dimensions**: concrete enforcement, abstraction, implementation, or resource-management mechanisms;
* **scope dimensions**: assumptions, workloads, threat models, deployment settings, or compatibility goals.

Do not confuse category labels with comparison dimensions.

For example, a category such as “VM-based isolation” is not itself a comparison dimension. It may be explained by dimensions such as boundary placement, trusted computing base, resource multiplexing layer, device model, memory isolation mechanism, and guest compatibility.

### Step 3: Test Orthogonality and Boundary Clarity

For each proposed taxonomy dimension, check:

* Does this dimension measure one concept or several mixed concepts?
* Is it independent from other dimensions?
* Does it duplicate another dimension under a different name?
* Are values inside the dimension mutually distinguishable?
* Can a system be classified by evidence rather than intuition?
* Does the dimension apply consistently across all surveyed systems?
* Does the dimension expose meaningful tradeoffs?

Orthogonality does not require that each system belongs to only one category across the entire taxonomy. In a multidimensional taxonomy, a system may have one value per dimension and may also be a hybrid case. The requirement is that each dimension has a clear semantic meaning and does not overlap confusingly with other dimensions.

### Step 4: Classify Every Source

For every source in `source-analysis-matrix.yaml`, assign:

* taxonomy category;
* classification rationale;
* comparison-dimension values;
* mechanism type;
* boundary placement;
* target property;
* trust model;
* evaluation role;
* limitation;
* relation to existing gaps.

Every classification must cite evidence from `evidence-ledger.yaml`.

If a source cannot be classified cleanly, do not force it into a category. Mark it as:

* hybrid;
* edge case;
* taxonomy-breaking;
* out of scope;
* insufficient evidence.

Then explain what this implies for taxonomy revision.

### Step 5: Handle Taxonomy-Breaking Sources

Pay special attention to sources marked in `taxonomy-impact.yaml` as:

* `spans_categories`;
* `creates_category`;
* `contradicts_boundary`;
* `exposes_missing_dimension`;
* `exposes_overloaded_dimension`;
* `edge_case`.

For each such source, decide whether to:

* split an existing category;
* merge categories;
* add a new dimension;
* add a new category;
* narrow the survey scope;
* treat the source as an explicit edge case;
* revise terminology;
* leave the taxonomy unchanged with justification.

A taxonomy-breaking source is not a nuisance. It is evidence that the current taxonomy may be too coarse, too rigid, or based on the wrong abstraction.

### Step 6: Integrate Dangerous Baselines

Use `dangerous-baselines.yaml` to determine whether the taxonomy or gap analysis currently underestimates important prior work.

For every dangerous baseline, ask:

* Does it already solve part of the claimed gap?
* Does it make a proposed distinction less novel?
* Does it blur the boundary between categories?
* Does it require a new comparison dimension?
* Does it expose a missing axis such as deployment, compatibility, resource accounting, or fault containment?
* Would an OSDI/SOSP reviewer expect this baseline to appear in the survey?

If a dangerous baseline threatens the taxonomy, the taxonomy must be revised or the threat must be explicitly explained.

### Step 7: Build the Comparison Matrix

Construct a system × dimension matrix.

Rows should be systems, papers, mechanisms, or approaches. Columns should be comparison dimensions that are meaningful across the surveyed systems.

Each cell must be one of:

* evidence-backed value;
* partial value;
* not applicable;
* unknown;
* disputed;
* hybrid;
* out of scope.

Do not leave empty cells unexplained. An empty cell may mean missing evidence, true non-applicability, or an open research problem. These cases must be distinguished.

The matrix should make visible:

* clusters of similar systems;
* dimensions where systems differ sharply;
* dimensions where evidence is missing;
* dimensions where the target project may sit;
* dimensions that reveal open research opportunities.

### Step 8: Update Gap Analysis

Using the new taxonomy and comparison matrix, update the gap analysis.

For each original gap:

* filled;
* partially filled;
* invalidated;
* reframed;
* still open;
* under-sourced.

For each new gap discovered:

* what taxonomy dimension reveals it;
* which systems expose it;
* why existing work does not fully address it;
* whether it is a real research gap or merely a writing gap;
* what evidence is still needed;
* whether the gap is likely interesting to top-tier systems reviewers.

Do not overstate gaps. A gap is valid only if the survey has considered dangerous baselines and adjacent work.

### Step 9: Identify Open Research Cells

From the comparison matrix, identify cells or clusters that may represent open research problems.

A cell is not automatically an open problem because it is empty. It may be empty because:

* the dimension is irrelevant to that class of systems;
* no evidence was found;
* the survey has not searched enough;
* the problem is already solved under different terminology;
* the combination is technically infeasible;
* the combination is feasible but unexplored;
* the combination is explored but not in the selected corpus.

Classify every candidate open cell accordingly.

### Step 10: Produce Taxonomy Rationale

Write `taxonomy-rationale.md` explaining the design logic of the taxonomy.

It must answer:

* Why are these classification criteria chosen?
* Why are alternative classifications rejected?
* Which dimensions are orthogonal?
* Which dimensions intentionally interact?
* Which systems are hard to classify and why?
* What dangerous baselines shaped the taxonomy?
* What evidence forced category changes?
* What are the known limitations of the taxonomy?
* What should a reader learn from this taxonomy that a flat related-work list would not show?

### Step 11: Produce Taxonomy Risk Analysis

Write `taxonomy-risks.yaml` documenting remaining risks.

Risk types include:

* overloaded dimension;
* weak evidence;
* missing canonical source;
* unstable terminology;
* ambiguous category boundary;
* dangerous baseline not fully integrated;
* taxonomy too coarse;
* taxonomy too fine-grained;
* matrix dimension not consistently applicable;
* gap overclaim;
* survey scope mismatch.

Each risk must include severity and required repair.

## Output Contract

```yaml
taxonomy-update.yaml:
  schema_version: "1.0.0"
  round_id: string
  project_id: string
  target_document: string

  taxonomy_summary:
    previous_taxonomy: string
    updated_taxonomy: string
    major_changes:
      - string
    synthesis_judgment: string

  classification_dimensions:
    - dimension_id: string
      name: string
      definition: string
      dimension_type: category_axis | comparison_axis | mechanism_axis | scope_axis | evidence_axis
      values:
        - value: string
          definition: string
          inclusion_criteria:
            - string
          exclusion_criteria:
            - string
      orthogonality_rationale: string
      overlaps_with:
        - dimension_id: string
          explanation: string
      evidence_required_for_classification: string

  taxonomy_categories:
    - category_id: string
      name: string
      definition: string
      classification_rule: string
      representative_sources:
        - source_id: string
      boundary_cases:
        - source_id: string
          reason: string
      dangerous_baselines:
        - source_id: string
      limitations:
        - string

  system_classification:
    - source_id: string
      system_or_paper: string
      assigned_categories:
        - category_id: string
      dimension_values:
        - dimension_id: string
          value: string
          evidence_ids:
            - string
          confidence: high | medium | low
      classification_status: clean | hybrid | edge_case | taxonomy_breaking | out_of_scope | insufficient_evidence
      rationale: string

  taxonomy_changes:
    - change_id: string
      change_type: add_category | remove_category | split_category | merge_category | rename_category | add_dimension | remove_dimension | redefine_dimension | reclassify_system | narrow_scope | add_edge_case
      previous_state: string
      new_state: string
      evidence_ids:
        - string
      affected_sources:
        - source_id: string
      rationale: string

  gap_updates:
    original_gaps:
      - gap_id: string
        previous_status: open | weak | under_sourced
        new_status: filled | partially_filled | invalidated | reframed | still_open | under_sourced
        rationale: string
        evidence_ids:
          - string
    new_gaps:
      - gap_id: string
        description: string
        revealed_by_dimension: string
        revealed_by_sources:
          - source_id: string
        why_existing_work_is_insufficient: string
        dangerous_baselines_considered:
          - source_id: string
        evidence_needed: string
        reviewer_interest: high | medium | low

  open_research_cells:
    - cell_id: string
      matrix_location: string
      interpretation: true_open_problem | missing_evidence | not_applicable | terminology_mismatch | technically_infeasible | already_solved_elsewhere | under_searched
      rationale: string
      required_followup: string

  unresolved_risks:
    - risk_id: string
      risk_type: overloaded_dimension | weak_evidence | missing_canonical_source | unstable_terminology | ambiguous_boundary | dangerous_baseline | too_coarse | too_fine_grained | inconsistent_dimension | gap_overclaim | scope_mismatch
      severity: fatal | high | medium | low
      description: string
      required_repair: string
```

```yaml
comparison-matrix.yaml:
  schema_version: "1.0.0"
  rows:
    - source_id: string
      system_or_paper: string
      category: string
      cells:
        - dimension_id: string
          value: string
          status: evidence_backed | partial | not_applicable | unknown | disputed | hybrid | out_of_scope
          evidence_ids:
            - string
          notes: string
```

```yaml
gap-analysis-update.yaml:
  schema_version: "1.0.0"
  filled_gaps:
    - gap_id: string
      evidence_ids:
        - string
      explanation: string
  reframed_gaps:
    - gap_id: string
      old_framing: string
      new_framing: string
      reason: string
  remaining_gaps:
    - gap_id: string
      reason_still_open: string
      evidence_needed: string
  new_gaps:
    - gap_id: string
      description: string
      taxonomy_basis: string
      research_potential: high | medium | low
```

## Quality Gates

* Every source in `source-analysis-matrix.yaml` must be classified or explicitly marked as out of scope / insufficient evidence.
* Every classification must cite evidence from `evidence-ledger.yaml`.
* Every taxonomy dimension must have a definition, allowed values, and classification criteria.
* Every dimension must be tested for overlap with other dimensions.
* Every taxonomy-breaking source must trigger an explicit decision: revise taxonomy, add edge case, narrow scope, or justify no change.
* Every dangerous baseline must be integrated into the taxonomy, comparison matrix, or gap analysis.
* Every original gap must receive an updated status.
* Every new gap must be grounded in evidence, not intuition.
* Every empty matrix cell must be interpreted; empty does not automatically mean open problem.
* The taxonomy must explain more than a flat related-work list.
* The taxonomy must support future writing: a reader should understand what design space exists, where systems differ, and why the target project occupies a meaningful position.

## Failure Conditions

Stop and report a blocker if:

* the analyzed sources cannot be classified with the current dimensions;
* classification requires subjective judgment without evidence;
* a dangerous baseline invalidates a gap and no repair path is clear;
* too many systems are marked hybrid or edge case, indicating that the taxonomy is unstable;
* comparison dimensions do not apply consistently across sources;
* the taxonomy becomes a flat list of systems rather than an explanatory structure;
* the gap analysis depends on missing Tier 1 sources;
* the taxonomy overclaims open problems from unknown or under-searched cells.

## Forbidden Behavior

* Do not force every system into the current taxonomy.
* Do not treat orthogonality as “each system must fit only one category” across the entire taxonomy.
* Do not hide hybrid or edge-case systems.
* Do not create categories from terminology alone.
* Do not create comparison dimensions that cannot be applied across most sources.
* Do not infer open research gaps from empty matrix cells without evidence.
* Do not ignore dangerous baselines.
* Do not preserve the initial taxonomy if source evidence contradicts it.
* Do not modify the target survey document in this stage.
* Do not produce a taxonomy that is merely a bibliography grouped by topic.

## Advance Rule

After `taxonomy-update.yaml`, `comparison-matrix.yaml`, `gap-analysis-update.yaml`, `taxonomy-rationale.md`, and `taxonomy-risks.yaml` are produced and quality gates pass, run `cr stage advance`.

```
```
