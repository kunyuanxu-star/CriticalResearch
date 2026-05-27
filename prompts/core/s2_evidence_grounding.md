# Stage 2: Evidence Grounding

## Mission
Execute deep retrieval, triage sources, ingest and read them, normalize evidence, build a related-work map, and produce a Claim-Evidence Map. This stage replaces the old M1-M2 research phases into a single evidence-grounding pass.

This stage enforces **Inv2**: Every major critique must be grounded in evidence, paper text, domain convention, or venue standard.

## Inputs
- `round:round-contract.yaml` — round contract with target and scope
- `project:documents/<doc-id>.md` — current target document
- `project:state/claim-ledger.yaml` — existing claim definitions

## Outputs
- `evidence-ledger.yaml` — structured evidence with categories
- `claim-evidence-map.yaml` — per-claim evidence mapping
- `search-log.yaml` — log of all queries executed
- `raw-sources/` — directory of raw source snapshots

## Allowed Actions
- Plan research questions based on round contract.
- Generate search strategy and query classes.
- Execute searches and retrieve sources.
- Triage sources (include/exclude/maybe).
- Ingest sources into raw-sources/ with content hashes.
- Read sources deeply and write source notes.
- Normalize evidence: link each item to source_id and claim_id.
- Build related-work map and baseline positioning.
- Update literature knowledge cards.
- Write evidence-ledger.yaml and claim-evidence-map.yaml.

## Forbidden Actions
- Do not generate critique.
- Do not edit target document.
- Do not generate patches.
- Do not fabricate source content.
- Do not synthesize claims before evidence is normalized.

## Procedure

### 1. Plan Research Questions
Derive 3–7 research questions from the round contract target and fragile claims.
Each question must be falsifiable and bound to a specific claim or section.

### 2. Generate Search Strategy
For each research question, define:
- Query classes (exact phrases, author names, method names).
- Expected evidence types.
- Target venues or databases.

### 3. Execute Retrieval
Execute searches. Record every query in search-log.yaml with:
- query_text, source, results_count, selected_sources.
Save raw source snapshots to raw-sources/.

### 4. Triage Sources
For each source, decide: include | exclude | maybe.
Record triage decision with reason >= 10 chars.

### 5. Ingest and Read Sources
Index all included sources. Write deep-reading notes per source covering:
- What it is, what problem it addresses, what method it uses.
- What it supports in the current paper.
- What it weakens or contradicts.
- What it does NOT prove.
- Which paper section it affects.

### 6. Normalize Evidence
Produce evidence-ledger.yaml where each item has:
- evidence_id, source_id, evidence_level (S/A/B/C/D).
- evidence_category: supporting | weakening | baseline | writing_reference | terminology.
- related_claims, relation, direct_support, does_not_support.
- allowed_wording, forbidden_wording.

**At least one evidence item must have evidence_category: weakening.**

### 7. Build Claim-Evidence Map
Produce claim-evidence-map.yaml mapping each claim to:
- supporting_evidence (evidence_ids).
- weakening_evidence (evidence_ids).
- missing_evidence (description, required_to_support, priority).
- affected_sections.

## Output Contract

```yaml
evidence-ledger.yaml:
  round_id: integer
  evidence:
    - evidence_id: E###
      source_id: S###
      source_type: string
      evidence_level: S|A|B|C|D
      evidence_category: supporting|weakening|baseline|writing_reference|terminology
      related_claims: [CLM-###]
      relation: supports|weakens|contextualizes|contradicts
      direct_support: string (>= 10)
      does_not_support: string (>= 10)
      applicable_scenario: string (>= 5)
      allowed_wording: string (>= 10)
      forbidden_wording: string (>= 10)

claim-evidence-map.yaml:
  round_id: integer
  mappings:
    - claim_id: CLM-###
      supporting_evidence: [E###]
      weakening_evidence: [E###]
      missing_evidence:
        - description: string
          required_to_support: string
          priority: high|medium|low
      affected_sections: [string]
```

## Failure Conditions
- No evidence items.
- No weakening evidence item (evidence_category: weakening).
- Any evidence item missing source_id or related_claims.
- search-log.yaml missing.
- raw-sources/ empty.

## Completion Checklist
- [ ] Research questions defined and bound to claims.
- [ ] Search strategy documented.
- [ ] Sources triaged and ingested.
- [ ] Evidence normalized with categories.
- [ ] At least one weakening evidence item present.
- [ ] Claim-evidence map covers all core claims.
- [ ] All artifacts are valid YAML.

## Full-Document Coverage Requirement
Evidence gathering must cover all claims and sections mentioned in the round contract, not just the primary target. Document coverage in the evidence-ledger or claim-evidence-map.

## Handoff
The next stage (`s3_critical_review`) uses the evidence and claim map to conduct adversarial critique.
