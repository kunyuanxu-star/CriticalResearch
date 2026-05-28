# Stage 3: OSDI/SOSP Reviewer-Grounded Claim-Evidence Analysis

## Purpose

This stage evaluates the target paper through the lens of an OSDI/SOSP-level systems reviewer. It does not merely check whether each claim has some evidence. It determines whether the paper's problem, insight, design, implementation, evaluation, and positioning would be considered defensible by a top-tier systems program committee.

This stage must simultaneously perform two tasks:

1. **Venue-grounded research**: study how OSDI/SOSP-level papers in the same area structure their motivation, technical insight, system design, evaluation, baselines, and claims.
2. **Reviewer-grounded audit**: use the extracted venue norms and exemplar-paper patterns to assess whether the target paper's claims, evidence, argument flow, and evaluation obligations are strong enough for OSDI/SOSP review.

A claim without evidence is a vulnerability. A claim with evidence but without top-tier relevance, novelty, baseline strength, or evaluation alignment is also a vulnerability. This stage must expose both kinds of weakness.

## Stage Type

research-and-analysis-only

This stage may write structured analysis artifacts but must not modify the target paper. Concrete rewriting belongs to later stages.

## Required Inputs

* `paper-state.yaml` — claim inventory, contribution inventory, section structure, and known weak spots.
* `contract.yaml` — round scope, mutable document, target units, and read-only context.
* Target paper document — the paper under review.
* `references/evidence-standards.md` — evidence quality rules.
* `references/evaluation-contracts.md` — claim-type to evaluation-type mapping.
* `references/domain-profiles.md` — area-specific systems-review expectations.
* `workflows/paper/profile.md` — paper workflow semantics.
* External sources:

  * OSDI/SOSP official call-for-papers and author instructions.
  * Recent OSDI/SOSP accepted papers in the same or adjacent area.
  * Canonical OSDI/SOSP papers that define the relevant research style, baseline standard, or evaluation norm.

## Allowed Writes

* `venue-norm-ledger.yaml`
* `exemplar-paper-analysis.yaml`
* `claim-evidence-grounding.yaml`
* `osdi-sosp-reviewer-risk.yaml`
* `evaluation-obligations.yaml`

No target document edits are allowed in this stage.

## Outputs

* `claim-evidence-grounding.yaml` — complete claim→evidence map with reviewer risk assessment
* `venue-norm-ledger.yaml` — extracted OSDI/SOSP acceptance criteria
* `exemplar-paper-analysis.yaml` — corpus analysis of top-tier papers
* `osdi-sosp-reviewer-risk.yaml` — per-claim reviewer risk assessment
* `evaluation-obligations.yaml` — mandatory evaluation obligations per weak claim

## Required Procedure

### Step 1: Extract OSDI/SOSP Review Criteria

Read the current OSDI and SOSP call-for-papers and author instructions. Extract the explicit acceptance criteria, including:

* novelty
* significance
* interest to the systems community
* clarity
* relevance
* correctness
* problem importance
* compelling solution
* demonstrated practicality and benefit
* appropriate conclusions
* clear contributions
* advances beyond previous work
* accessibility to the broader systems community
* whether the paper must stand alone without supplementary material
* any track-specific criteria, such as operational systems, deployed systems, measurement papers, or experience papers

Write these criteria into `venue-norm-ledger.yaml`.

### Step 2: Build an Exemplar Corpus

Identify a small but high-quality corpus of OSDI/SOSP papers that are closest to the target paper. The corpus must include:

* 3–5 recent OSDI/SOSP papers in the same topic area.
* 2–3 canonical OSDI/SOSP papers that shaped the relevant research style.
* 1–2 dangerous adjacent baselines that a reviewer may use to reject or weaken the paper.

For each paper, record:

* venue and year
* research object
* problem setting
* core root cause
* central insight
* system mechanism
* implementation scale
* evaluation contract
* strongest baselines
* primary claims
* claim wording style
* limitations
* how the paper positions itself against prior work

