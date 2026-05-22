# /critical-cs-research

The user argument is the primary focus of a mandatory full-paper CriticalResearch round.

**You must not answer with advice only. You must execute a complete 37-phase paper transaction.**

## Mandatory Execution Semantics

1. Treat the user argument as a round objective, not as a normal question.
2. Create or resume the active paper round for the current project.
3. Write the user argument into `round-objective.yaml` with `scope_policy.type = full_paper_required` and `objective_may_limit_scope = false`.
4. Ensure `execution_policy.full_round_required = true`, `full_paper_required = true`, `allow_partial_stop = false`.
5. Generate `full-paper-coverage-plan.yaml` with complete paper inventory.
6. Execute every phase in `state.yaml.phase_order`, from the current phase to `close_round`.
7. For every phase:
   - Load the phase prompt from `prompts/phases/<phase>.md`.
   - Read all `required_inputs`.
   - Generate all `required_outputs` with substantive content (not placeholders).
   - Cover the full paper — check every section, claim, assumption, baseline, evaluation item.
   - Emphasize the user objective — give extra scrutiny to objective-related items.
   - Write `full_paper_coverage` and `objective_relevance` in every output artifact.
   - Run phase validators via `cr step <project> validate`.
   - If validators fail: repair the outputs and retry. Do NOT advance past a failing phase.
   - Run `cr step <project> advance` only after validation passes.
8. Do not skip phases. Every phase in `phase_order` must be executed.
9. Do not narrow the workflow to the user objective. The objective is a weighting lens, not a scope limiter.
10. Do not stop until `cr close-round <project>` succeeds, unless:
    - A human-decision blocker is recorded in `human-review-queue.yaml`, OR
    - An unrecoverable tool error occurs and is recorded in `unrecoverable-error.yaml`.

## Phase Execution Checklist

For each phase, verify before advancing:
- [ ] Phase prompt loaded and understood
- [ ] All required_inputs read
- [ ] All required_outputs generated with substantive content
- [ ] `full_paper_coverage` recorded (sections, claims, assumptions, baselines, evaluations checked)
- [ ] `objective_relevance` recorded (level, explanation, objective-specific findings)
- [ ] `cr step <project> validate` passes
- [ ] Any validator failures repaired before advance

## Completion Response

Only after close-round succeeds, respond with:
- Round ID and workflow mode
- User objective (from round-objective.yaml)
- 37/37 phase completion status
- Full-paper coverage summary (sections, claims, baselines, evaluations covered)
- Key critiques generated (count by severity)
- Patches applied or blocked
- Experiment obligations generated
- Knowledge deltas applied
- Remaining risks and next-round targets
- Any non-focus high-risk items discovered during full-paper pass

## Important

The user objective is a weighting lens, not a scope limiter.

Every phase must cover the full paper, not only the objective-related parts.

If a phase seems unrelated to the objective, execute it anyway — the objective changes only what you emphasize, never what you skip.
