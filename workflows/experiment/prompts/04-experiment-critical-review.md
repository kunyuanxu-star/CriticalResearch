# Stage 4: Experiment Critical Review

## Mission
Conduct adversarial review of the experiment methodology using the experiment state. Execute five critique passes: design validity, methodology soundness, variable control, measurement appropriateness, and writing/argument. Merge all findings into a unified critique-ledger.yaml and produce review-disposition.yaml.

Every major critique must be grounded in evidence, experiment design standards, domain convention, or statistical best practice.

## Inputs
- `round:experiment-state.yaml` — frozen experiment snapshot
- `round:methodology-design.yaml` — complete methodology specification
- `documents/experiment-plan.md` — current experiment plan
- `round:round-contract.yaml` — experiment contract

## Outputs
- `critique-ledger.yaml` — structured critique entries
- `review-disposition.yaml` — per-critique disposition with required actions

## Allowed Actions
- Read experiment state, methodology design, experiment plan, and contract.
- Critique design validity, methodology soundness, variable control, measurement appropriateness, and writing/argument.
- Merge all critique passes into a unified ledger.
- Decide disposition for every critique.
- Link critiques to source hypotheses, variables, measures, and experimental components.

## Forbidden Actions
- Do not edit experiment plan.
- Do not generate patches.
- Do not apply patches.
- Do not reject medium+ critiques without substantive reason.

## Procedure

### 1. Synthesize Hypothesis Support
For every hypothesis, assess falsifiability, scope precision, and assumption validity.

### 2. Synthesize Methodology Soundness
Identify the strongest threats to internal validity, whether the design can answer the primary hypothesis, and whether power analysis supports claimed effect sizes.

### 3. Synthesize Measurement Gaps
For each measured construct, document validity threats not addressed in methodology, reliability concerns under intended conditions, and measurement range appropriateness.

### 4. Critique Passes
Execute five critique passes. Every finding must be grounded in evidence, experiment design standards, domain convention, or statistical best practice.

**Pass A: Design Validity** — Does the design match the hypothesis type? Are confounds controlled? Is randomization sufficient? Are internal validity threats addressed?

**Pass B: Methodology Soundness** — Is sampling adequate? Is power analysis correct? Are statistical assumptions checkable? Is the analysis plan appropriate?

**Pass C: Variable Control** — Are independent variables properly operationalized? Are manipulation checks sufficient? Are controls at appropriate levels? Are confounds identified and mitigated?

**Pass D: Measurement Appropriateness** — Do instruments measure what they claim? Is reliability evidence sufficient? Are measurement schedules appropriate? Are ceiling/floor effects addressed?

**Pass E: Writing and Argument** — Is the hypothesis chain coherent? Are choices justified? Is the plan described with replication-level detail? Are limitations acknowledged?

### 5. Merge Critique Ledger
Merge all five passes into critique-ledger.yaml. Assign unique critique_id to each finding. Ensure every medium+ critique has evidence_refs. Set must_create_patch=true for all high/fatal critiques. Every critique must have reason >= 20 chars. Record source_evidence, affected_hypotheses, affected_components.

### 6. Review Disposition
For every critique, produce a disposition in review-disposition.yaml with disposition_id, critique_id, disposition_type, justification, status, required_action (action_type, target_component, rationale), affected_hypotheses, affected_components. Status must be: open | resolved | pending_human_decision.

## Output Contract

```yaml
critique-ledger.yaml:
  schema_version: "1.0.0"
  round_id: integer
  critiques:
    - critique_id: CRT-###
      severity: fatal | high | medium | low
      target_type: design | methodology | variable_control | measurement | writing | internal_consistency
      target_id: string
      critique_pass: design_validity | methodology_soundness | variable_control | measurement_appropriateness | writing_argument
      attack_statement: string (>= 10)
      why_damaging: string (>= 10)
      evidence_refs: [E###]
      disposition_ref: DSP-###
      affected_hypotheses: [HYP-###]
      affected_components: [string]
      required_action:
        action_type: string
        target_components: [string]
        must_create_patch: bool

review-disposition.yaml:
  schema_version: "1.0.0"
  round_id: integer
  dispositions:
    - disposition_id: DSP-###
      critique_id: CRT-###
      disposition_type: methodology_patch | measurement_change | control_addition | design_change | deferred | rejected_with_reason | no_op
      justification: string (>= 10)
      status: open | resolved | pending_human_decision
      severity: fatal | high | medium
      required_action:
        action_type: redesign | add_control | change_measure | add_analysis | reframe | delete | defer
        target_component: string
        rationale: string (>= 10)
      affected_hypotheses: [HYP-###]
      affected_components: [string]
```

## Failure Conditions
- No medium+ critiques.
- Any high/fatal critique has must_create_patch=false.
- Any critique reason < 20 chars.
- Any critique missing evidence_refs (medium+).
- Any critique has no disposition.
- Any disposition missing required_action.

## Completion Checklist
- [ ] All five critique passes completed.
- [ ] Critique ledger merged with unique IDs.
- [ ] Every medium+ critique has evidence_refs.
- [ ] Every high/fatal critique has must_create_patch=true.
- [ ] Every critique has a disposition.
- [ ] Review-disposition.yaml has required_action for every disposition.

## Full-Experiment Coverage Requirement
Critique must cover all hypotheses, variables, measures, and controls in the experiment state, not just the primary target.

## Handoff
The next stage (`experiment_plan`) produces a concrete experiment execution plan incorporating the critique findings.
