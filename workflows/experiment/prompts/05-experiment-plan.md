# Stage 5: Experiment Plan

## Mission
Produce a concrete, step-by-step experiment execution plan. This stage transforms the methodology design and critique findings into an actionable plan: participant flow, materials preparation, procedure timeline, data collection protocol, analysis execution order, and quality assurance checkpoints.

## Inputs
- `round:methodology-design.yaml` — complete methodology specification
- `round:critique-ledger.yaml` — structured critique entries
- `round:review-disposition.yaml` — per-critique dispositions
- `round:experiment-state.yaml` — frozen experiment snapshot

## Outputs
- `experiment-execution-plan.yaml` — step-by-step execution plan
- `experiment-materials-checklist.yaml` — materials, instruments, software, environment

## Allowed Actions
- Read methodology design, critique ledger, dispositions, and experiment state.
- Design participant flow from recruitment through debriefing.
- Prepare materials, instruments, software, and environment specifications.
- Define procedure timeline with estimated durations.
- Specify data collection protocol with integrity checks and analysis execution order.
- Define quality assurance checkpoints.

## Forbidden Actions
- Do not execute experiments.
- Do not modify experiment plan document.
- Do not generate patches to methodology.
- Do not fabricate results or pilot data.
- Do not change methodology without tracing to a critique disposition.

## Procedure

### 1. Participant Flow
Design the complete participant journey: recruitment method and timeline, screening procedure, informed consent, randomization/assignment, experimental session structure, debriefing, compensation, and withdrawal handling.

### 2. Materials and Environment
Prepare specifications for hardware (specs, calibration), software (version, configuration), instruments (make, model, calibration schedule), physical environment (lighting, noise, temperature, seating), stimuli (creation, validation, counterbalancing), and questionnaires (item sources, scoring).

### 3. Procedure Timeline
Define session phases with estimated durations, within-session event sequence, between-session intervals, total time per participant, and rest breaks with fatigue mitigation.

### 4. Data Collection Protocol
Specify data capture method (manual, automated, hybrid), data fields and formats, integrity checks during collection, real-time quality monitoring, storage and backup, and unique participant identification scheme.

### 5. Analysis Execution Order
Define the full analysis pipeline: data cleaning and preparation, missing data pattern analysis, assumption checking sequence, primary analysis execution, secondary and exploratory analyses, sensitivity analyses, and result reporting format.

### 6. Quality Assurance
Define checkpoints for pre-experiment (materials validation, pilot run, protocol dry-run), during experiment (fidelity checks, manipulation checks, dropout monitoring), and post-experiment (data integrity, analysis reproduction, result verification).

## Output Contract

```yaml
experiment-execution-plan.yaml:
  schema_version: "1.0.0"
  round_id: integer
  participant_flow:
    recruitment_method: string
    screening_procedure: string
    consent_procedure: string
    assignment_procedure: string
    session_structure: [string]
    debriefing_procedure: string
    compensation: string
    withdrawal_handling: string
  materials:
    hardware: [{ spec: string, calibration: string }]
    software: [{ name: string, version: string, configuration: string }]
    instruments: [{ name: string, model: string, calibration_schedule: string }]
    environment: { lighting: string, noise: string, temperature: string, seating: string }
    stimuli: { creation_procedure: string, validation: string, counterbalancing: string }
    questionnaires: [{ name: string, source: string, scoring: string }]
  procedure_timeline:
    phases: [{ phase: string, duration_minutes: number, events: [string] }]
    total_duration_minutes: number
    rest_breaks: string
  data_collection:
    capture_method: manual | automated | hybrid
    data_fields: [string]
    integrity_checks: [string]
    quality_monitoring: string
    storage_procedure: string
    participant_id_scheme: string
  analysis_order:
    data_cleaning: [string]
    missing_data_analysis: string
    assumption_checks: [string]
    primary_analysis: string
    secondary_analyses: [string]
    sensitivity_analyses: [string]
    result_format: string
  quality_assurance:
    pre_experiment: [string]
    during_experiment: [string]
    post_experiment: [string]

experiment-materials-checklist.yaml:
  schema_version: "1.0.0"
  round_id: integer
  hardware: [{ item: string, quantity: integer, spec: string, calibration_required: boolean }]
  software: [{ name: string, version: string, license: string, configuration: string }]
  instruments: [{ name: string, model: string, calibration_due: string }]
  environment: [{ parameter: string, required_value: string, tolerance: string }]
  stimuli: [{ name: string, format: string, validation_status: string }]
  questionnaires: [{ name: string, source: string, language: string, scoring_available: boolean }]
  documentation: [{ document: string, status: ready | needs_update | missing }]
```
## Failure Conditions
- Participant flow missing any phase (recruitment, consent, assignment, session, debriefing).
- Materials section missing any category.
- Procedure timeline missing phase durations.
- Data collection protocol missing integrity checks.
- Analysis order missing primary analysis specification.
- Quality assurance missing any phase.

## Completion Checklist
- [ ] Participant flow covers recruitment through debriefing.
- [ ] Materials, instruments, software, and environment fully specified.
- [ ] Procedure timeline has phases with durations.
- [ ] Data collection protocol includes integrity and quality checks.
- [ ] Analysis order specifies cleaning, assumptions, primary, secondary.
- [ ] Quality assurance checkpoints defined for all phases.
- [ ] All artifacts are valid YAML.

## Full-Experiment Coverage Requirement
Execution plan must operationalize every variable, measure, and control from the methodology design, not just the primary target.

## Handoff
The next stage (`revision_plan`) transforms critiques and the execution plan into concrete revision decisions.
