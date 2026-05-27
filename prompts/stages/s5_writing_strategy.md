# Stage 5: Writing Strategy

## Mission
Transform the revision plan into a concrete writing strategy and patch plan. Define argument order at the high level, rhetorical function per paragraph, and sentence-level function. Map each revision to a specific writing pattern and patch.

## Inputs
- `round:revision-plan.yaml` — claim/structure/evidence-level revisions
- `project:writing/paper-draft.md` — current paper draft

## Outputs
- `writing-plan.yaml` — three-level writing strategy
- `patch-plan.yaml` — concrete patch plan with writing patterns

## Allowed Actions
- Read revision plan and current draft.
- Design high-level argument order.
- Plan paragraph-level rhetorical functions.
- Plan sentence-level functions.
- Map revisions to writing patterns and patches.

## Forbidden Actions
- Do not edit paper draft.
- Do not apply patches.
- Do not generate new critique.

## Procedure

### 1. High-Level Argument Order
Define the order of sections and their rhetorical functions:
- setup, problem, method, result, implication, limitation.

### 2. Paragraph-Level Planning
For each affected section, plan paragraphs with:
- paragraph_id, rhetorical_function, target_section, linked_patch.

Rhetorical functions: claim, evidence, contrast, cause, result, transition, qualification, example.

### 3. Sentence-Level Planning
For key paragraphs, plan sentences with:
- sentence_id, function, text, linked_claim.

Sentence functions: claim, contrast, cause, result, evidence, qualification, definition.

### 4. Patch Planning
Map each revision to a concrete patch:
- patch_id, revision_refs, writing_pattern, target_section, description.
- before_anchor, after_anchor.
- experiment_required, human_decision_required, status.

Writing patterns:
- add_paragraph, delete_paragraph, reorder_paragraphs.
- strengthen_claim, weaken_claim, reframe_claim.
- add_citation, add_figure, add_table.
- rewrite_section, split_section, merge_sections.

## Output Contract

```yaml
writing-plan.yaml:
  schema_version: "1.0.0"
  round_id: integer
  high_level:
    argument_order:
      - section: string
        function: setup|problem|method|result|implication|limitation
  paragraph_level:
    - paragraph_id: PARA-###
      rhetorical_function: claim|evidence|contrast|cause|result|transition|qualification|example
      target_section: string
      linked_patch: PP-### (optional)
  sentence_level:
    - sentence_id: SENT-####
      function: claim|contrast|cause|result|evidence|qualification|definition
      text: string
      linked_claim: CLM-### (optional)

patch-plan.yaml:
  schema_version: "1.0.0"
  round_id: integer
  patches:
    - patch_id: PP-###
      revision_refs: [REV-###]
      writing_pattern: add_paragraph|delete_paragraph|reorder_paragraphs|strengthen_claim|weaken_claim|reframe_claim|add_citation|add_figure|add_table|rewrite_section|split_section|merge_sections
      target_section: string
      description: string (>= 10 chars)
      before_anchor: string (optional)
      after_anchor: string (optional)
      experiment_required: bool
      human_decision_required: bool
      status: planned|approved|blocked|applied|rejected
  no_patch_reason: string (>= 10 chars, optional)
```

## Failure Conditions
- Any revision has no corresponding patch.
- Any patch missing writing_pattern or target_section.
- writing-plan.yaml missing high_level, paragraph_level, or sentence_level.

## Completion Checklist
- [ ] High-level argument order defined.
- [ ] Paragraph-level rhetorical functions planned.
- [ ] Sentence-level functions planned for key paragraphs.
- [ ] Every revision mapped to a patch.
- [ ] Patches have writing patterns and target sections.

## Full-Paper Coverage Requirement
Writing strategy must cover all sections affected by revisions, even if the primary target is narrow.

## Handoff
The next stage (`s6_paper_patch`) applies patches to the draft and records traceability.
