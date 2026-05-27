# Document Adapter: Proposal

Overlay for research or project proposal documents.

## S1: Round Contract
- Review criteria: problem clarity, scope realism, milestone feasibility
- Writing quality checks: stakeholder-appropriate language, persuasive structure
- Required coverage: problem statement, goals, scope, milestones, risks
- Artifact: proposal-state.yaml (frozen snapshot of goals, scope, assumptions, risks)

## S2: Evidence Grounding
- Source quality: market research, prior art, feasibility studies
- Minimum sources: 3
- Evidence categories: supporting, weakening, neutral
- Goal-evidence map must cover all stated goals

## S3: Critical Review
- Five critique passes: goal precision, novelty/feasibility, evidence sufficiency, resource/evaluation contract, writing/argument
- Medium+ critiques require evidence_refs
- High/fatal critiques must have must_create_patch=true
- Stakeholder readability standards apply

## S4: Revision Strategy
- Revisions must trace to critique IDs
- Full-proposal coverage required
- No-op allowed with justification

## S5: Writing Strategy
- Three-level strategy: argument order, section plans, paragraph patterns
- Must reference target document structure

## S6: Document Patch
- Patches apply to documents/proposal.md
- Writing diff records all changes
- Patch trace links to critique and revision
- Resource obligations for goal-level patches

## S7: Knowledge Consolidation
- Distill into global knowledge cards
- Update goal ledger
- Record knowledge deltas

## S8: Round Closure
- Next-round targets must be concrete and scoped
- Round summary covers document changes and open risks
- Knowledge writeback required

## Validation Rules
- Round contract must have problem_statement substantive
- Success criteria must have >= 1 item
- Evidence ledger must have >= 1 item
- Critique ledger must have >= 1 critique
- Revision plan must have >= 1 revision
- Writing plan must have argument_order >= 1
- Next-round targets must have >= 1 candidate
- Milestones must have >= 3 items
- Closure report must have summary and remaining risks
