# ID Namespace and Collision Rules

Structured identifier rules for all CriticalResearch artifact types.

## ID Patterns

| Prefix | Scope | Format | Example | Uniqueness |
|--------|-------|--------|---------|------------|
| `CRT-` | Critique | `CRT-XXX` (3 digits) | `CRT-007` | Per project |
| `PP-` | Paper Patch | `PP-XXX` (3 digits) | `PP-007` | Per project |
| `CLM-` | Claim | `CLM-XXX` (3 digits) | `CLM-004` | Per project |
| `GAP-` | Research Gap | `GAP-XXX` (3 digits) | `GAP-012` | Per project |
| `EXP-` | Experiment Obligation | `EXP-XXX` (3 digits) | `EXP-007` | Per project |
| `RP-` | Research Principle | `RP-XXXX` (4 digits) | `RP-0002` | Per workspace |
| `WR-` | Writing Rule | `WR-XXXX` (4 digits) | `WR-0001` | Per workspace |
| `RV-` | Reviewer Pattern | `RV-XXXX` (4 digits) | `RV-0001` | Per workspace |
| `AP-` | Anti-Pattern | `AP-XXXX` (4 digits) | `AP-0003` | Per workspace |
| `EP-` | Experiment Pattern | `EP-XXXX` (4 digits) | `EP-0001` | Per workspace |
| `DEC-` | Human Decision | `DEC-XXX` (3 digits) | `DEC-012` | Per project |
| `LIT-` | Literature Card | `LIT-XXX` (3 digits) | `LIT-005` | Per workspace |
| `TK-` | Thinking Knowledge Candidate | `TK-XXX` (3 digits) | `TK-012` | Per workspace |

## Uniqueness Scopes

- **Per project**: IDs must be unique within `research-X/`. Two different projects can both have `CRT-007`.
- **Per workspace**: IDs must be unique within `Research/_cr/knowledge/`. Cross-project knowledge cards share a single namespace.

## Collision Rules

1. **ID assignment**: Sequential numbering within each prefix scope. New items get `max(existing) + 1`.
2. **ID reuse**: Never reuse IDs, even after deletion. Deleted/superseded items keep their IDs with terminal status.
3. **Cross-references**: Use `prefix-ID` format in all references. Example: `linked_critique: CRT-007`, `superseded_by: PP-012`.
4. **Validation**: `cr-validate-ids` checks for duplicates within scope, malformed patterns, and dangling references.

## File Naming Convention

- Paper patches: `patches/PP-XXX.yaml` (3 digits, zero-padded)
- Experiment obligations: `experiments/EXP-XXX.yaml` (3 digits, zero-padded)
- Thinking cards: `cards/RP-XXXX-slug.md` (4 digits + kebab-case slug)
- Literature cards: `papers/<citation-key>.md`, `systems/<system-id>.md`, etc.

## Transition from Legacy

Current critique and gap IDs in existing projects follow these rules already. The plan adds PP-, EXP-, RP-, WR-, RV-, AP-, EP- prefixes.
