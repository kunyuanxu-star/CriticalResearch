# Universal Paper-Centered Research Round (8-Stage)

A round is not a literature summary. A round is a controlled transformation of the current paper.

## Stage 1: Round Contract

Before doing new work, reconstruct the paper state and formalize the round contract:

- current thesis
- research object and problem setting
- target property
- core claims and key assumptions
- strongest baseline or competing explanation
- current evaluation contract
- most fragile claim
- most damaging open critique
- paper section most at risk

Write `round-contract.yaml` with target, scope, intensity, required outputs, forbidden scope, and success criteria. No research may proceed without a signed contract.

## Stage 2: Evidence Grounding

Classify the project into one or more areas: systems, networking, security, PL, databases, architecture, ML/AI, SE, HCI, visualization, graphics, robotics, algorithms/theory, interdisciplinary CS.

Choose the appropriate evaluation contract (see `references/evaluation-contracts.md`). Do not force a systems-style evaluation onto non-systems papers.

Plan research questions. Execute retrieval. Triage, ingest, and read sources. Normalize evidence into `evidence-ledger.yaml` with categories (supporting, weakening, baseline, writing_reference, terminology). Build `claim-evidence-map.yaml`.

**At least one evidence item must have category `weakening`.**

For each new source, explain: what it is, what problem it addresses, what method or argument it uses, what it supports in the current paper, what it weakens, what it does not prove, which paper section it affects, whether it should update a literature knowledge card. Never list a source without explaining why it matters.

## Stage 3: Critical Review

Attack the paper as a top-conference reviewer. For each core claim, ask: Is the claim precise? Are assumptions explicit? Is the baseline the strongest available? Does the evidence actually support the claim? Does the evaluation contract match the claim? Could a simpler method achieve the same result? Is the novelty incremental? Would the paper still matter if the strongest claim were weakened?

Every significant critique must be written as a structured critique object in `critique-ledger.yaml`. Every critique must be grounded in evidence, paper text, domain convention, or venue standard.

Produce `review-disposition.yaml` with per-critique disposition and required_action.

## Stage 4: Revision Strategy

For every accepted critique, generate a revision decision in `revision-plan.yaml`. Classify each revision as claim-level, structure-level, or evidence-level. Resolve human judgment gates for thesis-level changes.

If a decision affects thesis, claim scope, assumptions, baseline, contribution, evaluation priority, or positioning, do not decide silently. Ask one question at a time. Each question must include: exact decision needed, why it matters, evidence found, options with benefit/risk, recommendation, affected paper sections, consequence of no decision.

## Stage 5: Writing Strategy

Transform revision decisions into a concrete writing strategy with three levels:

- **High level**: argument order (setup → problem → method → result → implication → limitation)
- **Paragraph level**: rhetorical function per paragraph (claim, evidence, contrast, cause, result, transition, qualification, example)
- **Sentence level**: function per sentence (claim, contrast, cause, result, evidence, qualification, definition)

Produce `patch-plan.yaml` mapping each revision to a concrete writing pattern.

## Stage 6: Paper Patch

Apply patches to `paper-draft.md` according to the patch plan. Record every change in `writing-diff.yaml` with before/after text, section_anchor, and patch_id. Produce `patch-trace.yaml` for full traceability: patch_id → critique_id → revision_decision → writing_pattern → status.

Accepted patches must update `paper-draft.md`, `writing-diff.yaml`, and patch lifecycle. If a patch cannot be applied, mark it as blocked and state: blocker, missing evidence, required human decision, required evaluation, next action. Do not mark a patch as applied unless the paper draft has actually changed.

For every patch affecting a core claim, define an experiment obligation in `experiment-obligations.yaml`: target claim, hypothesis, baselines, evidence type, validation method, metrics, success criteria. Do not invent results.

## Stage 7: Knowledge Consolidation

Distill two kinds of knowledge. Literature knowledge: paper cards, method cards, concept cards, debate threads, comparison maps. Thinking knowledge: research principles, writing rules, reviewer patterns, anti-patterns, evaluation patterns.

Write `knowledge-delta.yaml` with typed updates. Write knowledge cards to `_cr/knowledge/cards/research/`, `_cr/knowledge/cards/writing/`, `_cr/knowledge/cards/review/` with maturity tracking (candidate→used→validated→canonical).

Record `knowledge-apply-log.yaml` with before/after sha256 hashes.

## Stage 8: Round Closure

Before claiming completion, ensure: every significant critique has a paper patch, every claim-level patch has an evaluation obligation, every accepted patch changed the paper draft, every human-level decision is resolved or explicitly blocking, knowledge delta exists, paper draft remains complete, next round target is specified.

Run the full validator pipeline. If validation fails, repair artifacts before reporting completion.

Produce `next-round-targets.yaml` with exactly 3 structured next-round options with rationale. Produce `round-summary.yaml` with summary and remaining risks.

The round must be a gateway, not a wall.
