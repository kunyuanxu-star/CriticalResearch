---
name: critical-cs-research
description: A domain-general but computer-science-specific critical research loop for OS, networking, security, databases, PL/compilers, architecture, AI infrastructure, distributed systems, software engineering, HCI/CSCW, and technical systems work. Use when Codex must validate a CS research idea, paper motivation, related-work critique, system design, experiment plan, rebuttal, survey, architecture decision, security analysis, or performance diagnosis by decomposing claims, grounding evidence, finding counterexamples, generating research gaps, re-searching, revising claims, mapping evaluation obligations, and producing evidence-backed conclusions.
---

# Critical CS Research

## Core Rule

Do not directly polish or defend the user's original idea. First run the research control loop:

`Problem -> Claim -> Assumption -> Evidence -> Counterexample -> Gap -> Re-search -> Revision -> Decision`

The final answer must preserve the trace from each conclusion back to claims, evidence, counterexamples, critiques, and decisions. Allow the original idea to be weakened, reframed, marked as risk, or deleted.

## When Starting

1. Identify the task type: idea validation, paper motivation, related-work critique, system design review, experiment planning, rebuttal preparation, survey construction, architecture decision, security analysis, or performance diagnosis.
2. Identify the CS area: systems, networking, security, database, PL/compiler, architecture, software engineering, AI infrastructure, distributed systems, or HCI/CSCW.
3. Read `references/domain-profiles.md` for the relevant profile when the area is clear or when profile-specific checks matter.
4. Read `references/evidence-standards.md` before doing source-backed research or assigning evidence levels.
5. Read `references/role-lenses.md` when the task is large enough to benefit from separate parsing, scouting, counterexample, review, audit, experiment, and synthesis passes.
6. Use `templates/*.md` when the user asks for reusable artifacts, files, or exhaustive output.

If the user has not provided material, ask for it. If target venue, audience, or output form is missing, infer a reasonable default and state it briefly.

## Required Workflow

### Phase 0: Task Initialization

Output a compact initialization block:

- Task type
- CS area
- Target output
- Target venue or rigor level
- Main risk
- Initial hypothesis

### Phase 1: Problem Framing

Normalize the user's material into a research problem. Make explicit:

- Target phenomenon
- Relevant existing approaches
- Claimed limitation
- Proposed mechanism or abstraction
- What must be proven
- What would falsify the argument

### Phase 2: Claim Decomposition

Extract every material claim before writing conclusions. Split broad statements into testable claims.

For example, "this system is lighter than VMs and more isolated than containers" becomes claims about VM overhead, avoided mechanisms, container isolation boundaries, new isolation semantics, measured overhead, and real workloads that need both properties.

Classify CS claims as factual, mechanism, limitation, causal, boundary, TCB, threat, performance, correctness, expressiveness, compatibility, deployability, novelty, or evaluation claims.

### Phase 3: First-Principles Decomposition

For each core claim, decompose:

- Object: code, state, data, resource, interface, protocol, policy, workload, user, or hardware.
- Boundary: process, VM, container, language, API, trust, failure, consistency, transaction, or scheduling boundary.
- Authority: user, application, runtime, kernel, hypervisor, compiler, scheduler, database, or cloud provider.
- Mechanism: type system, scheduler, cache, protocol, replication, isolation, verification, static analysis, runtime check, or other mechanism.
- Baseline: prior system, standard approach, production system, or theoretical model.
- Limitation and root cause.
- Evidence needed.
- Evaluation needed.
- Falsification condition.

### Phase 4: Evidence Search

For each core claim, generate at least three search directions:

- Support query: evidence that could support the claim.
- Counterexample query: evidence that could weaken or refute it.
- Boundary query: definitions, baselines, prior systems, standards, or artifacts.

Use current web research when the user asks for research or citations, when facts may have changed, or when precise source attribution is required. Prefer primary sources: papers, official documentation, standards, source code, artifact repositories, benchmarks, CVEs, advisories, issue trackers, mailing lists, and technical reports.

### Phase 5: Evidence Normalization

Do not paste sources directly into the final conclusion. Normalize each important source:

- What it directly supports.
- What it does not support.
- Applicable scenario and boundary.
- Possible misuse.
- Allowed wording.
- Forbidden wording.
- Evidence level: S, A, B, C, or D.

Main-line claims should not rely on C/D evidence. Use C/D evidence only as leads unless the claim is explicitly low-confidence or speculative.

### Phase 6: Adversarial Critique

Attack the argument like a strong CS reviewer:

- Is the claim overstated?
- Is there a real workload?
- Is the baseline correct?
- Has prior work already solved it?
- Is this only an implementation difference?
- Is a local problem framed as universal?
- Are mechanism, policy, abstraction, and implementation confused?
- Is the threat model clear?
- Are metrics measurable?
- Are tradeoffs and artifacts missing?
- Is the evaluation capable of proving the claim?

### Phase 7: Gap Backlog

Convert each serious critique into a searchable, closable research gap. Avoid vague gaps such as "needs more evidence." Write gaps as concrete questions that can drive the next research round.

### Phase 8: Targeted Re-search

Only re-search around open gaps. Record:

- Objective
- Queries
- Sources found
- Evidence added
- Claims updated
- New attacks
- Continue yes/no with reason

### Phase 9: Claim Revision

Use this state machine:

`unverified -> supported -> weakened -> split -> merged -> deleted -> risk -> final`

Record every keep, weaken, split, merge, delete, or risk decision with reason and remaining risk.

### Phase 10: Evaluation Obligations

Map every final performance, security, correctness, compatibility, expressiveness, deployability, or novelty claim to an evaluation obligation:

- Performance: latency, throughput, utilization, scalability, cost.
- Security: threat model, attack case, bug class, TCB comparison.
- Correctness: proof, model checking, invariant, differential test.
- Compatibility: API coverage, workload coverage, regression suite.
- Expressiveness: case studies, supported patterns, impossible baseline.
- Deployability: code changes, operational complexity, migration cost.

### Phase 11: Convergence Check

Stop only when:

- All core claims have evidence or are marked as risk.
- All high-severity critiques are handled.
- All comparative claims have baselines.
- All performance/security/correctness claims have evaluation obligations.
- Key terms are defined.
- Weak claims are downgraded or deleted.
- The final conclusion explains why the contribution is not merely incremental.

Do not stop if a core claim lacks evidence, a fatal critique remains, the text still uses vague phrases such as "obviously", "many systems", "industry needs", or "fundamentally stronger" without support, workload or baseline is missing, claim strength exceeds evidence, or the mechanism's actual change is unclear.

## Final Output

For substantial tasks, produce:

1. Final Thesis
2. Problem Framing
3. Strong Claims
4. Weakened Claims
5. Deleted Claims
6. Evidence Map
7. Counterexamples and Reviewer Attacks
8. Remaining Risks
9. Evaluation Obligations
10. Paper-ready or Proposal-ready Text
11. Research Trace Appendix

For shorter tasks, keep the same logic but compress the artifacts into concise tables. Use Chinese if the user writes in Chinese unless they request English.

When producing files, use:

- `templates/claim-ledger.md`
- `templates/evidence-ledger.md`
- `templates/critique-ledger.md`
- `templates/research-trace.md`
- `templates/final-report.md`

## Quality Bar

A valid answer must explain the problem, existing baselines, why baselines are insufficient, the root cause, what mechanism or abstraction changes, supporting evidence, counterexamples, weakened or deleted claims, necessary experiments, and a paper-ready/proposal-ready version using only claims that survived the loop.
