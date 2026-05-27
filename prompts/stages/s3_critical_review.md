# Stage 3: Critical Review

## Mission
Conduct adversarial review of the paper using the evidence and claim-evidence map. Synthesize claim evidence, baseline positioning, and evaluation gaps. Then produce five critique passes (claim precision, novelty/baselines, evidence sufficiency, evaluation contract, writing/argument). Merge all findings into a unified critique-ledger.yaml and produce review-disposition.yaml.

This stage enforces **Inv2**: Every major critique must be grounded in evidence, paper text, domain convention, or venue standard.

## Inputs
- `round:evidence-ledger.yaml` — structured evidence
- `round:claim-evidence-map.yaml` — per-claim evidence mapping
- `project:writing/paper-draft.md` — current paper draft
- `round:round-contract.yaml` — round contract

## Outputs
- `critique-ledger.yaml` — structured critique entries
- `review-disposition.yaml` — per-critique disposition with required actions

## Allowed Actions
- Read evidence, claim map, paper draft, and round contract.
- Synthesize claim evidence, baseline positioning, and evaluation gaps.
- Critique claim precision, novelty, evidence sufficiency, evaluation contract, and writing/argument.
- Merge all critique passes into a unified ledger.
- Decide disposition for every critique.
- Link critiques to source evidence and affected claims/sections.

## Forbidden Actions
- Do not edit paper draft.
- Do not generate patches.
- Do not apply patches.
- Do not reject medium+ critiques without substantive reason.

## Procedure

### 1. Synthesize Claim Evidence
For every core claim, assess:
- Support level from evidence.
- Gaps between claim strength and evidence strength.
- Missing evidence that would change the assessment.

### 2. Synthesize Baseline Positioning
Identify:
- Strongest competing method/system/theory.
- Whether any baseline subsumes the paper's contribution.
- Novelty threat level.

### 3. Synthesize Evaluation Gaps
For each core claim, document:
- Current evaluation contract.
- Missing experiments, benchmarks, or proofs.
- Whether the evaluation matches the claim type.

### 4. Critique Passes
Execute five critique passes. Every finding must be grounded in evidence, paper text, domain convention, or venue standard.

**Pass A: Claim Precision**
- Is each claim falsifiable and scoped?
- Are assumptions explicit?
- Are scope boundaries clear?

**Pass B: Novelty and Baselines**
- Is the baseline the strongest available?
- Could a simpler method achieve the same result?
- Is novelty incremental or significant?

**Pass C: Evidence Sufficiency**
- Does evidence actually support the claim?
- Is there contradictory evidence?
- Are evidence levels appropriate for claim strength?

**Pass D: Evaluation Contract**
- Does evaluation match claim type?
- Are metrics appropriate?
- Are there missing baselines, ablations, or analyses?

**Pass E: Writing and Argument**
- Is the argument chain coherent?
- Are transitions logical?
- Is rhetoric appropriate for the venue?

### 5. Merge Critique Ledger
Merge all five passes into critique-ledger.yaml:
- Assign unique critique_id to each finding.
- Ensure every medium+ critique has evidence_refs.
- Set must_create_patch=true for all high/fatal critiques.
- Ensure every critique has reason >= 20 chars.
- Record source_evidence, affected_claims, affected_sections.

### 6. Review Disposition
For every critique in the ledger, produce a disposition in review-disposition.yaml:
- disposition_id, critique_id, disposition_type, justification, status.
- required_action with action_type, target_section, rationale.
- affected_claims, affected_sections.

Status must be one of: open | resolved | pending_human_decision.

## Output Contract

```yaml
critique-ledger.yaml:
  schema_version: "1.0.0"
  round_id: integer
  critiques:
    - critique_id: CRT-###
      severity: fatal|high|medium|low
      target_type: claim|baseline|assumption|evaluation_contract|writing|internal_consistency
      target_id: string
      attack_type: string
      attack_statement: string (>= 10)
      why_damaging: string (>= 10)
      evidence_refs: [E###]
      source_evidence: [E###]
      disposition_ref: DSP-###
      affected_claims: [CLM-###]
      affected_sections: [string]
      required_action:
        action_type: string
        target_sections: [string]
        must_create_patch: bool

review-disposition.yaml:
  schema_version: "1.0.0"
  round_id: integer
  dispositions:
    - disposition_id: DSP-###
      critique_id: CRT-###
      disposition_type: paper_patch|experiment_obligation|claim_deleted|deferred|rejected_with_reason|no_op
      linked_patch_id: PP-### (optional)
      linked_experiment_id: EXP-### (optional)
      justification: string (>= 10)
      status: open|resolved|pending_human_decision
      severity: fatal|high|medium
      required_action:
        action_type: strengthen|weaken|reframe|delete|defer|add_experiment
        target_section: string
        rationale: string (>= 10)
      affected_claims: [CLM-###]
      affected_sections: [string]
```

## Failure Conditions
- No medium+ critiques.
- Any high/fatal critique has must_create_patch=false.
- Any critique reason < 20 chars.
- Any critique missing evidence_refs (medium+).
- Any critique has no disposition.
- Any disposition missing required_action.

## Completion Checklist
- [ ] All five critique passes completed.
- [ ] Critique ledger merged with unique IDs.
- [ ] Every medium+ critique has evidence_refs.
- [ ] Every high/fatal critique has must_create_patch=true.
- [ ] Every critique has a disposition.
- [ ] Review-disposition.yaml has required_action for every disposition.

## Full-Paper Coverage Requirement
Critique must cover all sections, claims, assumptions, baselines, and evaluations. Document coverage in the critique-ledger.

## Handoff
The next stage (`s4_revision_strategy`) turns critiques into concrete revision decisions.
