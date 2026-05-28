# Evidence Discipline

This is a shared discipline document referenced by stage prompts across all workflows. It defines rules for evidence quality, sourcing, and grounding — ensuring that every critique, claim assessment, and revision decision is anchored in material that can be verified.

## Core Principle

Every critique, claim assessment, and revision decision MUST be grounded in one or more of:
1. **Document text** — a specific passage in the target document
2. **Evidence artifact** — measurement data, proof, survey finding, benchmark result
3. **Domain convention** — established practice in the target CS area (cite the convention)
4. **Venue standard** — explicit expectation of the target venue (cite the standard)

Sourceless criticism is FORBIDDEN. "This feels weak" without grounding is not a valid critique. "The evaluation is insufficient" without specifying what is missing and why it matters is not a valid critique.

## Evidence Types and Strength

| Type | Strength | Description |
|------|----------|-------------|
| Direct measurement | Strong | Reproducible experiment, benchmark, or empirical study that directly tests the claim |
| Formal proof | Strong | Mathematical proof of a claim under stated assumptions |
| Cited prior work | Moderate | Peer-reviewed result that supports the claim (cite the work specifically) |
| Ablation / sensitivity study | Moderate | Controlled variation showing the claim holds under different conditions |
| Logical argument | Weak | Reasoning from premises to conclusion, without empirical backing |
| Anecdote / intuition | None | Personal experience or intuition — not evidence |

## Evidence Adequacy Rules

- A claim backed only by logical argument is **under-supported** — flag it.
- A claim backed by a single moderate source is **adequate but narrow** — note the limitation.
- A claim with no supporting evidence is **unsupported** — flag as high risk.
- A claim that asserts stronger conclusions than its backing evidence warrants is **overclaimed**.

## Prohibited Evidence Patterns

- **Evidence by assertion**: "It is obvious that X" or "Clearly, Y follows from Z" without justification
- **Evidence by citation bombing**: Citing 5+ papers without explaining what each contributes
- **Evidence by vagueness**: "We evaluated on real-world workloads" without specifying the workload
- **Evidence by hand-waving**: "The results show significant improvement" without quantifying
- **Circular evidence**: Using the paper's own claim as evidence for a related claim

## Evidence Traceability

Every piece of evidence cited in a critique or claim assessment MUST be traceable:
- Document text → cite the section and paragraph
- Measurement → cite the experiment name, figure/table number, and metric
- Prior work → cite the specific paper and finding, not just the reference number
- Domain convention → cite the source that establishes the convention

## When Evidence Is Missing

When a claim lacks adequate evidence:
1. Record the gap explicitly — what evidence is missing, why it matters
2. Do NOT fabricate evidence or assert support that does not exist
3. Do NOT downgrade the claim to match available evidence without flagging the downgrade
4. Generate an evaluation obligation: what experiment, proof, or analysis would close the gap

## Evidence in Paper Workflows

Paper-specific evidence concerns:
- Claims about system properties (performance, scalability, reliability) REQUIRE measurement evidence
- Claims about novelty REQUIRE comparison to closest prior work
- Claims about generality REQUIRE evidence beyond a single workload or configuration
- Claims about correctness REQUIRE formal argument or exhaustive testing
- Claims about usability REQUIRE user study or expert review
