# Stage 2: Experiment State

## Mission
Load the full experiment context: all hypotheses, variables, controls, measures, baselines, and validation criteria. Assemble the Experiment State snapshot that every subsequent stage builds upon. This stage establishes the ground truth for all experiment design and critique work.

## Inputs
- `round:round-contract.yaml` — experiment contract with target and scope
- `documents/experiment-plan.md` — current experiment plan
- `state/claim-ledger.yaml` — existing hypothesis definitions
- `workspace:_cr/knowledge/` — global knowledge cards

## Outputs
- `experiment-state.yaml` — frozen snapshot of hypotheses, variables, controls, measures, baselines, validation criteria, and risks
- `state/knowledge-load-log.yaml` — record of knowledge cards loaded and their relevance

## Allowed Actions
- Read experiment plan, contract, claim ledger, and knowledge cards.
- Load relevant domain knowledge (methods, controls, measurement standards).
- Normalize all hypotheses with scope, assumptions, variables, measurement plan.
- Document all independent variables, dependent variables, controlled variables.
- Document all measurement instruments and their properties.
- Document all control conditions and comparison baselines.
- Identify fragile components with explicit fragility_reason.

## Forbidden Actions
- Do not design new methodology.
- Do not generate critique.
- Do not modify experiment plan.
- Do not search for external sources beyond loaded knowledge cards.
- Do not generate patches.

## Procedure

### 1. Hypothesis Normalization
For every hypothesis, produce a normalized entry:
- hypothesis_id, text, type (primary | secondary | exploratory).
- scope with boundaries, independent variables, dependent variables.
- assumptions (>= 1 per hypothesis).
- predicted effect direction and magnitude.
- evidence_status: untested | partially_supported | supported | contradicted.

### 2. Variable Inventory
Catalog all variables:
- Independent variables: name, type (categorical | continuous | treatment), levels/range, manipulation method.
- Dependent variables: name, type, measurement instrument, expected distribution.
- Controlled variables: name, target value/range, control method, tolerance.
- Confounding variables: name, expected effect, mitigation strategy.

### 3. Measurement Instrumentation
For every dependent variable and construct:
- Instrument name and type.
- Validity evidence (face, content, construct, criterion).
- Reliability evidence (test-retest, internal consistency, inter-rater).
- Measurement resolution and range.
- Known biases or limitations.

### 4. Baselines and Controls
Document:
- Control conditions with rationale.
- Comparison baselines (external benchmarks, prior results, null models).
- Randomization strategy if applicable.
- Blinding strategy if applicable.
- Sample size and power analysis status.

### 5. Fragility Assessment
Mark at least one fragile component:
- Component identity, fragility_reason >= 10 chars.
- What evidence would break it.
- Risk level: low | medium | high | critical.

## Output Contract

```yaml
experiment-state.yaml:
  schema_version: "1.0.0"
  round_id: integer
  primary_hypothesis: string
  hypotheses:
    - hypothesis_id: HYP-###
      text: string (>= 10 chars)
      type: primary | secondary | exploratory
      scope:
        boundaries: string
        independent_variables: [string]
        dependent_variables: [string]
      assumptions: [string] (>= 1)
      predicted_effect: string
      evidence_status: untested | partially_supported | supported | contradicted
  variables:
    independent:
      - name: string
        type: categorical | continuous | treatment
        levels_or_range: string
        manipulation_method: string
    dependent:
      - name: string
        type: string
        measurement_instrument: string
        expected_distribution: string
    controlled:
      - name: string
        target_value: string
        control_method: string
        tolerance: string
    confounding:
      - name: string
        expected_effect: string
        mitigation: string
  measures:
    - instrument_name: string
      type: string
      validity_evidence: string
      reliability_evidence: string
      resolution: string
      limitations: string
  baselines:
    control_conditions: [string]
    comparison_baselines: [string]
    randomization: string
    blinding: string
  fragility:
    - component: string
      fragility_reason: string (>= 10 chars)
      breaking_evidence: string
      risk_level: low | medium | high | critical
```

## Failure Conditions
- No hypotheses normalized.
- Any hypothesis missing assumptions.
- Variable inventory incomplete (any category empty).
- No measurement instruments documented.
- No fragility assessment or fragility_reason < 10 chars.
- experiment-state.yaml missing any top-level section.

## Completion Checklist
- [ ] All hypotheses normalized with scope, assumptions, evidence_status.
- [ ] Independent, dependent, controlled, and confounding variables catalogued.
- [ ] Measurement instruments documented with validity and reliability.
- [ ] Baselines, controls, randomization, and blinding documented.
- [ ] At least one fragile component identified.
- [ ] Knowledge cards loaded and logged.
- [ ] experiment-state.yaml is valid YAML.

## Full-Experiment Coverage Requirement
State reconstruction must cover all hypotheses, variables, measures, and controls in the experiment plan, not just the contract target.

## Handoff
The next stage (`methodology_design`) uses the experiment state to design or refine the experimental methodology.
