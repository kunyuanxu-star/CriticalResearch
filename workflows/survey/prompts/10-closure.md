# Stage 10: Closure
# Purpose: Verify round completion, validate all invariants, and produce
# the closure report.

## Inputs
- All round artifacts
- `contract.yaml` — success criteria

## Task

1. **Verify success criteria**: Check every item in `contract.yaml` `success_criteria`.

2. **Run validators**:
   - `cr-validate-single-mutable-document` — all patches target only mutable doc
   - `cr-validate-survey-units` — all patches within declared units
   - `cr-validate-survey-evidence` — claims backed by evidence
   - `cr-validate-survey-patch` — patches follow survey patch schema
   - `cr-validate-document-diff` — diff covers all patches
   - `cr-validate-knowledge-delta` — delta exists and is non-trivial

3. **Produce `document-diff.yaml`**:
   - Unified or structured diff of all changes between document states
   - Mapped to patch IDs
   - Only covers changes within target unit anchors

4. **Produce `closure.md`**:
   - Round summary: what was done
   - Success criteria: all met?
   - Remaining risks: what's still uncertain
   - Next round candidates: suggested follow-up rounds
   - Knowledge gained: what the project learned

5. **Validate all invariants**:
   - Inv0-Inv11 all hold
   - Any violation is a hard failure

## Output
- `document-diff.yaml`
- `closure.md`
- Validation report (pass/fail with details)
