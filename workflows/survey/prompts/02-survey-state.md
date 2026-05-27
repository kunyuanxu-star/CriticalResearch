# Stage 2: Survey State
# Purpose: Assess the current state of the target survey units — what's covered,
# what's missing, what's weak.

## Inputs
- `contract.yaml` — round scope and target units
- Target survey document — full text within target unit anchors
- `units/<target>.units.yaml` — unit maturity assessments
- Project knowledge — claims, terminology, related work

## Task
Produce `survey-state.yaml` containing:

1. **Per-unit assessment** for each target unit:
   - Current coverage: what systems/taxonomies are discussed
   - Maturity ratings: evidence (missing/partial/complete), taxonomy (missing/partial/complete), critique (missing/partial/complete)
   - Gaps: what's missing — specific systems, classification criteria, comparison dimensions, or evidence
   - Weak spots: claims without evidence, flat listings that aren't taxonomies, outdated references

2. **Overall survey assessment**:
   - Does the survey form a taxonomy or just a literature dump?
   - Are classification criteria orthogonal?
   - Are comparison dimensions consistent across sections?
   - Is there a gap in system coverage?
   - Are strong baselines missing?

3. **Source inventory**:
   - What sources are already cited?
   - What key papers/systems are not yet covered?
   - Are citations current?

## Output
`survey-state.yaml` with structured assessment used to drive research planning.
