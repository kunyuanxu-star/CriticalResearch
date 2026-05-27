# Stage 5: Invariant and Interface Validation

## Mission
Perform formal validation of every invariant and interface in the design state. Check invariant soundness, interface contract completeness, compositional consistency, and cross-component consistency. Produce invariant-validation.yaml and interface-validation.yaml with pass/fail results and required remediations.

This stage enforces **Inv5**: Every invariant and interface must pass formal validation before a design patch can be applied.

## Inputs
- `round:design-state.yaml` — frozen design snapshot with all invariants and interfaces
- `round:critique-ledger.yaml` — critique entries targeting invariants and interfaces
- `round:evidence-ledger.yaml` — evidence relevant to invariant correctness

## Outputs
- `invariant-validation.yaml` — per-invariant validation results
- `interface-validation.yaml` — per-interface validation results
- `cross-component-consistency.yaml` — compositional validation results

## Allowed Actions
- Read design state, critique ledger, and evidence.
- Validate every invariant for falsifiability, scope correctness, and enforcement adequacy.
- Validate every interface for contract completeness and assumption explicitness.
- Check invariant composition: are global invariants preserved under component composition?
- Check interface compatibility: do connected interfaces have compatible contracts?
- Flag violations with required remediation and severity.
- Link findings to source critiques where applicable.

## Forbidden Actions
- Do not edit design document.
- Do not generate patches.
- Do not apply patches.
- Do not create new invariants or interfaces — only validate existing ones.
- Do not skip invariants or interfaces in the design state scope.

## Procedure

### 1. Invariant Validation
For every invariant in design-state.yaml:
- **Falsifiability check**: Can the invariant be proven false if violated? If not, flag as imprecise.
- **Scope check**: Is the scope (component | interface | global) correct? Does the invariant span the right boundary?
- **Enforcement check**: Is the enforcement_mechanism adequate for the classification? (e.g. safety invariants need static_check or by_construction).
- **Violation consequence check**: Is the consequence documented and appropriate?

### 2. Interface Validation
For every interface in design-state.yaml:
- **Precondition completeness**: Are all caller obligations stated?
- **Postcondition completeness**: Are all callee guarantees stated?
- **Assumption explicitness**: Are implicit assumptions surfaced?
- **Error mode coverage**: Are all error paths documented?
- **Type contract**: Are data types, ranges, and ordering constraints complete?

### 3. Cross-Component Consistency
- **Compositional invariant check**: For each global invariant, verify it holds under all valid compositions of component-level operations.
- **Interface compatibility check**: For every pair of connected interfaces (provided ↔ required), verify contract compatibility (weakest precondition → strongest postcondition alignment).
- **Invariant conflict check**: Verify no pair of invariants is mutually contradictory.

### 4. Flag and Remediate
For every validation failure:
- Assign violation_id with severity (fatal | high | medium | low).
- Link to source critique_id if applicable.
- Produce required_remediation with concrete action.

## Output Contract

```yaml
invariant-validation.yaml:
  schema_version: "1.0.0"
  round_id: integer
  validations:
    - invariant_id: INV-###
      falsifiable: bool
      scope_correct: bool
      enforcement_adequate: bool
      violation_consequence_documented: bool
      passed: bool
      violations:
        - violation_id: VIO-###
          severity: fatal|high|medium|low
          description: string (>= 10)
          source_critique: CRT-### (optional)
          required_remediation: string (>= 10)

interface-validation.yaml:
  schema_version: "1.0.0"
  round_id: integer
  validations:
    - interface_id: IFC-###
      preconditions_complete: bool
      postconditions_complete: bool
      assumptions_explicit: bool
      error_modes_covered: bool
      type_contract_complete: bool
      passed: bool
      violations:
        - violation_id: VIO-###
          severity: fatal|high|medium|low
          description: string (>= 10)
          source_critique: CRT-### (optional)
          required_remediation: string (>= 10)

cross-component-consistency.yaml:
  schema_version: "1.0.0"
  round_id: integer
  compositional_checks:
    - global_invariant_id: INV-###
      holds_under_composition: bool
      counterexample: string (optional)
  interface_compatibility_checks:
    - provider_interface: IFC-###
      consumer_interface: IFC-###
      compatible: bool
      mismatch_description: string (optional)
  invariant_conflicts: []
```

## Failure Conditions
- Any invariant fails validation with severity fatal and no remediation.
- Any interface fails validation with severity fatal and no remediation.
- Cross-component consistency check reveals a global invariant violation.
- Any connected interface pair is incompatible.
- Validation results do not cover all invariants and interfaces in design state.

## Completion Checklist
- [ ] Every invariant validated for falsifiability, scope, enforcement, and consequence.
- [ ] Every interface validated for precondition, postcondition, assumptions, error modes, and types.
- [ ] Compositional invariants checked for preservation under composition.
- [ ] Connected interface pairs checked for contract compatibility.
- [ ] No invariant conflicts detected.
- [ ] All violations have required_remediation.

## Full-Design Coverage Requirement
Every invariant and interface in the design state must be validated, regardless of round target.

## Handoff
The next stage (`revision_plan`) turns critiques and validation failures into concrete revision decisions.
