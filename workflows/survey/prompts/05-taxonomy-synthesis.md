# Stage 5: Taxonomy Synthesis
# Purpose: Synthesize the analyzed sources into a coherent taxonomy.
# Update classification criteria, comparison dimensions, and gap analysis.

## Inputs
- `evidence-ledger.yaml` — structured evidence from source analysis
- `source-notes.md` — narrative analysis
- `survey-state.yaml` — original gaps and weak spots
- Target survey document — current taxonomy structure

## Task
Produce `taxonomy-update.yaml`:

1. **Taxonomy structure**:
   - Define/refine classification criteria — must be orthogonal
   - Define comparison dimensions — must be consistent across all surveyed systems
   - Map every surveyed system to its position in the taxonomy

2. **Gap analysis update**:
   - What gaps are now filled?
   - What new gaps were discovered during research?
   - What areas remain under-sourced?

3. **Comparison matrices**:
   - System × Dimension matrix for the target units
   - Highlight where the project's own approach sits in the taxonomy
   - Identify empty cells that represent open research problems

4. **Taxonomy changes**:
   - What changed from the initial survey state?
   - Were any classification criteria redefined?
   - Were any systems reclassified?

## Rubric
- Are classification criteria orthogonal? (No system fits two categories simultaneously)
- Do comparison dimensions cover the key axes of differentiation?
- Are all surveyed systems placed in the taxonomy?
- Is the taxonomy more than a flat list?

## Output
`taxonomy-update.yaml`
