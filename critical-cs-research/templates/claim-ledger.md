# Claim Ledger

## Trigger

在 **Pass 1: Discovery** 的 Claim Decomposition 和 First-Principles Decomposition 阶段填写。每提取一个实质性主张，追加一行并立即完成其 First-Principles 分解。

## Example

| ID | Claim | Type | Importance | Hidden Assumptions | Required Definitions | Evidence Needed | Status |
|---|---|---|---|---|---|---|---|
| C1 | 本系统冷启动延迟低于 50ms | performance | core | 未定义"冷启动"的测量起点 | 冷启动：从收到请求到返回首字节 | 至少 3 个不同工作负载的 p99 延迟测量 | unverified |
| C2 | 通过 eBPF 拦截比 ptrace 开销更低 | mechanism | core | 假设 eBPF probe 本身无显著调度开销 | eBPF probe 执行时间 | microbenchmark 对比 ptrace 和 eBPF 的上下文切换开销 | unverified |

## Template

| ID | Claim | Type | Importance | Hidden Assumptions | Required Definitions | Evidence Needed | Status |
|---|---|---|---|---|---|---|---|
| C1 |  | factual / mechanism / limitation / causal / boundary / TCB / threat / performance / correctness / expressiveness / compatibility / deployability / novelty / evaluation | core / supporting |  |  |  | unverified |

## First-Principles Decomposition

### Claim C1

Original:

Subclaims:

- SC1.1
- SC1.2

Object:

Boundary:

Authority:

Mechanism:

Baseline:

Limitation:

Root cause:

Evidence needed:

Evaluation needed:

Falsification condition:
