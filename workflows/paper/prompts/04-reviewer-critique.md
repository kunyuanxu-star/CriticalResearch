# Stage 4: Reviewer Critique
# Simulate a top-venue reviewer: adversarial, evidence-demanding, precise.

## Inputs
- `paper-state.yaml`
- `claim-evidence-grounding.yaml`
- Target paper

## Task
Produce `critical-review.yaml`:

1. **Motivation critique**: Is the problem real? Does the paper make the reader care?

2. **Root cause critique**: Does the paper identify why prior approaches fail?
   Does it explain the root cause, not just symptoms?

3. **Insight critique**: Is the insight non-trivial? Would a competent systems
   researcher arrive at the same conclusion? "So what?" test.

4. **Claim critique**: Are claims defensible? Which claims are overclaimed?
   Which need weakening? Are baselines dangerous enough?

5. **Design critique**: Is the design clear? Are invariants stated?
   Are tradeoffs explicit? What are the limitations?

6. **Evaluation critique**: Does evaluation match claims? Are baselines fair?
   Are measurements reproducible? What's missing?

7. **Writing critique**: Does writing match top-venue style?
   Is argument chain linear? Are there redundant passages?
