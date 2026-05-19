# Grep-Based Check Classification

Analysis of current grep-based validation checks across CriticalResearch validators.
Classified as HARD_GATE (fail=block), SOFT_WARNING (warn only), or OBSOLETE (replaced).

## cr-validate-round

| Check | Classification | Rationale |
|-------|---------------|-----------|
| round.yaml exists | OBSOLETE | Now handled by cr-validate-schema (artifact registry) |
| round status in enum {open, in_progress, complete} | HARD_GATE | Schema validation handles enum, but semantic state check remains |
| Required output files exist (5+ files) | HARD_GATE | Now driven by round.yaml required_outputs |
| File line count > 4 (non-empty) | SOFT_WARNING | Thin files may be valid but indicate shallow work |
| knowledge-delta.md > 20 lines | SOFT_WARNING | Content quality, not binary presence |
| sources.md has evidence fields (title:, source_type:, etc.) | HARD_GATE | Required for evidence traceability |
| sources.md has search_failure fields | SOFT_WARNING | Alternative to evidence; should not block |
| critique.md has critique fields (critique_id:, severity:, etc.) | HARD_GATE | Required for critique traceability |
| At least one medium+ critique or exemption | HARD_GATE | Core quality bar; exemption covers setup rounds |
| All critiques severity=low without exemption | HARD_GATE | Must either have substantive critique or explicit exemption |

## cr-validate-knowledge

| Check | Classification | Rationale |
|-------|---------------|-----------|
| knowledge-delta.md exists | HARD_GATE | Invariant: every round must record learning |
| Literature Knowledge Updated section | HARD_GATE | Required decision (yes/no) |
| Thinking Knowledge Updated section | HARD_GATE | Required decision (yes/no) |
| Candidate Rules Generated section | SOFT_WARNING | May be legitimately absent |
| Project-Local Insights Only section | SOFT_WARNING | May be legitimately absent |
| No-update explanation section | HARD_GATE | Required when no knowledge was updated |
| Line count > 20 | SOFT_WARNING | Content quality indicator |
| Has Yes/No or bullet content | HARD_GATE | Binary check: template not filled vs filled |

## cr-validate-stop

| Check | Classification | Rationale |
|-------|---------------|-----------|
| Active round directory exists | HARD_GATE | Prerequisite for validation |
| Round status is "complete" | HARD_GATE | Round must be explicitly closed |
| Required output files missing | HARD_GATE | Driven by round.yaml required_outputs |
| Knowledge delta missing | HARD_GATE | Block stop if patches exist but no knowledge delta |
| Satisfaction state valid | SOFT_WARNING | Content hash check may be fragile |

## cr-validate-writing

| Check | Classification | Rationale |
|-------|---------------|-----------|
| writing-diff.md exists and non-empty | HARD_GATE | Every round must record writing changes |
| paper-draft.md mtime changed | SOFT_WARNING | Changes may be edits not captured in diff |

## hooks/check-*.sh

| Check | Classification | Rationale |
|-------|---------------|-----------|
| research-trace.md contains thesis/problem/approach | HARD_GATE | Core artifact structure |
| claim-ledger.md has required columns | HARD_GATE | Structured data requirement |
| evidence-ledger.md has required fields | HARD_GATE | Evidence traceability |
| critique-ledger.md has required fields | HARD_GATE | Critique traceability |
| gap-backlog.md has bidirectional links | HARD_GATE | Reference integrity |
| final-report.md has thesis format | HARD_GATE | Output quality gate |
| Story checklist completeness | SOFT_WARNING | Quality indicator, not blocking |
| Logic/story audit issues | SOFT_WARNING | Subjective quality assessment |

## Summary

- HARD_GATE checks: file presence, required field existence, reference integrity, essential content decisions
- SOFT_WARNING checks: content quality, depth, richness, subjective assessments
- OBSOLETE checks: superseded by JSON Schema validation in cr_validate_json_schema
