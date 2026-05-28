# Stage 4: Reviewer Critique

## Purpose

Simulate a top-venue reviewer reading the paper for the first time. The reviewer is adversarial, evidence-demanding, and precise — they are trying to find reasons to reject, not reasons to accept. This stage produces a structured critique that drives the entire revision pipeline: strategy (stage 5), revision plan (stage 6), and patches (stage 7).

This stage must NOT:
- Propose specific text changes (that's stage 6)
- Weaken claims to avoid critique (that's stage 5)
- Be gentle — the point is to find every vulnerability before a real reviewer does

## Stage Type

analysis-only

## Required Inputs

- `paper-state.yaml` — claim inventory, argument flow, writing quality, positioning
- `claim-evidence-grounding.yaml` — evidence map, overclaim assessments, risk levels
- `contract.yaml` — round scope, target units, review rubric context
- `workflows/paper/profile.md` — paper workflow research semantics, reviewer risk categories
- `workflows/paper/workflow.yaml` — review rubric questions
- `workflows/_shared/stage-protocol.md` — stage execution discipline
- `workflows/_shared/evidence-discipline.md` — evidence standards for critique grounding
- The target paper document — read sections relevant to each critique dimension

## Allowed Writes

- `critical-review.yaml` — and ONLY critical-review.yaml

## Required Procedure

### Step 1: Prepare Reviewer Posture
Load the paper workflow's `review_rubric` from `workflow.yaml`. Load the reviewer risk categories from `workflows/paper/profile.md`. Internalize the posture: you are a senior PC member at SOSP/OSDI/NSDI reading a submission you've never seen before. You have 45 minutes to form an opinion. You are looking for reasons to reject.

### Step 2: Motivation Critique
Assess whether the paper establishes a compelling problem:
- Is the problem real and significant? Or is it contrived?
- Does the paper make the reader care within the first page?
- Is the problem scoped — or is it "everything is slow/expensive/insecure"?
- Does the paper cite real-world evidence of the problem (measurements, failures, user complaints)?
- Would a reader from a slightly different sub-area understand why this matters?

### Step 3: Root Cause Critique
Assess whether the paper identifies why prior approaches fail:
- Does the paper explain the root cause, or only describe symptoms?
- Is the root cause analysis novel, or is it restating well-known limitations?
- Does the paper provide evidence for its root cause claim? (measurement, trace, logical decomposition)
- Would a competent researcher arrive at the same root cause without reading this paper?

### Step 4: Insight Critique
Apply the "So what?" test:
- What is the non-obvious observation that enables the solution?
- Is the insight distinguishable from "we tried something and it worked"?
- Would a reader finish the paper and tell a colleague "I didn't know that" — or "I could have guessed that"?
- Is the insight generalizable, or is it a one-off trick?

### Step 5: Claim Critique
For every claim identified in stage 2, especially core and high-risk claims:
- Is the claim defensible given the evidence assessed in stage 3?
- Which claims are overclaimed and need weakening?
- Which claims need strengthening (more evidence, better wording)?
- Which claims should be dropped entirely?
- Are baselines dangerous enough — would they beat the proposed approach if properly tuned?

### Step 6: Design Critique
If the paper presents a system, method, or algorithm:
- Is the design clearly described? Can a reader reproduce it?
- Are invariants, assumptions, and tradeoffs explicitly stated?
- What are the limitations? Are they honestly discussed or buried?
- Is the design a straightforward combination of known techniques?

### Step 7: Evaluation Critique
For every empirical claim:
- Does the evaluation directly test the claim?
- Are baselines fair, properly tuned, and representative of the state of the art?
- Are measurements reproducible? (hardware, software versions, configurations stated?)
- Is there sensitivity analysis? (varying workload parameters, configuration knobs, environment)
- What is missing? (scale, real-world workload, failure modes, corner cases)

### Step 8: Writing Critique
Assess whether the writing meets top-venue standards:
- Is the argument chain linear — does each section advance the story?
- Are there redundant passages — the same point made in introduction, design, and evaluation?
- Is the contribution crystal clear by the end of page 1?
- Are claims buried in dense prose where a skimming reviewer would miss them?
- Does the writing match the venue's style conventions?

### Step 9: Synthesize and Prioritize
Rank all critiques by severity:
- **Fatal**: if true, the paper should be rejected regardless of other merits
- **Major**: weakens the paper significantly; must be addressed
- **Minor**: would improve the paper but does not threaten acceptance
- **Nit**: stylistic only; discretionary

### Step 10: Write Critical Review
Produce `critical-review.yaml` with all critiques, grounded in specific evidence from the paper and the outputs of stages 2-3.

## Output Contract

```yaml
critical-review.yaml:
  schema_version: "1.0.0"
  round_id: integer
  overall_assessment:
    acceptability: strong_accept | weak_accept | borderline | weak_reject | strong_reject
    summary: string                 # one paragraph: the reviewer's overall take
    fatal_flaws: [string]           # critique IDs that are fatal
  critiques:
    - critique_id: string           # CR-001, CR-002, ...
      category: motivation | root_cause | insight | claim | design | evaluation | writing
      severity: fatal | major | minor | nit
      claim_ids: [string]           # which claim(s) this critique targets (from paper-state)
      text: string                  # the critique, as a reviewer would write it
      grounding: string             # specific paper passage, evidence gap, or standard violated
      expected_response: string     # what would satisfy this critique
  motivation:
    problem_is_real: strong | adequate | weak
    reader_cares: strong | adequate | weak
    scoped_appropriately: strong | adequate | weak
    issues: [string]                # critique IDs
  root_cause:
    root_cause_identified: strong | adequate | weak | none
    root_cause_novel: strong | adequate | weak
    root_cause_evidenced: strong | adequate | weak
    issues: [string]
  insight:
    non_obvious: strong | adequate | weak
    generalizable: strong | adequate | weak
    issues: [string]
  claims:
    defensible_count: integer
    overclaimed_count: integer
    unsupported_count: integer
    issues: [string]
  design:
    clarity: strong | adequate | weak | n/a
    tradeoffs_explicit: strong | adequate | weak | n/a
    issues: [string]
  evaluation:
    matches_claims: strong | adequate | weak
    baselines_fair: strong | adequate | weak
    reproducible: strong | adequate | weak
    sensitivity_analysis: strong | adequate | weak
    issues: [string]
  writing:
    argument_linear: strong | adequate | weak
    contribution_clear: strong | adequate | weak
    venue_style_match: strong | adequate | weak
    issues: [string]
  severity_summary:
    fatal: integer
    major: integer
    minor: integer
    nit: integer
```

## Quality Gates

- [ ] Every critique is grounded — `grounding` cites a specific paper passage, evidence gap, or standard
- [ ] Critique IDs are assigned sequentially (CR-001, CR-002, ...)
- [ ] Every claim from `paper-state.yaml` with `risk_level: high` has at least one corresponding critique
- [ ] Severity is consistent — a fatal critique means `overall_assessment.acceptability` is `weak_reject` or `strong_reject`
- [ ] Evaluation critique covers at minimum: claim match, baseline fairness, reproducibility, and sensitivity
- [ ] `severity_summary` counts match the actual critique entries
- [ ] No critique is sourceless — every `grounding` is specific, not "generally weak"

## Failure Conditions

- No fatal or major critiques found — STOP; either the paper is perfect (unlikely) or the critique was insufficiently adversarial
- A critique's `grounding` is vague ("the paper is unclear") — STOP; rewrite with a specific passage
- A core claim with `evidence_strength: none` has no corresponding critique — STOP; this is a critical gap

## Forbidden Behavior

- Do not be gentle — the goal is to find every vulnerability, not to reassure the author
- Do not propose fixes in the critique — "this claim should be weakened" belongs in stage 5
- Do not critique things the paper does not claim — critique what IS claimed, not what you wish was claimed
- Do not fabricate evidence to support or attack a claim
- Do not modify the paper document — analysis-only stage
- Do not skip review rubric dimensions — every question in `review_rubric` must be addressed

## Advance Rule

After all quality gates pass and `critical-review.yaml` is written, run `cr stage advance`.
