# Stage 3: Methodology Design

## Mission
Design or refine the experimental methodology: experimental design type, variable manipulation protocol, measurement protocol, control protocol, sampling plan, analysis plan, and validity threat assessment. Every methodological choice must be justified against alternatives and grounded in the experiment state.

## Inputs
- `round:experiment-state.yaml` — frozen experiment snapshot
- `round:contract.yaml` — experiment contract
- `workspace:_cr/knowledge/` — global knowledge cards, method cards

## Outputs
- `methodology-design.yaml` — complete methodology specification
- `methodology-justification.yaml` — per-choice justification against alternatives

## Allowed Actions
- Read experiment state, contract, and method knowledge cards.
- Select experimental design type with justification.
- Define variable manipulation, measurement, and control protocols.
- Design sampling plan and power analysis.
- Specify analysis plan: statistical tests, effect sizes, multiple comparison correction.
- Assess internal, external, construct, and statistical conclusion validity threats.
- Justify each methodological choice against at least one alternative.

## Forbidden Actions
- Do not execute experiments.
- Do not modify experiment plan.
- Do not generate critique of hypotheses.
- Do not generate patches.
- Do not fabricate results or pilot data.

## Procedure

### 1. Experimental Design Selection
Select and justify the experimental design type (between-subjects | within-subjects | mixed | quasi-experimental | observational) with justification >= 20 chars, at least one alternative considered and rejected with reason >= 10 chars, and unit of analysis defined.

### 2. Variable Manipulation Protocol
For each independent variable: step-by-step manipulation procedure, manipulation check method, fidelity criteria for successful manipulation.

### 3. Measurement Protocol
For each dependent variable: instrument administration procedure, calibration procedure if applicable, measurement schedule (timing, frequency, order), counterbalancing or randomization, quality checks during measurement.

### 4. Control Protocol
Define control condition setup, confound mitigation per identified confounding variable, environmental controls (physical, temporal, procedural), experimenter blinding, and demand characteristic mitigation.

### 5. Sampling Plan
Define population, sampling frame, sampling method, inclusion/exclusion criteria, target sample size with power analysis (effect size, alpha, power, test type), recruitment procedure, and attrition mitigation.

### 6. Analysis Plan
Specify primary analysis (statistical test, model, assumptions), secondary analyses (mediation, moderation, subgroup), effect size measure(s), multiple comparison correction, missing data handling, and outlier handling.

### 7. Validity Threat Assessment
For each validity type (internal, external, construct, statistical conclusion), document >= 1 threat and its mitigation.

## Output Contract

```yaml
methodology-design.yaml:
  schema_version: "1.0.0"
  round_id: integer
  design:
    type: between-subjects | within-subjects | mixed | quasi-experimental | observational
    justification: string (>= 20 chars)
    alternatives_considered: [{ design: string, rejection_reason: string }]
    unit_of_analysis: string
  manipulation_protocols:
    - variable: string
      procedure: [string]
      manipulation_check: string
      fidelity_criteria: string
  measurement_protocols:
    - variable: string
      instrument: string
      administration: string
      schedule: string
      counterbalancing: string
      quality_checks: string
  control_protocol:
    control_condition: string
    confound_mitigations: [{ confound: string, mitigation: string }]
    environmental_controls: [string]
    experimenter_blinding: string
  sampling_plan:
    population: string
    sampling_method: string
    inclusion_criteria: [string]
    exclusion_criteria: [string]
    target_sample_size: integer
    power_analysis: { effect_size: string, alpha: number, power: number, test_type: string }
    attrition_handling: string
  analysis_plan:
    primary_test: string
    model_specification: string
    assumptions: [string]
    secondary_analyses: [string]
    effect_size_measure: string
    multiple_comparison_correction: string
    missing_data_handling: string
    outlier_handling: string
  validity_threats:
    internal: [{ threat: string, mitigation: string }]
    external: [{ threat: string, mitigation: string }]
    construct: [{ threat: string, mitigation: string }]
    statistical_conclusion: [{ threat: string, mitigation: string }]

methodology-justification.yaml:
  schema_version: "1.0.0"
  round_id: integer
  justifications:
    - choice_id: string
      choice: string
      justification: string (>= 20 chars)
      alternatives_considered:
        - alternative: string
          reason_rejected: string (>= 10 chars)
```

## Failure Conditions
- No experimental design type selected.
- No alternative designs considered.
- Any variable missing manipulation or measurement protocol.
- Sampling plan missing power analysis parameters.
- Analysis plan missing primary test specification.
- Any validity type has zero threats documented.

## Completion Checklist
- [ ] Experimental design selected with justification and alternatives.
- [ ] Manipulation protocols defined for all independent variables.
- [ ] Measurement protocols defined for all dependent variables.
- [ ] Control protocol covers confounds, environment, blinding.
- [ ] Sampling plan includes power analysis.
- [ ] Analysis plan specifies primary test, effect size, corrections.
- [ ] Validity threats assessed for all four types.
- [ ] methodology-design.yaml and methodology-justification.yaml are valid YAML.

## Full-Experiment Coverage Requirement
Methodology design must cover all variables and hypotheses in the experiment state, not just the contract target.

## Handoff
The next stage (`experiment_critical_review`) critiques the methodology design for flaws, gaps, and validity threats.
