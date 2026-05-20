---
card_id: WR-0001
card_type: writing_rule
title: Root Cause Before Mechanism
status: candidate
rule: "A systems paper should establish the root cause of existing failures before introducing the proposed mechanism."
why_this_matters: "Readers reject papers that present mechanisms without first understanding why existing approaches fail. The mechanism should appear as a consequence of the problem, not an arbitrary artifact."
learned_from: []
how_to_apply:
  - "Identify the shared assumption that causes existing systems to fail."
  - "Explain why this assumption cannot be removed within existing designs."
  - "Show that the proposed mechanism directly addresses this root cause."
  - "Place the mechanism description after the root cause analysis, not before."
failure_mode: "Do not over-rotate on root cause analysis when the contribution is primarily empirical or observational. Not all systems papers require deep causal chains."
applies_to: ["systems design papers", "architecture proposals", "isolation mechanisms"]
does_not_apply_to: ["measurement papers", "empirical surveys", "benchmark proposals"]
linked_cards: ["RP-0002", "WR-0003"]
usage_history: []
promotion_history: []
created_at: ""
updated_at: ""
---
# WR-0001: Root Cause Before Mechanism

## Rule

A systems paper should establish the root cause of existing failures before introducing the proposed mechanism.

## Bad Pattern

"To solve the problem, we build FrameVisor with virtualized OSTD objects."

## Better Pattern

"Existing systems choose between virtual hardware boundaries and shared-kernel state partitioning. This choice becomes limiting when the object to isolate is an alternative OS service implementation rather than an application process. FrameVM addresses this by raising the guest boundary from virtual hardware to typed OS abstractions."

## Why It Works

The reader first understands why the design is necessary. The mechanism then appears as a consequence of the problem, not as an arbitrary artifact.

## Use in Critique

Flag an Introduction if it starts with mechanism before contradiction, lists components before root cause, or claims novelty before explaining why existing approaches fail.
