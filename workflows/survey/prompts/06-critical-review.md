# Stage 6: Critical Review
# Purpose: Critically review the survey as updated by taxonomy synthesis.
# Identify remaining weaknesses, unsupported claims, missing coverage.

## Inputs
- `taxonomy-update.yaml` — proposed taxonomy changes
- `evidence-ledger.yaml` — evidence backing
- Target survey document — current state (unit-anchored)
- Project knowledge — claims that the survey should support or challenge

## Task
Produce `critical-review.yaml`:

1. **Taxonomy critique**:
   - Are classification criteria truly orthogonal? Test with edge cases.
   - Are there systems that don't fit? (Should they — or does the taxonomy need adjusting?)
   - Are comparison dimensions hiding important differences?
   - Is there a dimension that would separate systems better?

2. **Coverage critique**:
   - What key systems are still missing?
   - Are strong baselines missing? (The ones that would make the project look weaker)
   - Is coverage biased toward similar approaches?

3. **Evidence critique**:
   - Which claims lack direct source backing?
   - Which claims rely on inference rather than direct evidence?
   - Are sources authoritative? (peer-reviewed vs. preprints vs. blog posts)
   - Are sources current?

4. **Writing critique**:
   - Does the survey read as a taxonomy or a literature dump?
   - Are transitions between systems meaningful?
   - Do readers understand WHY each system is discussed?

5. **Positioning critique**:
   - Does the survey fairly represent competing approaches?
   - Is the project's own approach positioned in the taxonomy?
   - Are gaps identified that the project fills?

## Rubric
Every critique item MUST be specific (point to a system, claim, dimension, or paragraph).
No vague "this could be better" without concrete evidence.

## Output
`critical-review.yaml` — numbered critique items with severity and evidence.
