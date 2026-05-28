# Stage 1: Experiment Contract

## Mission
Formalize the experiment's intent into a signed Experiment Contract. This stage combines document state snapshot, knowledge loading, experiment objective definition, and full-experiment coverage freeze into a single coherent contract. No experiment design may proceed without a signed contract.

## Inputs
- `documents/experiment-plan.md` — current experiment plan
- `state/claim-ledger.yaml` — existing hypothesis and claim definitions
- `workspace:_cr/knowledge/` — global knowledge cards

## Outputs
- `contract.yaml` — formalized contract with target, scope, intensity, required outputs, forbidden scope, success criteria

## Allowed Actions
- Read experiment plan, claim ledger, and knowledge cards.
- Extract and structure hypotheses, variables, controls, measures, baselines, validation criteria.
- Identify fragile hypotheses and at-risk experimental components.
- Record loaded knowledge summary in state.
- Write contract.yaml.

## Forbidden Actions
- Do not search for external sources.
- Do not generate critique.
- Do not modify experiment plan.
- Do not generate patches.
- Do not limit experiment scope beyond forbidden_scope declaration.

## Procedure

### 1. Experiment State Reconstruction
Read `documents/experiment-plan.md` and `state/claim-ledger.yaml`.
Extract:
- Primary hypothesis (one sentence).
- Every sub-hypothesis with hypothesis_id, text, scope, assumption, evidence_status.
- Independent variables, dependent variables, controlled variables.
- Current measurement plan and metrics.
- Current baselines and comparison targets.
- At least one fragile hypothesis with fragility_reason >= 10 chars.
- At-risk experimental components with specific vulnerabilities.

### 2. Knowledge Loading
Read `workspace:_cr/knowledge/` cards relevant to the experiment's domain.
Record which cards were loaded and why they matter.
If knowledge base is empty, document why and proceed.

### 3. Experiment Objective Definition
From the user's objective and the experiment state, define:
- `target`: concrete, bound to a hypothesis or experimental component, >= 10 chars.
- `scope.experimental_components`: all components (objective is weighting lens, not scope limiter).
- `scope.hypotheses`: all hypotheses.
- `scope.forbidden_scope`: explicit boundaries the experiment must not cross.
- `intensity`: triage | standard | deep.
- `required_outputs`: minimum set of artifacts this experiment must produce.
- `success_criteria`: at least one criterion with statement >= 10 chars.

### 4. Coverage Freeze
Document that the experiment covers all hypotheses and components. The objective determines priority and emphasis, but must not narrow coverage.

## Output Contract

```yaml
schema_version: "1.0.0"
round_id: integer
contract:
  target: string (>= 10 chars)
  scope:
    experimental_components: [string] (all components)
    hypotheses: [HYP-###] (all hypotheses)
    forbidden_scope: [string] (explicit boundaries)
  intensity: triage | standard | deep
  required_outputs:
    - evidence_ledger
    - critique_ledger
    - review_disposition
    - revision_plan
    - experiment_plan
    - patch_trace
    - writing_diff
    - knowledge_delta
    - next_round_targets
  success_criteria:
    - criterion_id: SC-###
      statement: string (>= 10 chars)
      metric: string (optional)
      threshold: string (optional)
```

## Failure Conditions
- No hypotheses extracted.
- Any hypothesis missing scope, assumption, or evidence_status.
- No fragile hypothesis identified or fragility_reason < 10 chars.
- Primary hypothesis empty or placeholder.
- target < 10 chars.
- success_criteria empty.
- required_outputs missing mandatory artifacts.

## Completion Checklist
- [ ] Experiment state reconstructed: hypotheses, variables, controls, measures, baselines, validation.
- [ ] Knowledge cards loaded and documented.
- [ ] Experiment contract has target, scope, intensity, required_outputs, success_criteria.
- [ ] Full-experiment coverage declared explicitly.
- [ ] contract.yaml is valid YAML.
## Full-Experiment Coverage Requirement
This stage must operate over the entire experiment plan. The objective is a weighting lens, not a scope limiter. Document:

```yaml
full_experiment_coverage:
  components_checked: []
  hypotheses_checked: []
  variables_checked: []
  controls_checked: []
  measures_checked: []
  omissions: []

objective_relevance:
  level: direct | indirect
  explanation: ""
  objective_specific_findings: []
```

## Handoff
The next stage in the stage order (`experiment_state`) loads experiment context and prepares for methodology design.
