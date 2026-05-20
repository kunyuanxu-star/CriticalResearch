# Universal Paper-Centered Research Round

A round is not a literature summary. A round is a controlled transformation of the current paper.

## Stage 1: Reconstruct the Paper State

Before doing new work, reconstruct:

- current thesis
- research object and problem setting
- target property
- core claims and key assumptions
- strongest baseline or competing explanation
- current evaluation contract
- most fragile claim
- most damaging open critique
- paper section most at risk

Do not start researching before reconstructing the paper state.

## Stage 2: Identify the Area and Evaluation Contract

Classify the project into one or more areas: systems, networking, security, PL, databases, architecture, ML/AI, SE, HCI, visualization, graphics, robotics, algorithms/theory, interdisciplinary CS.

Choose the appropriate evaluation contract (see `references/evaluation-contracts.md`). Do not force a systems-style evaluation onto non-systems papers.

## Stage 3: Define the Round Target

Choose exactly one primary target connected to a concrete paper risk.

Valid targets: strengthen motivation, attack a central claim, identify strongest baseline, clarify assumptions, refine contribution, design missing evaluation, repair related-work positioning, apply open paper patches, distill reusable knowledge, resolve a human decision.

Bad target: "Read more papers." Good target: "Determine whether an existing method already invalidates the novelty of Claim C2."

## Stage 4: Evidence Deepening

For each new source, explain: what it is, what problem it addresses, what method or argument it uses, what it supports in the current paper, what it weakens, what it does not prove, which paper section it affects, whether it should update a literature knowledge card. Never list a source without explaining why it matters.

## Stage 5: Adversarial Critique

Attack the paper as a top-conference reviewer. For each core claim, ask: Is the claim precise? Are assumptions explicit? Is the baseline the strongest available? Does the evidence actually support the claim? Does the evaluation contract match the claim? Could a simpler method achieve the same result? Is the novelty incremental? Would the paper still matter if the strongest claim were weakened?

Every significant critique must be written as a structured critique object.

## Stage 6: Paper Patch Generation

For every medium, high, or fatal critique, generate a paper patch containing: patch id, linked critique, linked claim, severity, affected paper regions, before/after or structural change, evaluation obligation, human judgment requirement, knowledge implication, lifecycle status. If no paper patch is generated for a significant critique, the round is invalid.

## Stage 7: Evaluation Obligation

For every patch affecting a core claim, define how the claim should be evaluated. Specify: target claim, hypothesis, baselines or comparisons, evidence type, method of validation, metrics or success criteria, support condition, refutation condition, paper section to update. Do not invent results. Design the validation.

## Stage 8: Human Judgment Gate

If a decision affects thesis, claim scope, assumptions, baseline, contribution, evaluation priority, or positioning, do not decide silently. Ask one question at a time. Each question must include: exact decision needed, why it matters, evidence found, options with benefit/risk, recommendation, affected paper sections, consequence of no decision.

## Stage 9: Apply or Block Paper Patches

Accepted patches must update `paper-draft.md`, `writing-diff.md`, `claim-paper-matrix.md`, and patch lifecycle. If a patch cannot be applied, mark it as blocked and state: blocker, missing evidence, required human decision, required evaluation, next action. Do not mark a patch as applied unless the paper draft has actually changed.

## Stage 10: Knowledge Distillation

Distill two kinds of knowledge. Literature knowledge: paper cards, method cards, concept cards, debate threads, comparison maps. Thinking knowledge: research principles, writing rules, reviewer patterns, anti-patterns, evaluation patterns. Every knowledge delta must explain what was learned, what triggered it, where it applies, where it does not, and how it should be used in future critique or writing.

## Stage 11: Round Closure

Before claiming completion, ensure: every significant critique has a paper patch, every claim-level patch has an evaluation obligation, every accepted patch changed the paper draft, every human-level decision is resolved or explicitly blocking, knowledge delta exists, paper draft remains complete, next round target is specified. If validation fails, repair artifacts before reporting completion.
