# Document Adapter: Paper

Overlay for academic/research paper documents.

## S1: Round Contract
- Review criteria: SOSP/OSDI-level systems conference standards
- Writing quality checks: argument coherence, venue-appropriate rhetoric
- Required coverage: all sections, claims, baselines, evaluation contract
- Artifact: paper-state.yaml (frozen snapshot of claims, baselines, assumptions, risks)

## S2: Evidence Grounding
- Source quality: peer-reviewed venues, reproducible artifacts
- Minimum sources: 5 (2 S/A-level)
- Evidence categories: supporting, weakening, neutral
- Claim-evidence map must cover all core claims

## S3: Critical Review
- Five critique passes: claim precision, novelty/baselines, evidence sufficiency, evaluation contract, writing/argument
- Medium+ critiques require evidence_refs
- High/fatal critiques must have must_create_patch=true
- Venue standards apply

## S4: Revision Strategy
- Revisions must trace to critique IDs
- Full-paper coverage required
- No-op allowed with justification

## S5: Writing Strategy
- Three-level strategy: argument order, section plans, paragraph patterns
- Must reference target document structure

## S6: Document Patch
- Patches apply to documents/paper.md
- Writing diff records all changes
- Patch trace links to critique and revision
- Experiment obligations for claim-level patches

## S7: Knowledge Consolidation
- Distill into global knowledge cards
- Update claim ledger
- Record knowledge deltas

## S8: Round Closure
- Next-round targets must be concrete and scoped
- Round summary covers document changes and open risks
- Knowledge writeback required

## Validation Rules
- Round contract must have target >= 10 chars
- Evidence ledger must have >= 1 weakening item
- Critique ledger must have >= 1 critique
- Revision plan must have >= 1 revision
- Writing plan must have argument_order >= 1
- Next-round targets must have >= 1 candidate
- Closure report must have summary and remaining risks