Write this into `exemplar-paper-analysis.yaml`.

### Step 3: Infer Venue-Level Argument Patterns

From the exemplar corpus, extract reusable top-tier systems-paper patterns:

* How do accepted papers motivate the problem?
* Where do they place the root cause?
* How do they turn the root cause into a technical insight?
* How much implementation detail is needed before the design becomes credible?
* What kinds of baselines are treated as dangerous?
* What evaluation dimensions are considered mandatory?
* How do they avoid overclaiming?
* How do they state limitations without weakening the contribution?
* What claims are acceptable in the introduction, design, implementation, and evaluation sections?
* What claims require experiments, formal arguments, artifact evidence, or production evidence?

Do not summarize papers as a literature survey. Extract review-relevant norms.

### Step 4: Map Target Claims to OSDI/SOSP Evaluation Contracts

For every claim in `paper-state.yaml`, classify:

* claim type:

  * motivation claim
  * root-cause claim
  * novelty claim
  * design claim
  * mechanism claim
  * security claim
  * performance claim
  * compatibility claim
  * scalability claim
  * usability/deployability claim
  * comparison claim
  * limitation claim
* required evidence type:

  * direct experiment
  * ablation
  * benchmark comparison
  * formal invariant/proof
  * code/artifact evidence
  * deployment/experience evidence
  * related-work comparison
  * threat model argument
  * workload analysis
  * failure-case analysis
* current evidence in the paper
* evidence strength
* missing evidence
* whether the evidence would satisfy an OSDI/SOSP reviewer

### Step 5: Perform Reviewer-Style Risk Assessment

For each major claim and each major section, assess the following reviewer risks:

* **Problem Risk**: Is the problem important enough for OSDI/SOSP?
* **Novelty Risk**: Would reviewers say the idea is incremental over prior systems?
* **Insight Risk**: Is the insight non-obvious, or is it merely an implementation choice?
* **Design Risk**: Are mechanisms specified clearly enough to be evaluated?
* **Correctness Risk**: Are invariants, assumptions, and failure cases explicit?
* **Evaluation Risk**: Do experiments actually test the claims made in the paper?
* **Baseline Risk**: Are the strongest competing systems missing or under-discussed?
* **Scope Risk**: Does the paper overgeneralize beyond tested settings?
* **Writing Risk**: Does the argument chain progress linearly from problem to root cause to insight to design to evidence?
* **Community-Interest Risk**: Would a substantial fraction of OSDI/SOSP attendees care?

Each risk must be rated:

* fatal
* high
* medium
* low

For every fatal or high risk, provide:

* the exact paper claim or section that triggers the risk
* the reviewer objection likely to be written
* the missing evidence or missing argument
* the closest OSDI/SOSP exemplar pattern that the paper fails to match
* the minimum repair required in later stages

Write this into `osdi-sosp-reviewer-risk.yaml`.

### Step 6: Identify Overclaims and Underclaims

For every claim, determine whether it is:

* properly supported
* overclaimed
* underclaimed
* misplaced
* too vague
* too implementation-specific
* too broad for the evaluation
* too weak to communicate the contribution

Overclaiming must be judged against both the paper's own evidence and the exemplar-paper norms.

For each overclaim, record:

* current wording
* evidence-supported wording
* required additional evidence if the stronger wording is retained
* likely reviewer criticism

For each underclaim, record:

* missed contribution
* evidence that could support a stronger claim
* where the stronger claim should appear

### Step 7: Generate Evaluation Obligations

For every weak, unsupported, or reviewer-risky claim, generate an evaluation obligation:

* obligation ID
* linked claim ID
* claim type
* required experiment or argument
* required baseline
* required workload
* required metric
* expected reviewer question
* whether the obligation is mandatory for OSDI/SOSP submission
* whether the paper can instead weaken or delete the claim

Write this into `evaluation-obligations.yaml`.

### Step 8: Write Claim-Evidence Grounding

Produce `claim-evidence-grounding.yaml` with the complete claim map.

