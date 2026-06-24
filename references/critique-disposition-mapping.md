# Attack Disposition Mapping

Reviewer attacks are recorded inside `## Reviewer Attacks` in `research.md`.
Each attack should end with one disposition that explains how the brief handled
it.

## Disposition Types

| Disposition | Meaning | Produces |
|---|---|---|
| `repaired` | The brief was changed to address the attack | Updated field in `research.md` |
| `accepted_risk` | The attack is valid but acceptable for the current brief | Evidence Boundary or Weakest Link note |
| `deferred` | The attack should be handled after the next minimum experiment | Next Minimum Experiment note |
| `challenged` | The attack is based on a false premise or overreach | Scope explanation |
| `out_of_scope` | The attack exceeds the objective | Evidence Boundary out-of-scope entry |
| `gated` | The attack requires external evidence or access | `status: gated` or gate note |

## Mapping by Attack Type

| Attack Type | Primary Disposition | Secondary | Rationale |
|---|---|---|---|
| `baseline_missing` | `repaired` | `deferred` | Add a concrete baseline, or make the next action a baseline selection task. |
| `metric_missing` | `repaired` | `gated` | Add an operational metric, or gate on unavailable measurement access. |
| `fake_contradiction` | `repaired` | `challenged` | Rewrite feature demand into a structural tension, or justify why the tension is real. |
| `solution_not_insight` | `repaired` | `accepted_risk` | Replace solution naming with causal leverage, or mark the insight as provisional. |
| `mechanism_gap` | `repaired` | `deferred` | Add mechanism detail, or make the next experiment resolve the mechanism. |
| `external_gate` | `gated` | `deferred` | Stop the loop if meaningful repair needs data, compute, literature, or implementation. |
| `scope_creep` | `out_of_scope` | `challenged` | Do not let adjacent asks block an actionable brief. |
| `writing_gap` | `repaired` | `accepted_risk` | Tighten thesis flow when it affects comprehension; do not loop only for polish. |

## Decision Heuristics

1. `blocking` + `thesis_breaking` must be repaired, blocked, or gated.
2. `blocking` + `proof_blocking` must be repaired unless the loop budget is exhausted.
3. `major` + `in_scope` should be repaired while budget remains.
4. `minor`, `adjacent`, and `out_of_scope` attacks do not justify another loop by themselves.
5. Duplicate attacks should be merged instead of restated.
