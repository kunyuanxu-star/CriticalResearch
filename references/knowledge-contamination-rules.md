# Knowledge Contamination Prevention

Rules to prevent the knowledge banks from accumulating hallucinated, overgeneralized, or project-specific rules.

## Deduplication Rules

1. **Same rule, different wording**: Before creating a new card, search existing cards by card_type. If the rule is semantically identical to an existing card, do not create a duplicate — add usage history to the existing card instead.
2. **Subset rule**: If the new candidate is a special case of an existing rule, add it as a linked sub-card or usage note rather than a separate card.
3. **Superset rule**: If the new candidate generalizes an existing rule, deprecate the narrow rule with `superseded_by` pointing to the new broader rule.
4. **Matching heuristic**: Cards with the same card_type and overlapping `applies_to` domains are candidates for deduplication.

## Deprecation Triggers

A card should be deprecated when:
1. **Contradictory evidence**: A later paper, experiment, or reviewer decision directly contradicts the rule.
2. **Overgeneralization discovered**: The rule was applied in a context where it caused harm (recorded in `failure_mode` or usage history).
3. **Superseded**: A broader or more precise rule replaces it.
4. **Domain shift**: The research domain that motivated the rule is no longer relevant to active projects.

Deprecation requires:
- `deprecation_reason` explaining why
- `contradicted_by` with specific evidence (paper, critique, experiment result)
- Status set to `deprecated` (not deleted — deprecated cards remain as negative examples)

## Generalization Safeguards

Rules should NOT be promoted past `used` unless:
1. **Multiple independent sources**: At least 2 different critique/decision/patch sources, not multiple rounds of the same project applying the same rule.
2. **Cross-project validation**: Preference for rules validated in different research domains (e.g., OS isolation AND database systems).
3. **No recorded counterexample**: No usage history entry describes a case where the rule was misleading.

## Project-Local vs Reusable

Criteria for classifying knowledge as `project_local` vs `candidate_reusable`:

| Factor | project_local | candidate_reusable |
|--------|--------------|-------------------|
| Domain specificity | Tightly coupled to one project's claims | Generalizable across projects in the same area |
| Abstraction level | Concrete findings about specific systems | Abstract patterns applicable to multiple systems |
| Cross-project evidence | No evidence outside current project | Can be tested against other projects' claims |
| Reviewer generality | Specific to one venue or reviewer culture | Common across multiple venues and reviewer communities |

## Anti-Patterns to Reject

Knowledge cards that exhibit these should be rejected or marked `candidate` with a warning:
1. **Vague advice**: Rules without specific, actionable steps (e.g., "write better introductions")
2. **Single-source rules**: Rules derived from exactly one critique with no wider applicability
3. **Opinion without evidence**: Rules that read like personal preference, not backed by reviewer feedback or paper outcomes
4. **Overfitted patterns**: Rules that only apply to the exact claim structure of one project
