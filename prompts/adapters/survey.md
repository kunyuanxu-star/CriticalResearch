# Document Adapter: Survey

Overlay for literature survey or taxonomy documents.

## S1: Round Contract
- Review criteria: coverage completeness, taxonomy soundness, comparison fairness
- Writing quality checks: clarity for non-experts, balanced treatment
- Required coverage: all topic areas, systems/methods compared, gaps identified
- Artifact: survey-state.yaml (frozen snapshot of coverage map, taxonomy, gaps)

## S2: Evidence Grounding
- Source quality: peer-reviewed venues, authoritative texts, reproducible systems
- Minimum sources: 8 (5 for survey depth)
- Evidence categories: supporting, weakening, neutral
- Topic-evidence map must cover all stated topics

## S3: Critical Review
- Five critique passes: coverage precision, taxonomy coherence, evidence sufficiency, comparison fairness, writing/argument
- Medium+ critiques require evidence_refs
- High/fatal critiques must have must_create_patch=true
- Comprehensive coverage standards apply

## S4: Revision Strategy
- Revisions must trace to critique IDs
- Full-survey coverage required
- No-op allowed with justification

## S5: Writing Strategy
- Three-level strategy: taxonomy order, section plans, paragraph patterns
- Must reference target document structure

## S6: Document Patch
- Patches apply to documents/survey.md
- Writing diff records all changes
- Patch trace links to critique and revision

## S7: Knowledge Consolidation
- Distill into global knowledge cards
- Update coverage ledger
- Record knowledge deltas

## S8: Round Closure
- Next-round targets must be concrete and scoped
- Round summary covers document changes and open gaps
- Knowledge writeback required

## Validation Rules
- Round contract must have target >= 10 chars
- Evidence ledger must have >= 5 sources reviewed
- Critique ledger must have >= 1 critique
- Revision plan must have >= 1 revision
- Writing plan must have argument_order >= 1
- Next-round targets must have >= 1 candidate
- Closure report must have summary and remaining risks
