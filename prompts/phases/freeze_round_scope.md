# Phase: freeze_round_scope

## Mission
Lock the scope boundary for this round. Every in-scope claim and section must be traceable to paper-state. Every forbidden change must be explicit. Out-of-scope items must be listed to prevent scope creep.

## Inputs
- `round-risk.yaml` — primary risk definition
- `paper-state.yaml` — frozen paper snapshot

## Outputs
- `round-scope.yaml` — frozen scope boundary

## Allowed Actions
- Read round-risk and paper-state.
- Declare in-scope claims, sections, baselines.
- Declare out-of-scope claims, sections.
- List allowed and forbidden changes.

## Forbidden Actions
- Do not modify paper-state or round-risk.
- Do not search for external sources.
- Do not generate critique or patches.

## Procedure
1. Map the primary risk to specific claims and sections that need attention.
2. List these as in_scope_claims and in_scope_sections.
3. List baselines that are in scope for comparison.
4. Explicitly list what is out of scope (prevent mission creep).
5. Define allowed_changes and forbidden_changes as concrete constraints.

## Output Contract
```yaml
in_scope_claims: [claim_id, ...] (>=1 item, each must exist in paper-state)
in_scope_sections: [section_anchor, ...] (>=1 item)
in_scope_baselines: [baseline_id, ...]
out_of_scope_claims: [claim_id, ...]
out_of_scope_sections: [section_anchor, ...]
allowed_changes: [string, ...]
forbidden_changes: [string, ...] (>=1 item)
```

## Failure Conditions
- in_scope_claims empty.
- forbidden_changes empty.
- in-scope claim_id not found in paper-state.
- Scope boundary is vague (e.g., "improve paper").

## Completion Checklist
- [ ] All in-scope claims traceable to paper-state.
- [ ] Forbidden changes are concrete and explicit.
- [ ] Out-of-scope items documented.
- [ ] round-scope.yaml is valid YAML.

## Knowledge Use
Before executing: inspect loaded-knowledge.yaml for cards with intended_use including `freeze_round_scope`. Cite relevant card_ids.

## Handoff
Research planning phases will use this scope to design targeted research questions.
