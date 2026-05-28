# Knowledge Discipline

This is a shared discipline document referenced by stage prompts across all workflows. It defines the rules for extracting, structuring, and persisting reusable knowledge from each round — ensuring knowledge compounds across rounds rather than being lost.

## Core Principle

Every round MUST produce a knowledge delta. The delta captures what was learned during the round that should inform future rounds: patterns, rules, failure modes, conventions, and insights that are independent of the specific document state.

Knowledge that is not persisted is knowledge that will be re-learned (or re-missed) in the next round.

## What Belongs in Knowledge Cards

### Belongs (write a card)
- **Claim patterns**: "Claims about tail latency require p99+ measurements, not averages"
- **Reviewer patterns**: "SOSP reviewers consistently attack evaluation sections that lack sensitivity analysis"
- **Evidence rules**: "Security claims without a threat model are automatically rejected by IEEE S&P reviewers"
- **Writing conventions**: "Top-venue introductions follow problem→root cause→insight→approach structure"
- **Failure modes**: "Survey papers that compare by feature matrix without qualitative analysis are desk-rejected"
- **Design invariants**: "Every system optimization must state what it trades off (performance for complexity, etc.)"
- **Methodology rules**: "Ablation studies must isolate one variable at a time; changing two variables invalidates the causal claim"

### Does NOT Belong (do not write a card)
- **Round-specific state**: "Round 3 weakened claim C-7" — this is round history, not reusable knowledge
- **Document content**: "The introduction now starts with a workload characterization" — this is document state
- **Trivial observations**: "The paper has 6 sections" — no compounding value
- **Vague generalizations**: "Writing matters" — not actionable
- **Duplicate knowledge**: A card with the same insight already exists — update the existing card's maturity instead

## Card Structure

Each knowledge card MUST have:
- **Card ID**: unique identifier
- **Claim**: the knowledge in one sentence — a rule, pattern, or constraint
- **Domain**: the CS sub-area(s) it applies to
- **Maturity**: `emerging` (1 round), `stable` (2-3 rounds), `proven` (4+ rounds)
- **Source**: which round(s) produced this knowledge
- **Evidence**: what in the round supports this claim (critique, reviewer feedback, validation failure)
- **Constraints**: when the rule applies vs. when it doesn't

## Maturity Lifecycle

| Maturity | Rounds | Behavior |
|----------|--------|----------|
| `emerging` | 1 | Loaded as advisory — may be challenged |
| `stable` | 2-3 | Loaded as strong guidance — challenge requires explicit justification |
| `proven` | 4+ | Loaded as binding constraint — must be applied |

## Extraction Rules

When producing `knowledge-delta.yaml`:

1. Review every critique that was accepted or disputed — what rule would have caught this earlier?
2. Review every patch that was applied — what pattern does it exemplify?
3. Review every validation failure — what invariant was violated?
4. Review reviewer feedback (if any) — what expectation was not met?
5. For each candidate insight, ask: "Will this help in the next round?" If no, discard.

## No-Delta Justification

If no knowledge was gained (trivial round, no new insights), produce an explicit no-delta justification explaining why. "Nothing learned" is not sufficient — explain what was attempted and why it produced no transferable knowledge.

## Knowledge Loading

At round start, knowledge cards referenced in `contract.yaml` → `read_only_context.global_knowledge_cards` are loaded. Cards with `maturity: proven` are binding constraints — the round must respect them. Cards with lower maturity are advisory — they may be challenged or refined based on new evidence.
