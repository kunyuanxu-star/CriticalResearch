# Evidence Standards

Use this reference when assigning evidence levels or verifying CS research claims.

## Evidence Levels

- `S`: top-tier paper or journal article, formal standard, official system documentation, reproducible artifact, CVE/security advisory, authoritative benchmark, accepted artifact evaluation, or formal proof for a formal claim.
- `A`: high-quality paper, mainstream project documentation, production technical report, public issue or mailing-list discussion by maintainers, incident report, or well-described engineering postmortem.
- `B`: vendor blog, developer blog, community discussion, informal benchmark, conference talk, or non-peer-reviewed technical note with enough detail to inspect assumptions.
- `C`: ordinary article, tutorial, press release, marketing page, or lightly sourced summary.
- `D`: user intuition, model inference, unsourced anecdote, or speculative reasoning.

Main-line research claims should be supported by S/A evidence where possible. B evidence can contextualize or motivate. C/D evidence should be treated as search leads or clearly labeled speculation.

## Preferred CS Sources

Prioritize sources closest to the claim:

- Papers and artifacts: OSDI, SOSP, NSDI, EuroSys, ASPLOS, USENIX ATC, FAST, SIGCOMM, CCS, IEEE S&P, USENIX Security, NDSS, PLDI, POPL, OOPSLA, SIGMOD, VLDB, ICDE, ISCA, MICRO, HPCA, MLSys, and associated artifact repositories.
- Official materials: language specs, RFCs, standards, Linux/Kubernetes/Rust/LLVM/PostgreSQL/MySQL/TensorRT/vLLM/Ray docs, release notes, migration guides, API docs, design docs.
- Engineering evidence: source code, tests, benchmarks, issue trackers, mailing lists, CVE/NVD records, security advisories, incident reports, traces, workloads, reproduction scripts.
- Independent validation: replication studies, artifact evaluations, public benchmarks with methodology, postmortems, and production case studies.

Avoid treating tutorials, Stack Overflow answers, README marketing claims, synthetic demos, or unsourced benchmark charts as decisive evidence.

## Match Evidence To Claim Type

- Algorithmic complexity: require proof, derivation, textbook, or paper. Separate asymptotic behavior from real workload performance.
- Performance: require benchmark setup, hardware, runtime versions, data size, workload, warmup, concurrency, variance, and baseline.
- Scalability: require bottleneck analysis, load model, resource limits, backpressure behavior, failure modes, and operational evidence where possible.
- Security: require threat model, attacker capability, trust boundary, vulnerability class, mitigation status, and whether the claim concerns prevention, detection, or risk reduction.
- Correctness: require specification, semantics, invariant, proof, model checking, tests, or differential validation.
- AI/ML or AI infrastructure: require model/version, dataset, workload distribution, hardware, metrics, evaluation protocol, baselines, leakage checks, utilization, and error analysis.
- API/tooling: require official docs, source, tests, or release notes for version-specific behavior.
- Architecture: require workload, non-functional requirements, tradeoffs, operational constraints, failure handling, and alternatives.
- Cost: require pricing date, region, usage assumptions, traffic/storage/egress model, and sensitivity analysis.

## Evidence Normalization Fields

- Evidence ID
- Source and link
- Source type
- Evidence level
- Related claims
- Relation: supports, weakens, contextualizes, or contradicts
- Direct support
- Limits
- Applicable scenario
- Allowed wording
- Forbidden wording
