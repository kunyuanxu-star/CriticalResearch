# Patch Discipline

This is a shared discipline document referenced by stage prompts across all workflows. It defines the rules for generating, applying, and tracing document patches — ensuring every modification to the mutable document is justified, traceable, and reversible.

## Core Principle

Every document patch MUST form a complete traceability chain:

```
Critique → Disposition → Revision Decision → Patch → Document Diff
```

No link in this chain may be missing. A patch without a precursor critique is a free-form edit and is FORBIDDEN. A critique without a resulting disposition (accepted, rejected, deferred, or disputed) is unresolved.

## Patch Anatomy

Every patch MUST declare:
- **Patch ID**: unique identifier within the round (e.g., `PP-001`, `PP-002`)
- **Source critique**: which critique entry (or entries) this patch addresses
- **Disposition**: the resolution of the source critique (accepted, rejected, deferred, disputed)
- **Target unit(s)**: which document units are modified
- **Patch type**: the kind of change (workflow-specific — see workflow.yaml for valid types)
- **Expected effect**: what the patch is intended to accomplish in the document
- **Actual diff**: the concrete text changes applied

## Patching Rules

### Before Applying
1. Every patch MUST have a corresponding entry in the revision plan
2. The revision plan MUST record the disposition for every critique the patch addresses
3. Patches MUST be ordered by dependencies — if patch B modifies text introduced by patch A, A must come first
4. Target units MUST exist in the document's unit registry

### During Application
1. Modifications MUST stay within declared unit boundaries
2. Text changes MUST be concrete — "improve the argument" is not a concrete change
3. Insert, replace, and delete operations MUST specify exact anchor points
4. Do not modify text outside target units unless the patch type is a structural operation that spans unit boundaries

### After Application
1. Every applied patch MUST produce a corresponding entry in `document-diff.yaml`
2. The document-diff entry MUST show the exact before/after text change
3. Verify that the patch's expected effect was achieved — if not, revise or record the discrepancy

## Prohibited Patch Patterns

- **Free-form editing**: Modifying the document without a traceable critique
- **Scope creep**: Fixing unrelated issues while applying a patch
- **Silent changes**: Modifying text without recording it in document-diff
- **Claim inflation**: Strengthening a claim beyond what the evidence supports
- **Ghost patches**: Recording a patch in the revision plan but not applying it, or applying a patch without recording it

## Patch Trace

The `patch-trace.yaml` artifact records the complete chain for every patch:

```yaml
patches:
  - patch_id: PP-001
    source_critique: CR-003
    disposition: accepted
    target_units: [paper.introduction]
    patch_type: claim_weakening
    expected_effect: "Narrow claim from 'all workloads' to 'read-heavy workloads'"
    diff_id: D-001
```

## Rollback

If a patch introduces a regression (detected in a later validation stage):
1. Record the regression as a new critique
2. Generate a new patch to reverse or correct the problematic change
3. Do NOT manually edit the document to undo — all changes must be patched

## Workflow-Specific Patch Types

Each workflow defines valid patch types in its `workflow.yaml`. Only those types may be used. Using a patch type from another workflow is FORBIDDEN.
