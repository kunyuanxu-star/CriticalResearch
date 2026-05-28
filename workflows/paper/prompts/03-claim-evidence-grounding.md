# Stage 3: Claim-Evidence Grounding

## Purpose

Map every claim in the paper to its supporting evidence, assess evidence strength, and identify gaps. This stage transforms the claim inventory from stage 2 into a risk-ranked evidence assessment that drives the reviewer critique in stage 4. A claim without adequate evidence is a vulnerability — this stage finds every vulnerability.

This stage must NOT:
- Critique the paper's arguments (that's stage 4)
- Propose claim wording changes (that's stage 5)
- Judge whether a claim is "good" — only whether it is supported

## Stage Type

analysis-only

## Required Inputs

- `paper-state.yaml` — claim inventory with claim text and locations
- `contract.yaml` — round scope, read-only context, loaded knowledge cards
- `workflows/paper/profile.md` — paper workflow semantics
- `workflows/_shared/stage-protocol.md` — stage execution discipline
- `workflows/_shared/evidence-discipline.md` — evidence types, strength, and adequacy rules
- The target paper document — to verify evidence claims in context

## Allowed Writes

- `claim-evidence-grounding.yaml` — and ONLY claim-evidence-grounding.yaml

## Required Procedure

### Step 1: Load Paper State and Evidence Discipline
Read `paper-state.yaml` to get the complete claim inventory. Read `workflows/_shared/evidence-discipline.md` to internalize the evidence adequacy rules. Read `contract.yaml` for read-only context documents that may contain evidence.

### Step 2: Map Each Claim to Evidence
For every claim in the claim inventory:
- What evidence does the paper cite for this claim? (experiment, proof, prior work citation, logical argument, none)
- Is the cited evidence present in the paper? (yes, in section X / no, only referenced / no, missing entirely)
- What type of evidence is it? (direct measurement, formal proof, cited prior work, ablation, logical argument, anecdote)

### Step 3: Assess Evidence Strength
For each claim:
- **Strong**: direct measurement or formal proof that directly tests the claim
- **Moderate**: cited prior work that addresses the claim but not directly, or ablation that partially supports
- **Weak**: logical argument only, with no empirical or formal backing
- **None**: no evidence whatsoever

### Step 4: Identify Overclaims
For each claim, compare the claim's wording to what the evidence actually supports:
- Does the claim assert stronger conclusions than the evidence warrants?
- Does the claim generalize beyond the tested conditions?
- Does the claim omit scope limitations present in the evidence?

### Step 5: Generate Evaluation Obligations
For each claim with weak or missing evidence:
- What specific evidence would close the gap? (an experiment, a proof, a citation)
- What would the evidence need to demonstrate?
- How critical is closing this gap to the paper's contribution?

### Step 6: Flag High-Risk Claims
Claims that are:
- Core claims with weak or no evidence
- Claims that contradict loaded knowledge cards
- Claims that are worded as absolutes but backed only by logical argument
- Claims that the evidence directly contradicts

### Step 7: Write Claim-Evidence Grounding
Produce `claim-evidence-grounding.yaml` with the complete mapping.

## Output Contract

```yaml
claim-evidence-grounding.yaml:
  schema_version: "1.0.0"
  round_id: integer
  claim_evidence_map:
    - claim_id: string               # C-001, matches paper-state.yaml
      claim_text: string             # verbatim from paper-state.yaml
      evidence_cited:
        type: direct_measurement | formal_proof | cited_prior_work | ablation | logical_argument | none
        location: string | null      # where in the paper, if present
        description: string          # what the evidence is
      evidence_strength: strong | moderate | weak | none
      overclaim_assessment:
        is_overclaimed: boolean
        explanation: string          # if overclaimed: what the evidence actually supports
        suggested_scope: string      # the scope the evidence actually justifies
      evaluation_obligation:
        needed: boolean
        description: string | null   # what evidence would close the gap
        criticality: critical | important | nice_to_have
      risk_level: high | medium | low
      risk_rationale: string         # why this risk level
  summary:
    total_claims: integer
    strong_evidence: integer
    moderate_evidence: integer
    weak_evidence: integer
    no_evidence: integer
    overclaimed: integer
    high_risk: integer
  critical_gaps: [string]            # claim IDs that are both core and high-risk
```

## Quality Gates

- [ ] Every claim from `paper-state.yaml` has a corresponding entry in `claim_evidence_map`
- [ ] No claims are missing — the count in `summary.total_claims` matches the claim inventory
- [ ] Evidence strength is justified — each "strong" or "weak" rating has a specific reason
- [ ] Overclaim assessments cite specific wording differences between claim and evidence
- [ ] Every claim with `evidence_strength: none` has an evaluation obligation
- [ ] `critical_gaps` lists only core claims that are also high-risk
- [ ] Summary counts add up correctly: strong + moderate + weak + none == total_claims

## Failure Conditions

- A claim in `paper-state.yaml` has no entry in the evidence map — STOP, incomplete analysis
- Evidence is asserted to exist but cannot be found in the paper — STOP, do not fabricate evidence
- A core claim has `evidence_strength: none` — this is a critical finding, not a failure; record it and proceed

## Forbidden Behavior

- Do not fabricate evidence — if evidence is missing, say so
- Do not inflate evidence strength — logical argument is not "moderate"
- Do not dismiss missing evidence as "acceptable for this venue" without citing venue standards
- Do not modify the paper document — analysis-only stage
- Do not propose claim wording changes — that belongs in stage 5
- Do not skip claims because they seem "obviously supported" — every claim gets assessed

## Advance Rule

After all quality gates pass and `claim-evidence-grounding.yaml` is written, run `cr stage advance`.
