# Draft Anchor Model

Section identifiers for paper patch targeting. Patches reference these anchors to declare which parts of the paper draft they affect.

## Anchor Identifiers

| Anchor | Paper Section | Description |
|--------|--------------|-------------|
| `abstract` | Abstract | One-paragraph summary of the paper |
| `introduction` | Introduction | Problem statement, motivation, contribution summary |
| `background` | Background | Necessary technical context and definitions |
| `motivation` | Motivation | Detailed argument for why existing approaches are insufficient |
| `design` | Design | System architecture, mechanisms, and design rationale |
| `implementation` | Implementation Plan | How the design would be realized |
| `evaluation_plan` | Evaluation Plan | Experiment design, baselines, metrics, workloads |
| `related_work` | Related Work | Comparison with prior and concurrent work |
| `discussion` | Discussion | Limitations, future work, alternative interpretations |
| `conclusion` | Conclusion | Summary of contributions and impact |

## Anchor Reference Format

In `paper-draft.md`, anchors are declared as HTML comments:

```markdown
<!-- anchor: introduction -->
## Introduction

Current text here...
```

Patches reference these anchors in their `affected_anchors` field. Validators check that patch anchors resolve to existing section anchors in the paper draft.

## Multiple Paragraph Anchors

For finer-grained targeting, numeric suffixes are allowed:

```markdown
<!-- anchor: introduction.p1 -->
<!-- anchor: introduction.p2 -->
<!-- anchor: design.4.1 -->
```

The base anchor (e.g., `introduction`) matches all sub-anchors. A patch targeting `introduction` affects the entire section. A patch targeting `introduction.p2` affects only that paragraph.

## Validation Rules

1. Patch `affected_anchors` entries must match known anchor identifiers
2. Applied patches must have all anchors present in current paper-draft.md (cr-validate-anchors)
3. Proposed patches may reference anchors not yet created (soft warning)
4. Dangling patch with anchors absent from draft blocks (hard gate)
