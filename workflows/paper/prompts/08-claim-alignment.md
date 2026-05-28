# Stage 8: Claim Alignment

## Purpose

Verify that all claims in the modified paper are internally consistent, evidence-aligned, patch-consistent, and safe to carry into round closure.

This stage is part of the **paper workflow**. It runs after Stage 7 has modified the paper. Its role is to catch claim-level regressions introduced by patching: new unsupported claims, accidental overclaiming, weakened claims that were not actually weakened, contradictions between sections, evaluation claims that do not match experiments, or contribution statements that exceed the evidence.

This stage must not edit the paper. If claim-alignment failures are found, record them as findings, residual risks, blockers, or next-round targets. Do not silently repair them.

A paper patch is not successful merely because the document changed. It is successful only if the resulting claims remain coherent, scoped, and supported by the evidence grounding.

## Stage Type

post-patch validation

## Required Inputs

* Modified target paper document — read all sections needed to verify claim consistency.
* `paper-state.yaml` — original claim inventory, contribution inventory, section structure, and known claim roles.
* `claim-evidence-grounding.yaml` — evidence map, evidence strength, overclaim assessments, evidence-supported wording, and evaluation obligations from Stage 3.
* `critical-review.yaml` — reviewer objections and critique items from Stage 4.
* `writing-strategy.yaml` — intended writing and rhetorical repairs from Stage 5.
* `revision-plan.yaml` — planned patches, claim constraints, dependencies, and validation criteria from Stage 6.
* `patch-plan.yaml` — executable patch plan from Stage 6.
* `patch-trace.yaml` — actual applied patches and repair status from Stage 7.
* `document-diff.yaml` — exact before/after text changes from Stage 7.
* `residual-risks.yaml` — unresolved risks from patch application, if any.
* `contract.yaml` — mutable document, target units, round scope, and project context.
* Project knowledge ledger or knowledge cards, if available.
* `workflows/paper/profile.md` — paper workflow claim semantics.
* `workflows/_shared/evidence-discipline.md` — evidence adequacy and claim-strength rules.
* `workflows/_shared/stage-protocol.md` — stage execution discipline.

## Allowed Writes

* `claim-alignment.yaml`

No paper document edits are allowed in this stage.

## Required Procedure

### Step 1: Re-Extract Claims from the Modified Paper

Read the modified target paper document and extract all claims from the target units and any surrounding sections needed for consistency checking.

Extract claims including:

* problem claims;
* motivation claims;
* root-cause claims;
* novelty claims;
* insight claims;
* design claims;
* mechanism claims;
* implementation claims;
* performance claims;
* security claims;
* correctness claims;
* compatibility claims;
* scalability claims;
* evaluation claims;
* related-work comparison claims;
* contribution claims;
* limitation and scope claims.

For each claim, record:

* claim ID;
* verbatim text;
* section;
* paragraph or sentence location;
* claim type;
* role in the paper;
* whether it is old, modified, new, moved, deleted, split, or merged.

Do not paraphrase claim text when recording it. Copy the modified paper wording exactly.

### Step 2: Map Modified Claims to Original Claims

For each extracted claim, determine its relation to the original claim inventory and Stage 3 evidence grounding:

* unchanged from original;
* weakened version of an original claim;
* strengthened version of an original claim;
* scoped version of an original claim;
* moved original claim;
* split original claim;
* merged original claims;
* newly introduced claim;
* original claim removed.

For each changed claim, trace it to:

* patch ID;
* critique ID;
* writing-strategy item;
* document diff entry;
* expected effect from the revision plan.

If a changed claim cannot be traced to a patch, flag it as unplanned claim drift.

### Step 3: Check Evidence Alignment

For every current claim, compare its wording with `claim-evidence-grounding.yaml`.

Check:

* Does the claim have an evidence-grounding entry?
* If it is modified, does the new wording remain within evidence-supported scope?
* If it is strengthened, does the evidence permit strengthening?
* If it is weakened, did the weakening actually reduce the unsupported scope?
* If it is new, is it supported by existing evidence or must it be flagged as unsupported?
* If it is deleted, was deletion intentional and traceable to a patch?
* If it is moved, does its new location preserve the correct scope and role?

Rules:

* A claim with `evidence_strength: none` must not be strengthened.
* A claim with `evidence_strength: weak` must not be made central without adding an explicit evaluation obligation or weakening its wording.
* A performance, security, correctness, compatibility, or scalability claim must not rely only on rhetorical plausibility.
* A novelty claim must remain consistent with related-work positioning and dangerous baselines.
* A contribution claim must not exceed the strongest supported claim in the body.
* An evaluation claim must match what the evaluation actually measures.

### Step 4: Check Cross-Section Consistency

Compare claims across sections.

Check for contradictions between:

* abstract and introduction;
* introduction and design;
* design and implementation;
* design and evaluation;
* evaluation and contribution statement;
* related work and novelty claim;
* limitations and main claims;
* conclusion and evidence scope.

