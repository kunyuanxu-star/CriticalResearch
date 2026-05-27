# Stage 3: Research Planning
# Purpose: Plan which sources to find and analyze to fill the gaps identified
# in the survey state assessment.

## Inputs
- `contract.yaml` — scope
- `survey-state.yaml` — current gaps and weak spots
- Project knowledge — existing related work

## Task
Produce `research-plan.yaml`:

1. **Source hunting targets**: For each gap identified in survey-state.yaml:
   - What specific papers/systems need to be found?
   - What search strategies? (venues: SOSP, OSDI, EuroSys, ATC, ASPLOS, VEE, NSDI)
   - What are the must-find canonical references?

2. **Analysis framework**:
   - For each candidate source: what taxonomy dimension does it inform?
   - What specific claims to extract?
   - How to classify it within the existing taxonomy?

3. **Priority ordering**:
   - Tier 1: Canonical references that would invalidate current analysis if missing
   - Tier 2: Recent work that may shift the taxonomy
   - Tier 3: Edge cases and niche approaches for completeness

4. **Stop conditions**:
   - When to stop searching (saturation criteria)
   - Minimum sources per gap

## Output
`research-plan.yaml` with prioritized source targets and search strategies.
