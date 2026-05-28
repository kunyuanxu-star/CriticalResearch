# Stage 6: Results Analysis

## Mission
Analyze experiment results against hypotheses. Examine all outcomes — supported, refuted, ambiguous, and failed. Produce a structured results analysis that links every result to its originating hypothesis, critique, and methodology component. Document effect sizes, statistical outcomes, and interpretation under uncertainty. Identify gaps where results are inconclusive or where new experiments are needed.

This is a planning/analysis stage. You are not executing experiments; you are analyzing results that have been reported and deciding what they mean.

## Inputs
- `round:methodology-design.yaml` — complete methodology specification
- `round:experiment-execution-plan.yaml` — step-by-step execution plan
- `round:critique-ledger.yaml` — structured critique entries
- `round:review-disposition.yaml` — per-critique dispositions
- `round:experiment-state.yaml` — frozen experiment snapshot

## Outputs
- `results-analysis.yaml` — structured results analysis per hypothesis and measure
- `experiment-findings.yaml` — evidence-grade findings with confidence

## Allowed Actions
- Read methodology design, execution plan, critique ledger, dispositions, and experiment state.
- Analyze results per hypothesis.
- Compute or interpret effect sizes and confidence intervals.
- Judge whether hypotheses are supported, refuted, or ambiguous.
- Identify result gaps and propose follow-up experiments.
- Document evidence strength for every finding.

## Forbidden Actions
- Do not modify experiment plan.
- Do not generate patches to methodology.
- Do not fabricate results or data.
- Do not ignore null or negative results.
- Do not overstate weak or ambiguous findings.

## Procedure

### 1. Load Experiment Context
Read all inputs. Identify every hypothesis from methodology-design.yaml, every measure, every control, and every expected outcome from the execution plan.

### 2. Analyze Per Hypothesis
For each hypothesis:
- State the hypothesis as specified in the methodology.
- Summarize observed results.
- Compute or report effect size and confidence where available.
- Determine: supported | refuted | ambiguous | failed_to_execute.
- Document evidence strength: strong | moderate | weak | none.
- Note any confound or measurement issue that may affect interpretation.

### 3. Cross-Reference Critiques
For each critique in the critique ledger:
- Was the critique addressed by results?
- Did results validate or refute the concern?
- Does any result create new critique-worthy issues?

### 4. Identify Result Gaps
Document: hypotheses with missing or inconclusive results, measures that failed quality checks, analyses that could not be completed, confounds that could not be controlled, and follow-up experiments that are now required.

### 5. Produce Findings Summary
Rank findings by evidence strength and importance. Document what is known with confidence, what is suggested but uncertain, and what remains unknown.

## Output Contract

```yaml
results-analysis.yaml:
  schema_version: "1.0.0"
  round_id: integer
  hypothesis_results:
    - hypothesis_id: HYP-###
      hypothesis: string
      result_summary: string (>= 20 chars)
      outcome: supported | refuted | ambiguous | failed_to_execute
      effect_size: string | null
      confidence_interval: string | null
      evidence_strength: strong | moderate | weak | none
      confound_notes: string | null
      linked_critiques: [CRT-###]
      linked_measures: [string]
  critique_postmortem:
    - critique_id: CRT-###
      addressed: bool
      result_relevance: string
      new_concerns_raised: string | null
  result_gaps:
    - gap_id: GAP-###
      description: string (>= 20 chars)
      severity: fatal | high | medium | low
      affected_hypotheses: [HYP-###]
      required_follow_up: string

experiment-findings.yaml:
  schema_version: "1.0.0"
  round_id: integer
  findings:
    - finding_id: FND-###
      statement: string (>= 20 chars)
      evidence_strength: strong | moderate | weak
      supporting_hypotheses: [HYP-###]
      caveats: string
      confidence: high | medium | low
```

## Failure Conditions
- Any hypothesis has null outcome.
- Any finding with evidence_strength strong has no supporting_hypotheses.
- Result gaps exist but none are documented.
- Evidence strength overstates weak or absent results.

## Completion Checklist
- [ ] Every hypothesis has outcome and evidence strength.
- [ ] Critique postmortem covers all critiques.
- [ ] Result gaps are documented with severity.
- [ ] Findings summary produced with evidence grades.
- [ ] No fabricated or overclaimed results.

## Full-Experiment Coverage Requirement
Results analysis must cover every hypothesis, variable, measure, and control from the methodology design, not just the primary target.

## Handoff
The next stage (`revision_plan`) converts results analysis and critique findings into a concrete revision plan for the experiment design.
