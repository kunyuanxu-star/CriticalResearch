# Stage 7: Revision Plan
# Purpose: Plan concrete document changes to address the critical review.
# Each critique gets a disposition and a workflow-specific patch.

## Inputs
- `critical-review.yaml` — numbered critique items
- `taxonomy-update.yaml` — proposed taxonomy changes
- `contract.yaml` — target units and scope
- Target survey document — current text

## Task
Produce `revision-plan.yaml`:

1. **Disposition for every critique**:
   - `patch`: Produce a concrete document change
   - `deferred`: Record as deferred obligation with rationale
   - `no-patch`: Explicitly reject with reasoning

2. **Patch plan** for each accepted critique:
   - Patch ID (SP-001, SP-002, ...)
   - Patch type (taxonomy_revision, related_work_section_rewrite, comparison_matrix_update, gap_analysis_update, missing_source_addition, terminology_revision)
   - Target unit(s): which unit anchors will be modified
   - Specific change description: what text to add/remove/rewrite
   - Source trace: which evidence items support this change
   - Expected diff scope: how many lines/paragraphs expected to change

3. **Ordering**: Patches in dependency order. A taxonomy_revision before a related_work_section_rewrite that depends on it.

4. **Deferred obligations**: Track anything deferred with justification and suggested future workflow/unit.

## Constraint
Every accepted critique MUST map to at least one patch.

## Output
`revision-plan.yaml`
