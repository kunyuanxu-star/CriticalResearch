# Research Brief ID Namespace

Use compact identifiers only inside `research.md`. Do not create separate
identifier registries by default.

## ID Patterns

| Prefix | Scope | Format | Example | Uniqueness |
|--------|-------|--------|---------|------------|
| `A` | Reviewer attack | `A<number>` | `A1` | Per run |
| `C` | Scope challenge | `C<number>` | `C1` | Per run |
| `E` | Evidence item, when needed | `E<number>` | `E1` | Per run |
| `B` | External blocker or gate | `B<number>` | `B1` | Per run |

## Rules

1. IDs reset for each `run-XXX`.
2. IDs are human-readable anchors, not global database keys.
3. Use only IDs that are referenced in the same `research.md`.
4. Prefer field names over IDs when a direct field reference is clearer.
5. Do not create sidecar ID registries unless the user explicitly asks for a
   larger evidence archive.

## Examples

```markdown
### Attack A1
- Role: skeptical_reviewer
- Field: proof_plan
- Type: baseline_missing
- Severity: blocking
- Scope: proof_blocking
- Argument: The metric is named but the baseline is unspecified.
- Required repair: Add at least one baseline and a decision rule.
- Disposition: repaired
```
