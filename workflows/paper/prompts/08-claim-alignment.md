# Stage 8: Claim Alignment

## Purpose

Verify that all claims in the modified paper are mutually consistent and aligned with the evidence grounding from stage 3 and the project's knowledge ledger. Patches in stage 7 may have introduced new claims, altered existing claims, or created contradictions between sections. This stage catches those issues before the round closes — a claim introduced in the evaluation section that contradicts the introduction's claim is a bug, not a feature.

This stage must NOT:
- Modify the paper document (that's stage 7; if issues are found, record them for the next round)
- Re-evaluate evidence (that's stage 3 — use the existing grounding)
- Generate new critiques (that's stage 4 — record misalignments as findings, not as new critiques)

## Stage Type

validation

## Required Inputs

- The modified paper document — read in full, all sections
- `claim-evidence-grounding.yaml` — original evidence map from stage 3
- `patch-trace.yaml` — every applied patch, expected and actual effects
- `document-diff.yaml` — every text change with before/after
- `contract.yaml` — target units, project context
- `workflows/paper/profile.md` — paper workflow claim semantics
- `workflows/_shared/stage-protocol.md` — stage execution discipline
- `workflows/_shared/evidence-discipline.md` — evidence adequacy rules for claim validation

## Allowed Writes

- `claim-alignment.yaml` — and ONLY claim-alignment.yaml

## Required Procedure

### Step 1: Extract Claims from Modified Paper
Re-extract all claims from the modified paper, following the same methodology as stage 2 (but only for claims, not the full paper state):
- Read every section
- Extract every falsifiable statement the paper asserts as true
- Copy claim text verbatim from the modified paper

### Step 2: Cross-Check Against Original Grounding
For each claim extracted:
- Does this claim exist in `claim-evidence-grounding.yaml`? (same claim ID, same or similar wording)
- If it's a modified claim: does the new wording still match the evidence assessment?
- If it's a new claim: what evidence supports it? (flag if none)
- If an original claim is missing: was it intentionally dropped (trace to a patch), or did it accidentally disappear?

### Step 3: Check Internal Consistency
Compare claims across sections:
- Does the introduction claim something the evaluation does not demonstrate?
- Does the evaluation claim something the design section does not describe?
- Are scope claims consistent? (e.g., "works for all workloads" in abstract but "tested on read-heavy workloads" in evaluation)
- Are terminology and definitions consistent across sections?

### Step 4: Check Claim Wording Against Patch Intent
For every patch in `patch-trace.yaml` that modified a claim:
- Did the claim change match the patch's `expected_effect`?
- Did a claim_weakening patch actually weaken the claim, or did it change it to a different claim?
- Did a claim_strengthening patch introduce an overclaim?
- Did a paragraph_rewrite accidentally modify a claim's meaning?

### Step 5: Cross-Check Against Knowledge Ledger
If the project has a knowledge ledger (claims tracked across rounds):
- Are claim IDs consistent between the paper and the ledger?
- Have claims been updated in the ledger to reflect modifications?
- Flag any claim that contradicts a `proven` knowledge card

### Step 6: Flag Misalignments
For every issue found:
- **Claim contradiction**: two claims that cannot both be true
- **Evidence mismatch**: a claim whose wording exceeds what evidence supports
- **Missing claim**: a claim from the original paper that was dropped without a corresponding patch
- **New unsupported claim**: a claim introduced in stage 7 that has no evidence backing
- **Wording drift**: a claim that was supposed to be weakened but was rewritten as a different claim

### Step 7: Write Claim Alignment
Produce `claim-alignment.yaml`.

## Output Contract

```yaml
claim-alignment.yaml:
  schema_version: "1.0.0"
  round_id: integer
  modified_claims:
    - claim_id: string               # original claim ID (C-001, ...) or "NEW-001" for new
      current_text: string           # exact text in modified paper
      original_text: string | null   # text before modification (null if new)
      modified_by_patch: string | null  # PP-001, or null if unintentional
      alignment_status: aligned | modified_consistent | modified_inconsistent | dropped | new_unsupported
      issue: string | null           # if not aligned: what's wrong
  contradictions:
    - claim_a: string                # claim ID
      claim_b: string                # claim ID
      description: string            # why they contradict
      severity: fatal | major | minor
  evidence_mismatches:
    - claim_id: string
      original_evidence_strength: strong | moderate | weak | none
      current_wording_exceeds_evidence: boolean
      explanation: string
  missing_claims:
    - claim_id: string               # claims from original paper no longer present
      dropped_intentionally: boolean # traceable to a patch?
      patch_id: string | null
  new_unsupported_claims:
    - claim_id: string
      claim_text: string
      introduced_by: string          # patch ID or section
      evidence_available: boolean
  knowledge_ledger_issues:
    - claim_id: string
      issue: string                  # contradiction with proven card, ID mismatch, etc.
  overall_alignment: aligned | minor_issues | major_issues | critical_issues
  summary: string                    # one paragraph: state of claim alignment after this round
```

## Quality Gates

- [ ] Every claim in the modified paper is accounted for (in modified_claims, or matched to an existing entry)
- [ ] Every contradiction is documented with both claim IDs and a specific explanation
- [ ] Every new claim introduced by patches is identified (even if supported)
- [ ] `overall_alignment` matches the severity of issues found — `critical_issues` if any contradiction is fatal
- [ ] Missing claims are traced to patches or flagged as unintentional

## Failure Conditions

- A fatal contradiction found (e.g., abstract claims "10x improvement" but evaluation shows "1.5x") — STOP; flag for human review
- A new unsupported claim was introduced by a patch — STOP; the patch introduced a regression
- A claim was dropped without a traceable patch — STOP; this may be a data loss bug
- The paper has more claims after stage 7 than before, and some are unsupported — STOP; patches should reduce, not inflate, claim risk

## Forbidden Behavior

- Do not modify the paper document — validation stage; record issues, don't fix them
- Do not re-evaluate evidence — use the existing `claim-evidence-grounding.yaml` as authoritative
- Do not generate new critiques — alignment issues are findings, not reviewer critiques
- Do not skip claims because they "seem fine" — every claim gets cross-checked
- Do not mark `overall_alignment: aligned` if ANY issue exists — even minor issues prevent a clean alignment

## Advance Rule

After all quality gates pass and `claim-alignment.yaml` is written, run `cr stage advance`.
