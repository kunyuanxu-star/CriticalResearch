# Evaluation Contracts

A paper claim must be matched with the right evidence type. A claim is weak if its evidence type does not match its claim type.

## Claim Type → Evidence Type

| Claim Type | Required Evidence | Examples |
|-----------|------------------|----------|
| Performance | Benchmarks, workloads, latency, throughput, resource use, scalability curves | SPEC, TPC, YCSB, custom workloads |
| Accuracy | Dataset, metric, baseline, ablation, error analysis, statistical significance | Train/test split, F1, confidence intervals |
| Security | Threat model, adversary capability, attack evaluation, security proof, false positives/negatives | Adversary model, CVE benchmarks, formal security argument |
| Correctness | Formal proof, mechanized proof, invariant, testing, equivalence, model checking | Coq/Lean mechanization, property-based testing |
| Usability | User study, task design, population, measurement, qualitative coding, statistical analysis | N participants, task completion time, SUS scores |
| Expressiveness | Representative examples, coverage, case studies, comparison to alternatives | Coverage metrics, case diversity analysis |
| Scalability | Growth dimension, load stress, asymptotic trend, bottleneck analysis | Scale-out curves, Amdahl analysis, bottleneck profiling |
| Generality | Multiple domains, datasets, workloads, tasks, languages, or settings | Cross-domain benchmarks, multi-dataset validation |
| Theoretical | Definitions, theorem, proof, assumptions, comparison to known bounds | Proof sketch or full mechanization |
| Measurement | Methodology, data source, bias control, reproducibility, confounder analysis | Measurement methodology, data collection pipeline |
| Causal | Controlled comparison, ablation, intervention, alternative explanation analysis | A/B tests, ablation studies, counterfactual analysis |
| Design | Design rationale, ablation, case study, user or system evidence, failure mode analysis | Design alternatives comparison, rationale documentation |

## Mismatch Examples

- A security claim cannot be supported only by performance data.
- A usability claim cannot be supported only by anecdotal examples.
- A generality claim cannot be supported by one dataset.
- A correctness claim cannot be supported only by empirical success.
- A performance claim cannot be supported only by design intuition.

## Baseline Selection

The baseline must be the strongest competing approach for the claim being made. Baselines can be: prior systems, algorithms, models, theorems, tools, datasets, explanations, user interfaces, measurement methods, simple heuristics, human experts, or the status quo. Never compare against a weak baseline to make the contribution appear stronger.
