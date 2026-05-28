# Role Lenses

Use these as mental passes inside the same agent by default. Only create actual subagents if the user explicitly asks for parallel agents or delegation.

## Claim Parser

Only decompose the material. Do not research or conclude.

Outputs: problem framing, claim ledger, assumption ledger.

## Research Scout

Only gather and normalize supporting evidence. Do not write the final conclusion.

Outputs: evidence ledger, source notes.

## Counterexample Finder

Search for prior work, baselines, edge cases, and counterexamples.

Outputs: counterexample ledger, baseline map.

## Adversarial Reviewer

Attack the argument like a top-tier CS reviewer.

Outputs: critique ledger, gap backlog.

## Evidence Auditor

Check whether each claim is stronger than the evidence allows.

Outputs: evidence audit, allowed wording, forbidden wording.

## Experiment Mapper

Map claims to evaluation obligations.

Outputs: claim-to-evaluation map, experiment obligations.

## Synthesis Writer

Write only from claims that survived critique and evidence audit.

Outputs: final report, paper-ready or proposal-ready text.

---

## Concurrency Contract (Always Active)

The following Role-Lenses execute as parallel passes in every round:

### Parallel Pass 1: Discovery Lenses

Runnable concurrently:
- **Claim Parser** (decompose claims)
- **Research Scout** (pre-collect baseline information)

Not runnable concurrently: First-Principles Decomposition must execute after Claim Decomposition completes.

### Parallel Pass 2: Validation Lenses

Runnable concurrently:
- **Research Scout** (deep evidence search and normalization)
- **Counterexample Finder** (search for counterexamples and baselines)
- **Adversarial Reviewer** (pre-judgment critique based on draft claims)

Note: Adversarial Reviewer's pre-judgment critiques may need revision after Evidence Normalization; the final Critique Ledger must reflect the post-normalization state.

### Merge Rules

1. **Evidence conflicts**: If Research Scout and Counterexample Finder find contradictory evidence for the same claim, record as `contradicts`, raise the review priority for that claim, do not auto-delete.
2. **Critique overlap**: If Adversarial Reviewer and Counterexample Finder raise the same critique, merge into one entry and annotate with dual sources.
3. **Information loss prohibition**: Raw output from every Lens must be preserved in the Research Trace Appendix, even if it does not enter the Final Report.
4. **Saturation calculation**: Performed centrally by Evidence Auditor after Merge; individual Lenses must not self-declare saturation.
