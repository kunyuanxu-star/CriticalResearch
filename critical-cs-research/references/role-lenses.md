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
