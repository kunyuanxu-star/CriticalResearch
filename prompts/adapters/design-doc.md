# Document Adapter: Design Document

Overlay for system or software design documents.

## S1: Round Contract
- Review criteria: abstraction clarity, interface completeness, invariant soundness, failure-model coverage
- Writing quality checks: precision for implementers, traceability to requirements
- Required coverage: all components, interfaces, invariants, failure models
- Artifact: design-state.yaml (frozen snapshot of components, interfaces, invariants, risks)

## S2: Evidence Grounding
- Source quality: design patterns, prior systems, benchmarks, specifications
- Minimum sources: 3
- Evidence categories: supporting, weakening, neutral
- Component-evidence map must cover all core components

## S3: Critical Review
- Five critique passes: abstraction precision, interface completeness, invariant soundness, failure-model coverage, writing/argument
- Medium+ critiques require evidence_refs
- High/fatal critiques must have must_create_patch=true
- Implementation-readiness standards apply

## S4: Revision Strategy
- Revisions must trace to critique IDs
- Full-design coverage required
- No-op allowed with justification

## S5: Writing Strategy
- Three-level strategy: architecture order, section plans, paragraph patterns
- Must reference target document structure

## S6: Document Patch
- Patches apply to documents/design-doc.md
- Writing diff records all changes
- Patch trace links to critique and revision
- Test obligations for invariant-level patches

## S7: Knowledge Consolidation
- Distill into global knowledge cards
- Update design-decisions ledger
- Record knowledge deltas

## S8: Round Closure
- Next-round targets must be concrete and scoped
- Round summary covers document changes and open risks
- Knowledge writeback required

## Validation Rules
- Round contract must have target >= 10 chars
- Evidence ledger must have >= 1 item
- Critique ledger must have >= 1 critique
- Revision plan must have >= 1 revision
- Writing plan must have argument_order >= 1
- Next-round targets must have >= 1 candidate
- Closure report must have summary and remaining risks
