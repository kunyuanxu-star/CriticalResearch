# Stage 8: Apply Survey Patch
# Purpose: Apply the revision plan patches to the survey document.
# Each patch modifies content within the declared unit anchors.

## Inputs
- `revision-plan.yaml` — ordered patch plan
- Target survey document — current text with unit anchors
- `units/<target>.units.yaml` — unit boundaries
- `evidence-ledger.yaml` — source evidence for citations

## Task
For each patch in revision-plan.yaml, in order:

1. **Generate the patch** as `patches/SP-NNN.yaml`:
   ```yaml
   schema_version: "1.0.0"
   patch_id: SP-NNN
   workflow: survey
   project_id: <project>
   round_id: <round>

   target_document:
     id: survey
     path: documents/survey.md

   target_units:
     - survey.<unit-name>

   source_trace:
     evidence: [E-001, E-004]
     critiques: [C-002]
     decisions: [D-001]

   patch_type: <taxonomy_revision | related_work_section_rewrite | ...>
   status: pending

   survey_payload:
     taxonomy_changes: []
     comparison_dimensions: []
     sources_added: []
     text_changes:
       - unit: survey.<unit-name>
         operation: <insert | replace | delete>
         anchor_after: "<marker text in document>"
         content: |
           <new content>
   ```

2. **Apply the patch** to the target document:
   - Only modify content within unit anchors
   - Never modify anchor comments themselves
   - Verify that the document parses correctly after changes
   - Record before/after snippets

3. **Mark patch status**: `applied` after successful application.

4. **Record cross-document implications**: If this patch reveals that another document needs changes, add to `next_round_candidates` in the contract.

## Constraint
- Only modify the declared mutable document.
- Only modify content within the declared unit anchors.
- The `text_changes` in survey_payload describe what changed, for traceability.

## Output
- `patches/SP-NNN.yaml` — one per patch, with status updated to `applied`
- Modified survey document — content within unit anchors updated
