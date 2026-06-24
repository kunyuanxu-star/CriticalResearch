# Validator Check Classification

Classification for `cr validate` checks over `research.md`.

## Hard Errors

| Check | Classification | Rationale |
|-------|---------------|-----------|
| Missing YAML frontmatter | HARD_GATE | The CLI cannot read run state. |
| Invalid schema, status, phase, mode, weakest link, or gate | HARD_GATE | State must be machine-readable. |
| Run id mismatch | HARD_GATE | A run file must match its directory. |
| Missing required heading | HARD_GATE | The brief contract is incomplete. |
| Missing thesis claim | HARD_GATE | The current thesis is undefined. |
| Missing Basic System setting, object, or goal | HARD_GATE | The research scene is under-specified. |
| Missing Core Contradiction need, but, or therefore | HARD_GATE | The problem has no explicit tension. |
| Fewer than two strawmen or missing failure modes | HARD_GATE | The root cause cannot be justified. |
| Missing shared root cause or key insight | HARD_GATE | The brief has no causal leverage. |
| Missing metric, baseline, minimum experiment, or decision rule | HARD_GATE | The proof plan is not executable. |
| Missing known, assumed, or unknown evidence boundary | HARD_GATE | Evidence status is unclear. |
| Missing next experiment action or decision rule | HARD_GATE | The brief cannot drive the next step. |

## Warnings

| Check | Classification | Rationale |
|-------|---------------|-----------|
| Feature-demand-shaped contradiction | SOFT_WARNING | It may still be valid, but needs scrutiny. |
| Root cause restates the failure | SOFT_WARNING | The causal explanation may be shallow. |
| Solution-shaped insight | SOFT_WARNING | The key idea may be a technique name, not causal leverage. |
| Missing thesis-breaking unknown | SOFT_WARNING | The evidence boundary may be too optimistic. |
| Broad next action | SOFT_WARNING | The next action may not be minimum. |

## Summary

- Hard errors make `cr validate` exit `2`.
- Warnings make `cr validate` exit `1`.
- `--strict` escalates warnings to errors.
- Terminal states may pass with allowed gaps only when the validator's explicit
  terminal allowance conditions are met.
