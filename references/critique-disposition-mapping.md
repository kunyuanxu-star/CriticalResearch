# Critique to Disposition Mapping

Analysis of how the 13 existing critique types map to the 6 disposition types.

## Disposition Types

| Disposition | Meaning | Produces |
|---|---|---|
| `paper_patch` | Draft change needed | PP-XXX patch file |
| `experiment_obligation` | Experiment needed to resolve | EXP-XXX obligation file |
| `claim_deleted` | Claim removed entirely | Updated claim ledger |
| `deferred` | Postponed to future round | Gap stays open |
| `rejected_with_reason` | Critique considered but dismissed | Justification recorded |
| `no_op` | Already addressed, no action | Justification recorded |

## Mapping by Critique Type

| Critique Type | Primary Disposition | Secondary | Rationale |
|---|---|---|---|
| `overclaim` | `paper_patch` | `claim_deleted` | Weaken or remove the overclaim. If claim is indefensible, delete. |
| `missing_baseline` | `experiment_obligation` | `deferred` | Must design experiment against strongest baseline. Defer if resources unavailable. |
| `missing_workload` | `experiment_obligation` | `deferred` | Must find or design representative workload. |
| `ambiguous_definition` | `paper_patch` | `no_op` | Clarify terminology in paper. If already clear in context, no_op. |
| `weak_causality` | `paper_patch` | `experiment_obligation` | Rewrite causal argument in motivation/introduction. May need experiment if causal claim is core. |
| `alternative_solution` | `paper_patch` | `rejected_with_reason` | Add to related work discussion. If solution is not actually comparable, reject with reason. |
| `unproven_generality` | `paper_patch` | `claim_deleted` | Narrow claim scope in paper. Delete unprovable general claims. |
| `evaluation_gap` | `experiment_obligation` | `paper_patch` | Design missing evaluation. If evaluation is impossible, change claims to match what can be evaluated. |
| `artifact_gap` | `deferred` | `paper_patch` | Implementation not yet available. Defer or note as limitation. |
| `methodology_flaw` | `experiment_obligation` | `paper_patch` | Redesign experiment with corrected methodology. Update evaluation plan section. |
| `dependency_break` | `paper_patch` | `claim_deleted` | Fix logical chain in design/argument sections. If dependency cannot be resolved, delete dependent claims. |
| `missing_tradeoff` | `paper_patch` | `no_op` | Add tradeoff discussion. If tradeoff is obvious, no_op with justification. |
| `circular_reasoning` | `paper_patch` | `claim_deleted` | Restructure argument to break circularity. If restructuring fails, delete circular claim. |

## Decision Heuristics

1. **Fatal severity + core claim** → `claim_deleted` or `paper_patch` with major rewrite
2. **High severity + evidence gap** → `experiment_obligation` + `paper_patch`
3. **Medium severity + wording** → `paper_patch` with before/after
4. **Critique already addressed by prior patch** → `no_op` with cross-reference
5. **Critique valid but out of current scope** → `deferred` with revisit condition
6. **Critique invalid or based on misunderstanding** → `rejected_with_reason`
