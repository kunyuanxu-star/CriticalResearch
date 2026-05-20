---
card_id: WR-0001
card_type: writing_rule
title: Root Cause Before Mechanism
status: candidate
rule: "A paper should establish the root cause of existing failures before introducing the proposed mechanism."
why_this_matters: "Readers reject papers that present mechanisms without first understanding why existing approaches fail. The mechanism should appear as a consequence of the problem, not an arbitrary artifact."
learned_from: []
how_to_apply:
  - "Identify the shared assumption or limitation that causes existing approaches to fall short."
  - "Explain why this limitation cannot be removed within existing designs."
  - "Show that the proposed contribution directly addresses this root cause."
  - "Place the method description after the root cause analysis, not before."
failure_mode: "Do not over-rotate on root cause analysis when the contribution is primarily empirical or observational."
applies_to: ["all computer science areas"]
does_not_apply_to: ["measurement papers", "empirical surveys", "benchmark proposals"]
linked_cards: ["RP-0002", "WR-0003"]
usage_history: []
promotion_history: []
created_at: ""
updated_at: ""
---
# WR-0001: Root Cause Before Mechanism

## Rule

A paper should establish the root cause of existing failures before introducing the proposed mechanism.

## Bad Pattern

"To solve the problem, we built System X with novel feature Y."

## Better Pattern

"Existing approaches make assumption A, which limits their ability to handle case C. This assumption cannot be removed within those designs because of constraint K. Our approach addresses this by relaxing assumption A through technique T, enabling case C to be handled efficiently."

## Why It Works

The reader first understands why the contribution is necessary. The method then appears as a consequence of the problem, not as an arbitrary artifact.

## Use in Critique

Flag a paper's introduction if it starts with the method before establishing the gap, lists components before root cause, or claims novelty before explaining why existing approaches fail.
