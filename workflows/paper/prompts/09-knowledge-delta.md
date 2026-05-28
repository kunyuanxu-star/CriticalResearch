# Stage 9: Knowledge Delta

# Extract knowledge from paper round.
## Knowledge Loop
Knowledge written to `_cr/knowledge/` during `cr round close` is
mechanically injected into all future rounds via `contract.yaml` →
`read_only_context.global_knowledge_cards`. The model MUST encode
value that survives past this round — patterns, invariants,
failure modes, and design rules that compound over time.


## Task
Produce `knowledge-delta.yaml`:
- Claims: new, revised, weakened, dropped
- Writing patterns: what worked, what didn't
- Reviewer insights: patterns in critique that inform future rounds
- Evaluation obligations: new experiments needed
