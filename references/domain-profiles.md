# Domain Profiles

Load the relevant profile after identifying the CS area. Combine profiles for cross-area work.

## Systems

Focus: abstraction, mechanism, boundary, resource management, performance, compatibility, isolation.

Required questions:

- What is the workload?
- What is the baseline?
- What system boundary changes?
- What resource or state is controlled?
- What overhead is introduced?
- What compatibility is preserved?

Required evaluation: microbenchmark, macrobenchmark, real workload, ablation, stress test.

## Networking

Focus: protocol semantics, congestion, routing, topology, latency, throughput, packet loss, deployability, middleboxes.

Required questions:

- What traffic model and topology are assumed?
- What failure or adversarial network condition matters?
- What existing protocol or deployment path is the baseline?
- What state is kept at endpoints, switches, or controllers?
- What incentives or compatibility barriers affect adoption?

Required evaluation: emulation, testbed, trace-driven simulation, real deployment, fairness and tail-latency analysis.

## Security

Focus: threat model, attacker capability, TCB, attack surface, bug class, exploitability, defense completeness.

Required questions:

- What can the attacker control?
- What is trusted?
- What bug class is prevented or detected?
- What attack remains?
- What is the bypass path?

Required evaluation: attack case study, proof or argument, CVE analysis, fuzzing, red-team evaluation.

## Database And Distributed Systems

Focus: consistency, transactions, replication, recovery, latency, throughput, contention, fault tolerance.

Required questions:

- What consistency model?
- What failure model?
- What workload?
- What contention or skew pattern?
- What recovery guarantee?

Required evaluation: benchmark, fault injection, scalability test, skewed workload, recovery experiment.

## PL And Compiler

Focus: semantics, soundness, type system, optimization correctness, expressiveness, unsafe escape hatches, runtime overhead.

Required questions:

- What property is guaranteed?
- Is there a formal semantics?
- What assumptions are needed?
- Does unsafe or foreign code break the guarantee?
- What programs are expressible?

Required evaluation: theorem, mechanized proof, compiler implementation, benchmark, case study.

## Architecture

Focus: microarchitecture, memory hierarchy, ISA, accelerator design, energy, area, workload representativeness, simulator fidelity.

Required questions:

- What hardware constraint or bottleneck is targeted?
- What workloads and data sizes are representative?
- What baseline architecture and process assumptions are used?
- What tradeoff exists among performance, area, energy, programmability, and compatibility?

Required evaluation: cycle-level simulation, RTL/prototype where possible, energy/area model, sensitivity analysis, real workload suite.

## AI Infrastructure

Focus: scheduling, GPU utilization, memory management, serving latency, distributed training, multi-tenancy, cost.

Required questions:

- What model and workload?
- What hardware and interconnect?
- What traffic distribution?
- What baseline runtime or scheduler?
- What bottleneck is actually removed?

Required evaluation: throughput, p50/p95/p99 latency, utilization, memory pressure, cost per request, scaling behavior.

## Software Engineering

Focus: developer workflow, bug pattern, static/dynamic analysis, testing, maintainability, adoption, human effort.

Required questions:

- What developer pain point?
- What bug class?
- What false positive and false negative rate?
- What benchmark or repository sample?
- What human effort is reduced?

Required evaluation: benchmark suite, case study, user study, precision/recall, real repository analysis.

## HCI And CSCW

Focus: user tasks, interaction cost, collaboration, adoption, human factors, qualitative and quantitative validity.

Required questions:

- Who is the user or stakeholder?
- What task or collaboration pattern changes?
- What baseline workflow is used?
- What confounds affect the study?
- What evidence shows real adoption or improved outcomes?

Required evaluation: controlled user study, field study, qualitative coding, task metrics, longitudinal deployment.