Specific checks:

* Does the introduction promise what the evaluation demonstrates?
* Does the evaluation claim something the design does not describe?
* Does related work undercut or contradict the novelty claim?
* Does the contribution list make broader claims than the body supports?
* Does the limitation section narrow claims that earlier sections state too broadly?
* Are scope terms consistent across the paper?
* Are technical terms defined once and used consistently?

A contradiction is a blocker if both claims are central and cannot both be true.

### Step 5: Check Patch-Intent Consistency

For every patch in `patch-trace.yaml`, verify whether the actual claim change matches the intended repair.

Check:

* Did a `claim_weakening` patch actually weaken the claim?
* Did a `claim_strengthening` patch stay within evidence-supported wording?
* Did a `paragraph_rewrite` accidentally change claim meaning?
* Did a `section_restructure` move claims into misleading context?
* Did a `contribution_rewrite` align contributions with evidence?
* Did a `related_work_repositioning` preserve fair comparison?
* Did an `evaluation_obligation_addition` avoid implying that the evaluation has already been performed?

If patch intent and claim effect diverge, record claim drift.

### Step 6: Check OSDI/SOSP Reviewer Safety

Assess whether any current claim would still trigger a top-tier systems reviewer objection.

This is not a new review stage. It is a validation step against already identified risks.

Check whether the modified paper still contains:

* unsupported central claims;
* broad claims without scope;
* novelty claims not defended against dangerous baselines;
* contribution claims that sound generic or overstated;
* evaluation claims not tied to metrics, baselines, or workloads;
* design claims without mechanism or invariant support;
* security claims without threat model;
* performance claims without measurement;
* compatibility claims without tested scope;
* absolute wording such as “all,” “always,” “guarantee,” “eliminate,” “negligible,” or “first” without sufficient evidence.

Flag such cases as reviewer-safety risks.

### Step 7: Check Knowledge Ledger Consistency

If project knowledge cards or claim ledger entries exist, compare the modified paper claims with durable project knowledge.

Check:

* Does the paper contradict a stable knowledge card?
* Does it use terminology inconsistent with project terminology?
* Does it ignore a known dangerous baseline?
* Does it rely on a claim that prior rounds marked provisional or contested?
* Does it use forbidden wording from project knowledge?
* Does it introduce a new reusable claim that should be considered in Stage 9?

Do not update knowledge in this stage. Record knowledge-alignment findings in `claim-alignment.yaml` for Stage 9.

### Step 8: Classify Alignment Findings

For every issue found, classify it as one of:

* `claim_contradiction`: two or more claims cannot all be true.
* `evidence_mismatch`: claim wording exceeds evidence-supported scope.
* `new_unsupported_claim`: patch introduced a claim without grounding.
* `unplanned_claim_drift`: claim changed without trace to a planned patch.
* `failed_claim_weakening`: a weakening patch did not actually weaken the claim.
* `unsafe_claim_strengthening`: a strengthening patch exceeded evidence.
* `missing_claim`: original claim disappeared without patch trace.
* `scope_mismatch`: claim scope differs across sections.
* `terminology_mismatch`: term usage changed or became inconsistent.
* `contribution_mismatch`: contribution statement exceeds body evidence.
* `evaluation_mismatch`: evaluation wording exceeds measured evidence.
* `related_work_mismatch`: novelty or comparison claim conflicts with related work.
* `knowledge_conflict`: claim conflicts with project knowledge.
* `acceptable_alignment`: claim is aligned and safe.

Assign severity:

* `fatal`: prevents round closure unless repaired in a new patch round or resolved by human decision.
* `high`: likely to produce reviewer objection or evidence failure.
* `medium`: weakens consistency but does not invalidate core claim.
* `low`: local inconsistency or wording risk.

### Step 9: Decide Closure Readiness

Determine whether the paper is safe to close this round.

Closure statuses:

* `aligned`: no claim-alignment blockers.
* `aligned_with_residual_risks`: only low/medium risks remain and are recorded.
* `needs_next_round`: high risks remain but can be handled in a future round.
* `blocked`: fatal claim contradiction, unsupported central claim, or unsafe claim strengthening remains.

If blocked, identify exactly what must happen next:

* new paper patch round;
* return to Stage 6/7 if workflow permits;
* human decision;
* new evidence grounding;
* evaluation planning;
* related-work survey round.

### Step 10: Write Claim Alignment

Produce `claim-alignment.yaml`.

## Output Contract

