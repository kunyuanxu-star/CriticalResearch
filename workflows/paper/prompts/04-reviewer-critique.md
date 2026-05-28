# Stage 4: Reviewer Critique

## Critical Thinking Protocol

This stage must apply structured critical thinking, not checklist-style validation. The reviewer must actively search for reasons why the paper's argument may be false, incomplete, overstated, or insufficient for OSDI/SOSP acceptance.

For every major claim, contribution, design decision, and evaluation result, apply the following protocol.

### 1. Decompose the Claim

Break each claim into its hidden components:

* What is the explicit claim?
* What assumptions must be true for the claim to hold?
* What property is being claimed: performance, security, correctness, compatibility, generality, simplicity, deployability, or novelty?
* What scope is implied but not stated?
* What comparison baseline is assumed?
* What evidence would actually falsify the claim?

A claim is not valid merely because it sounds plausible. It is valid only if its assumptions, scope, baseline, and required evidence are explicit.

### 2. Search for Alternative Explanations

For each claimed improvement or observation, ask:

* Could the result be explained by implementation effort rather than a new idea?
* Could the improvement come from a weaker baseline?
* Could the result be caused by workload choice, hardware choice, parameter tuning, caching effects, benchmark artifacts, or omitted overhead?
* Could the paper be solving a narrower problem than it claims?
* Could prior systems already achieve the same effect under a different name or abstraction?

If a plausible alternative explanation exists, record it as a reviewer risk. The paper must either rule it out or weaken the claim.

### 3. Attack the Root Cause

For every root-cause claim, ask:

* Is this really the root cause, or only a symptom?
* Does the paper show that existing approaches fail for this reason?
* Could a simpler modification to prior systems address the same problem?
* Is the root cause specific enough to justify the proposed design?
* Would an expert reviewer consider this root cause already known?

A weak root-cause claim is a high-risk issue because it undermines the necessity of the whole paper.

### 4. Attack the Insight

For every claimed insight, ask:

* Is the insight non-obvious?
* Is it more than an engineering choice?
* Does it explain why the design works?
* Does it distinguish the paper from prior work?
* Could a reviewer summarize the insight in one sentence?
* Would the paper still make sense if the insight were removed?

If the insight is merely “we use X to improve Y,” classify it as weak. A top-tier systems paper usually needs a deeper observation about why previous abstractions, boundaries, policies, or mechanisms are misplaced.

### 5. Attack the Baselines

For every evaluation or comparison claim, ask:

* Is the strongest competing system included?
* Is the baseline configured fairly?
* Would a tuned baseline close the gap?
* Is the baseline missing a known optimization?
* Is the paper comparing against an outdated or artificially weak system?
* Is there a dangerous adjacent baseline that the authors did not discuss?

If a stronger baseline could invalidate the contribution, mark the claim as high or fatal risk.

### 6. Attack the Evaluation Contract

For every empirical claim, ask:

* Does the experiment test the exact claim?
* Are the metrics sufficient?
* Are the workloads representative?
* Are variance, failure cases, and tail behavior reported?
* Are ablations sufficient to isolate the paper's mechanism?
* Are negative results or limitations hidden?
* Does the evaluation distinguish mechanism benefit from implementation artifact?

Evidence is insufficient if it supports only a weaker or different claim.

### 7. Attack the Generalization

For every broad claim, ask:

* Does the evidence support this generality?
* Does the claim hold only for one workload, platform, implementation, or threat model?
* Are there obvious cases where the design would fail?
* Does the paper state the boundary of applicability?
* Would a reviewer accuse the paper of overgeneralizing?

If the claim generalizes beyond the tested setting, require either stronger evidence or narrower wording.

### 8. Apply the Rejection Test

For each major section and core claim, write the strongest possible rejection argument:

* What would Reviewer A say if they are skeptical of novelty?
* What would Reviewer B say if they care about systems practicality?
* What would Reviewer C say if they care about evaluation rigor?
* What would Reviewer D say if they know the closest related work very well?

The critique must not stop at identifying weaknesses. It must explain how those weaknesses would appear in an actual OSDI/SOSP review.

### 9. Apply the Minimum Acceptance Bar

For every core contribution, determine the minimum bar for acceptance:

* What must be true for this contribution to be publishable at OSDI/SOSP?
* What evidence is mandatory rather than optional?
* What baseline must be beaten or explained?
* What limitation must be acknowledged?
* What claim must be weakened if evidence cannot be added?
* What would make the paper clearly rejectable?

A paper is not top-tier-ready because it has a coherent story. It is top-tier-ready only if the strongest foreseeable objections are either answered, neutralized, or explicitly scoped out.

### 10. Record Counterevidence and Unresolved Doubt

The output must include not only supporting evidence but also:

* counterevidence
* missing evidence
* dangerous prior work
* alternative explanations
* unresolved assumptions
* reviewer objections
* falsification tests
* minimum repair actions

If the paper survives only because the analysis is charitable, the stage has failed.

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
