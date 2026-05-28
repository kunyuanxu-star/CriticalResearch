# Stage 10: Closure
# Verify design round completion.

## Inputs
- All round artifacts
- `contract.yaml` — success criteria

## Task

1. **Verify success criteria**: Check every item in `contract.yaml` `success_criteria`.

2. **Run validators**:
   - `cr-validate-single-mutable-document` — all patches target only mutable doc
   - `cr-validate-design-units` — all patches within declared units
   - `cr-validate-invariants` — invariants hold after patches
   - `cr-validate-interface-contracts` — interfaces consistent
   - `cr-validate-design-patch` — patches follow design patch schema
   - `cr-validate-document-diff` — diff covers all patches
   - `cr-validate-knowledge-delta` — delta exists and is non-trivial

3. **Produce `document-diff.yaml`**:
   - Unified or structured diff of all changes between document states
   - Mapped to patch IDs
   - Only covers changes within target unit anchors

4. **Generate `next-round-targets.yaml`**:
   - Identify deferred critiques and obligations from the revision plan
   - Identify cross-document implications (design changes that imply paper, survey, or proposal changes)
   - Identify implementation obligations that remain unaddressed
   - For each candidate: target document, units, objective, priority, rationale

5. **Produce `closure.md`**:
   - Round summary: what was done
   - Success criteria: all met?
   - Remaining risks: what's still uncertain
   - Next round candidates: suggested follow-up rounds
   - Knowledge gained: what the project learned

6. **Validate all invariants**:
   - Inv0-Inv11 all hold
   - Any violation is a hard failure

## Outputs
- `next-round-targets.yaml` — candidates for follow-up rounds
- `document-diff.yaml` — final diff of all changes
- `closure.md` — closure report
- Validation report (pass/fail with details)

## Output Contract

```yaml
next-round-targets.yaml:
  schema_version: "1.0.0"
  round_id: integer
  targets:
    - document: string
      units: [string]
      objective: string
      priority: high | medium | low
      rationale: string
      source: string
```

## Failure Conditions
- Any success criterion not met.
- Any validator fails.
- `next-round-targets.yaml` missing (even empty is valid — must exist).
- Any invariant violation.
