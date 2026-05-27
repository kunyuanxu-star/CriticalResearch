# Stage 8: Validation Obligations

## Mission
Elaborate every validation obligation into a concrete validation protocol. For each methodology or measurement change, define how it will be validated: pilot study design, simulation protocol, calibration verification, or expert review. Validation obligations are the experiment's quality gate before execution.

## Inputs
- `round:validation-obligations.yaml` — validation specs from patch application
- `round:patch-trace.yaml` — traceability matrix
- `round:methodology-design.yaml` — complete methodology specification
- `documents/experiment-plan.md` — current experiment plan

## Outputs
- `validation-protocols.yaml` — concrete validation protocols per obligation
- `validation-trace.yaml` — mapping from obligations to protocols

## Allowed Actions
- Read validation obligations, patch trace, methodology design, and experiment plan.
- Design validation protocols for each obligation: type, procedure, acceptance criteria.
- Define pilot study, simulation, calibration, analytical, and expert review protocols.
- Write validation-protocols.yaml and validation-trace.yaml.

## Forbidden Actions
- Do not execute experiments.
- Do not modify experiment plan.
- Do not generate patches.
- Do not fabricate validation results.
- Do not skip any validation obligation.

## Procedure

### 1. Classify Validation Types
For each obligation, determine validation type: pilot (small-scale trial), simulation (computational validation), calibration (instrument accuracy verification), analytical (mathematical/logical proof), expert_review (structured domain review), literature_benchmark (comparison against published standards).

### 2. Design Validation Protocols
For each obligation, produce validation_id, protocol_type, step-by-step procedure, required_resources (equipment, participants, data, experts), acceptance_criteria (quantitative or qualitative pass/fail), and failure_remediation (what to do on failure).

### 3. Type-Specific Design
For pilot: sample size, recruitment, procedure mirroring main experiment, pilot-specific measures, promotion criteria.
For simulation: model and parameters, data generation process, analysis pipeline, adequacy criteria.
For calibration: reference standard, measurement procedure, tolerance, recalibration procedure.
For expert_review: expert qualifications, review materials, evaluation rubric, consensus procedure.
For analytical: proof approach, assumptions, verification criteria.
For literature_benchmark: reference sources, comparison dimensions, equivalence criteria.

### 4. Write Validation Trace
Map each validation protocol back to its obligation, patch, critique, and affected component.

## Output Contract

```yaml
validation-protocols.yaml:
  schema_version: "1.0.0"
  round_id: integer
  protocols:
    - validation_id: VAL-###
      protocol_type: pilot | simulation | calibration | analytical | expert_review | literature_benchmark
      target_component: string
      procedure: [string]
      required_resources: { equipment: [string], participants: string, data: [string], experts: [string] }
      acceptance_criteria: string (>= 10 chars)
      failure_remediation: string (>= 10 chars)
      pilot_design: { sample_size: integer, recruitment: string, procedure_summary: string, pilot_measures: [string], promotion_criteria: string }
      simulation_design: { model: string, parameters: string, data_generation: string, analysis_pipeline: string, adequacy_criteria: string }
      calibration_design: { reference_standard: string, measurement_procedure: string, tolerance: string, recalibration_procedure: string }
      expert_review_design: { qualifications: string, review_materials: [string], evaluation_rubric: string, consensus_procedure: string }

validation-trace.yaml:
  schema_version: "1.0.0"
  round_id: integer
  traces:
    - validation_id: VAL-###
      obligation_id: string
      patch_id: PP-###
      critique_id: CRT-###
      affected_component: string
      status: planned | executed | passed | failed | remediated
```

## Failure Conditions
- Any validation obligation has no corresponding protocol.
- Any protocol missing acceptance_criteria < 10 chars or failure_remediation < 10 chars.
- Any protocol type-specific section missing (e.g., pilot_design missing for pilot type).
- validation-trace.yaml missing entries for any protocol.

## Completion Checklist
- [ ] Every validation obligation has a concrete protocol.
- [ ] Protocols classified by type with type-specific sections completed.
- [ ] Acceptance criteria and failure remediation defined for every protocol.
- [ ] Required resources enumerated.
- [ ] Validation trace links protocols to obligations, patches, and critiques.
- [ ] All artifacts are valid YAML.

## Full-Experiment Coverage Requirement
Validation protocols must cover all methodology and measurement-level changes across the experiment, not just the primary target.

## Handoff
The next stage (`knowledge_delta`) distills experiment-round learning into the global knowledge base.