```yaml
residual-risks.yaml:
claim-alignment.yaml:
  schema_version: "1.0.0"
  round_id: string
  project_id: string
  target_document: string

  alignment_summary:
    total_current_claims: integer
    unchanged_claims: integer
    modified_claims: integer
    new_claims: integer
    deleted_claims: integer
    aligned_claims: integer
    misaligned_claims: integer
    fatal_findings: integer
    high_findings: integer
    medium_findings: integer
    low_findings: integer
    closure_status: aligned | aligned_with_residual_risks | needs_next_round | blocked
    summary_judgment: string

  current_claims:
    - current_claim_id: string
      text: string
      location:
        section: string
        paragraph_id: string | null
        sentence_id: string | null
      claim_type: problem | motivation | root_cause | novelty | insight | design | mechanism | implementation | performance | security | correctness | compatibility | scalability | evaluation | related_work | contribution | limitation | scope
      role_in_paper: core | supporting | background | limitation | transition
      relation_to_original: unchanged | weakened | strengthened | scoped | moved | split | merged | new | deleted_original
      original_claim_ids:
        - string
      patch_trace:
        patch_ids:
          - string
        diff_ids:
          - string
        critique_ids:
          - string
      evidence_alignment:
        grounding_entry_exists: boolean
        evidence_strength: strong | moderate | weak | none | not_applicable
        within_evidence_supported_scope: boolean
        evidence_supported_wording: string | null
        mismatch_reason: string | null
      alignment_status: aligned | misaligned | unresolved | not_applicable
      notes: string

  deleted_original_claims:
    - original_claim_id: string
      original_text: string
      deletion_traced_to_patch: boolean
      patch_id: string | null
      deletion_intentional: boolean
      risk_if_unintentional: string | null

  cross_section_consistency:
    - check_id: string
      sections_compared:
        - string
      claim_ids:
        - string
      status: consistent | inconsistent | scope_mismatch | unresolved
      finding: string
      severity: fatal | high | medium | low
      required_action: string | null

  patch_intent_alignment:
    - patch_id: string
      patch_type: string
      intended_effect: string
      actual_claim_effect: string
      status: matched | partially_matched | drifted | failed | blocked
      affected_claim_ids:
        - string
      finding: string
      severity: fatal | high | medium | low

  findings:
    - finding_id: string
      finding_type: claim_contradiction | evidence_mismatch | new_unsupported_claim | unplanned_claim_drift | failed_claim_weakening | unsafe_claim_strengthening | missing_claim | scope_mismatch | terminology_mismatch | contribution_mismatch | evaluation_mismatch | related_work_mismatch | knowledge_conflict
      severity: fatal | high | medium | low
      affected_claim_ids:
        - string
      affected_sections:
        - string
      evidence_or_trace_basis:
        evidence_ids:
          - string
        patch_ids:
          - string
        diff_ids:
          - string
        knowledge_refs:
          - string
      finding: string
      reviewer_risk: string
      required_resolution: new_patch_round | re_ground_evidence | weaken_claim | delete_claim | add_evaluation_obligation | related_work_repositioning | human_decision | record_residual_risk

  knowledge_alignment_notes:
    - note_id: string
      claim_id: string
      relation_to_project_knowledge: consistent | contradicts | refines | requires_update | new_candidate_knowledge
      knowledge_ref: string | null
      note: string

  next_round_recommendations:
    - recommendation_id: string
      reason: string
      suggested_workflow: paper | survey | design | experiment | proposal
      suggested_target_unit: string | null
      priority: high | medium | low
```

## Quality Gates

* Every current claim in the modified target units must be recorded or explicitly scoped out.
* Every modified claim must trace to a patch or be flagged as unplanned claim drift.
* Every new claim must either map to existing evidence grounding or be flagged as unsupported.
* Every deleted original claim must be traced to an intentional patch or flagged.
* Every claim-strengthening patch must be checked against evidence strength.
* Every claim-weakening patch must be checked to ensure it actually weakened the claim.
* Every central contribution claim must be consistent with body evidence.
* Every evaluation claim must match the evaluation scope.
* Every novelty claim must remain consistent with related-work positioning.
* Every fatal or high finding must include a required resolution.
* No paper document edits may be made in this stage.
* `claim-alignment.yaml` must be the only artifact written.

## Failure Conditions

Stop and report a blocker if:

* the modified paper document cannot be read;
* `claim-evidence-grounding.yaml` is missing;
* `patch-trace.yaml` is missing;
* `document-diff.yaml` is missing;
* current claims cannot be mapped to patches or grounding records;
* a central claim was strengthened without evidence support;
* a new unsupported central claim was introduced;
* two core claims contradict each other;
* a fatal finding remains without required resolution;
* the stage would require editing the paper to proceed.

## Forbidden Behavior

* Do not modify the paper document.
* Do not re-run evidence research.
* Do not invent new evidence for newly introduced claims.
* Do not treat claim alignment as a new reviewer critique stage.
* Do not silently accept claim drift introduced by patching.
* Do not mark a claim aligned merely because it sounds plausible.
* Do not ignore section-level contradictions.
* Do not ignore deleted original claims.
* Do not update project knowledge directly.
* Do not advance if fatal claim-alignment blockers remain.

## Advance Rule

After `claim-alignment.yaml` is produced and all quality gates pass, run `cr stage advance`.

```
```
