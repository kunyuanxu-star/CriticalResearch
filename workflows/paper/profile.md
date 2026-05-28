# Paper Workflow Profile

This profile defines the research semantics specific to the paper workflow. Stage prompts reference these concepts, and the workflow harness uses them to scope validators, patch types, and critique rubrics.

## Core Concepts

### Claim
A falsifiable statement the paper asserts as true. Every claim MUST be:
- Specific enough to be tested or argued against
- Scoped to a domain, workload, or condition
- Supported by evidence of adequate strength

Claims exist on a spectrum:
- **Core claim**: The paper's primary contribution — without it, the paper has no value
- **Supporting claim**: A subsidiary claim that supports the core claim (e.g., a performance property that enables the main result)
- **Assumption claim**: A condition the paper asserts holds in its target setting
- **Comparison claim**: A claim about superiority, difference, or equivalence relative to a baseline
- **Scope claim**: A claim about the generality, applicability, or limitations of the work

### Evidence
Material that supports or weakens a claim. Evidence types in paper workflows:
- **Empirical measurement**: Benchmark results, performance traces, latency distributions
- **Formal argument**: Proofs, invariants, complexity analysis — must be complete, not sketched
- **Prior work citation**: Established results from peer-reviewed work — must be specific, not vague
- **Case study / qualitative**: Real-world deployment experience, user feedback — must be documented
- **Ablation**: Controlled experiment isolating one variable — must vary only that variable

### Argument Flow
The logical progression from problem to contribution. A well-formed paper argument:
1. Establish the problem (why should the reader care?)
2. Identify the root cause (why do existing solutions fail?)
3. Present the insight (what non-obvious observation enables the solution?)
4. Describe the approach (how does the insight translate to a system/method?)
5. Evaluate the claim (does the evidence support the claim?)
6. State the contribution (what does the reader now know that they didn't before?)

Argument flow is LINEAR — each section advances the story without backtracking or redundancy.

### Positioning
How the paper situates itself relative to prior work:
- **Novelty**: What is new? What gap does this fill?
- **Relationship**: How does this relate to prior work — builds on, contrasts with, generalizes, specializes?
- **Credit**: Are prior contributions accurately attributed?
- **Distinction**: Is the contribution clearly distinguishable from the closest prior work?

Poor positioning is a common desk-reject reason. The paper must make it easy for a reviewer to see what is new and why it matters.

### Writing Quality
Top-venue writing standards (SOSP, OSDI, NSDI, EuroSys, ATC):
- **Claim-up-front**: Every section and paragraph leads with its claim
- **No throat-clearing**: No "In recent years, there has been growing interest in..." openings
- **Concrete over abstract**: "Reduces tail latency by 3.2x at p99.9" not "Significantly improves performance"
- **Figure-first design**: Figures and tables should tell the story; text supports them
- **Defined-before-use**: Terms, metrics, and notation are defined before they are used
- **Limitations stated**: Every claim's scope and limitations are explicit, not hidden in future work

### Reviewer Risk
Categories of attack a top-venue reviewer will mount:
- **Novelty attack**: "This is incremental / obvious / a straightforward combination of A and B"
- **Baseline attack**: "The baselines are weak / misconfigured / not state-of-the-art"
- **Evaluation attack**: "The evaluation doesn't test the claim / missing sensitivity analysis / single workload"
- **Threat model attack**: "The threat model is unrealistic / missing / too narrow"
- **Fairness attack**: "The comparison is unfair — the baseline wasn't tuned / uses different hardware"
- **Writing attack**: "The paper is hard to follow / the contribution is unclear / the argument is circular"

Every critique stage must systematically probe each risk category.

### Evaluation Obligation
A requirement for evidence that, if unsatisfied, leaves a claim undefended:
- **Direct obligation**: An experiment that directly tests the claim
- **Sensitivity obligation**: An experiment that tests the claim's sensitivity to key parameters
- **Comparison obligation**: A fair comparison to the strongest baseline
- **Limitation obligation**: A documented limitation that bounds the claim's scope

Evaluation obligations are the output of the evidence grounding stage. They become inputs to revision planning and knowledge delta extraction.

## Workflow Constraints

- Exactly one mutable document per round: the paper document
- Other documents (design-doc, survey, proposal) may be read but never modified
- If paper changes imply design changes, record as `next_round_candidates` — do not modify the design document in a paper round
- Patches may only use patch types declared in `workflows/paper/workflow.yaml`
- Paper validators run after engine validators: claims alignment, evidence alignment, writing quality, single mutable document, paper units
