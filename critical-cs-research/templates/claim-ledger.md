# Claim Ledger

## Trigger

在 **Pass 1: Discovery** 的 Claim Decomposition 和 First-Principles Decomposition 阶段填写。每提取一个实质性主张，追加一行并立即完成其 First-Principles 分解。

## Example

| ID | Claim | Type | Importance | Hidden Assumptions | Required Definitions | Evidence Needed | Status |
|---|---|---|---|---|---|---|---|
| C1 | 本系统冷启动延迟低于 50ms | performance | core | 未定义"冷启动"的测量起点 | 冷启动：从收到请求到返回首字节 | 至少 3 个不同工作负载的 p99 延迟测量 | unverified |
| C2 | 通过 eBPF 拦截比 ptrace 开销更低 | mechanism | core | 假设 eBPF probe 本身无显著调度开销 | eBPF probe 执行时间 | microbenchmark 对比 ptrace 和 eBPF 的上下文切换开销 | unverified |

## Incremental Update Rules

- **追加新主张**：每识别一个新的 claim，在表格底部追加一行，分配递增 ID（C1, C2, ...）。不要覆盖已有行。
- **状态变更时追加记录**：当 claim 状态变化（如 `unverified` → `supported` 或 `weakened`），不要直接修改原行的 Status。可选做法：
  - 在原行更新 Status（保持表格简洁），但必须在 Research Trace 的 Decision Ledger 中记录变更原因；或
  - 追加新行（如 `C2-rev1`）标注新状态，保留原行历史。
- **Split / Merge / Delete 时保留原始 ID**：
  - `split`：原 claim 标记为 `split`，其子 claim 分配新 ID（如 `C2.1`, `C2.2`）。原 claim 仍保留在表格中，不物理删除。
  - `merge`：被合并的 claims 标记为 `merged`，目标 claim 保留并标注合并来源。
  - `delete`：标记为 `deleted`，不删除行，分母计算时排除。
- **禁止物理删除**：任何情况下不得从 Claim Ledger 中删除行。所有历史主张必须可追溯。

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
