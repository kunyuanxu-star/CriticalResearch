# Stage 9: Knowledge Delta

# Extract reusable design knowledge.
## Knowledge Loop
Knowledge written to `_cr/knowledge/` during `cr round close` is
mechanically injected into all future rounds via `contract.yaml` →
`read_only_context.global_knowledge_cards`. The model MUST encode
value that survives past this round — patterns, invariants,
failure modes, and design rules that compound over time.



## Outputs
- `knowledge-delta.yaml` — new/revised design decisions, invariants, interface contracts, evaluation obligations, open questions

## Task
Produce `knowledge-delta.yaml`:
- Design decisions: new decisions, revised decisions
- Invariants: new invariants (add to project knowledge)
- Interface contracts: stable interfaces to enforce
- Evaluation obligations: what must be measured to validate the design
- Open questions: unresolved design questions