The output must include:

```yaml
schema_version: "2.0.0"
round_id: string

venue_criteria:
  target_venues:
    - OSDI
    - SOSP
  criteria_summary:
    novelty: string
    significance: string
    interest: string
    clarity: string
    relevance: string
    correctness: string
    practicality: string
    contribution_vs_prior_work: string

exemplar_corpus:
  - source_id: string
    venue: string
    year: integer
    title: string
    relevance_to_target: high | medium | low
    extracted_pattern:
      problem_framing: string
      root_cause: string
      insight: string
      design_structure: string
      evaluation_contract: string
      baseline_strategy: string
      claim_style: string

claim_evidence_map:
  - claim_id: string
    location: string
    claim_text: string
    claim_type: string
    role_in_paper:
      core_contribution: boolean
      section_role: motivation | background | design | implementation | evaluation | related_work | conclusion
    required_evidence:
      evidence_type: string
      rationale: string
    current_evidence:
      type: direct_measurement | formal_proof | cited_prior_work | ablation | artifact | logical_argument | none
      location: string | null
      description: string
      source_refs: [string]
    evidence_strength: strong | moderate | weak | none
    osdi_sosp_sufficiency:
      sufficient_for_submission: boolean
      explanation: string
    overclaim_assessment:
      status: supported | overclaimed | underclaimed | vague | misplaced
      explanation: string
      evidence_supported_wording: string
    reviewer_risk:
      level: fatal | high | medium | low
      likely_reviewer_objection: string
      repair_required: string
    evaluation_obligation:
      needed: boolean
      obligation_id: string | null
      description: string | null
      mandatory_for_top_tier_submission: boolean

summary:
  total_claims: integer
  core_claims: integer
  strong_evidence: integer
  moderate_evidence: integer
  weak_evidence: integer
  no_evidence: integer
  overclaimed: integer
  fatal_risks: integer
  high_risks: integer
  mandatory_evaluation_obligations: integer

critical_gaps:
  - claim_id: string
    reason: string
    minimum_repair: string
```

## Quality Gates

* Every claim from `paper-state.yaml` must appear in `claim_evidence_map`.
* Every core claim must have an explicit OSDI/SOSP sufficiency judgment.
* Every fatal or high risk must include a likely reviewer objection.
* Every claim marked strong must identify direct evidence that tests the claim.
* Logical argument alone is not sufficient for performance, scalability, security, or compatibility claims.
* Every novelty claim must be checked against dangerous prior work.
* Every evaluation claim must identify the baseline, workload, metric, and tested condition.
* Every major contribution must be compared against at least one OSDI/SOSP exemplar or canonical related system.
* The analysis must distinguish between missing evidence, weak writing, weak novelty, weak evaluation, and weak problem significance.
* The paper must be judged as a self-contained submission; supplementary material cannot be required for understanding the core contribution.

## Failure Conditions

Stop and report a blocker if:

* The paper-state claim inventory is incomplete.
* The stage cannot identify any relevant OSDI/SOSP exemplar papers.
* A core claim has no evidence and no possible evaluation obligation.
* A novelty claim cannot be assessed because related work is missing.
* A performance or scalability claim lacks baseline, workload, or metric.
* A security claim lacks attacker model, trust boundary, or failure condition.
* The paper depends on supplementary material for a core contribution.

## Forbidden Behavior

* Do not defend the paper by default.
* Do not polish unsupported claims.
* Do not treat a weak but plausible idea as top-tier ready.
* Do not fabricate exemplar-paper patterns.
* Do not cite a paper as an exemplar without extracting its actual argument pattern.
* Do not call evidence strong unless it directly supports the exact claim wording.
* Do not ignore dangerous related work because it weakens the paper.
* Do not collapse all weaknesses into “needs more evaluation”; distinguish motivation, novelty, design, correctness, baseline, and writing failures.
* Do not modify the paper in this stage.

## Advance Rule

After all required YAML files are produced and all quality gates pass, run `cr stage advance`.
