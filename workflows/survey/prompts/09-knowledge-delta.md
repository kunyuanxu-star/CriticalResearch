# Stage 9: Knowledge Delta
# Purpose: Extract reusable knowledge from this survey round and update
# project-level knowledge artifacts.

## Inputs
- All round artifacts (contract, state, evidence, taxonomy, critique, patches)
- Project knowledge directory — current claims, terminology, related work

## Task
Produce `knowledge-delta.yaml`:

1. **Claims**:
   - New claims discovered during the survey
   - Existing claims that need revision based on survey findings
   - Claims that are contradicted by newly surveyed systems

2. **Terminology**:
   - New terms defined during the survey
   - Existing terms that need refinement
   - Standardization of terms across related work

3. **Related work**:
   - New related work entries with structured metadata
   - Updates to existing entries
   - Gap annotations: which areas have been fully surveyed vs. need more work

4. **Design decisions**:
   - Survey findings that inform design choices
   - Baselines to beat
   - Approaches to avoid (with evidence why)

5. **Evaluation obligations**:
   - New baselines for evaluation
   - Comparison dimensions that must be measured

6. **Open questions**:
   - Gaps in the literature that remain unfilled
   - Research directions identified during the survey

## If nothing to add
If no reusable knowledge was produced, add explicit `no_knowledge_justification` explaining why this round produced no lasting knowledge. This is rare for survey rounds.

## Output
`knowledge-delta.yaml` — structured delta for merging into project knowledge
