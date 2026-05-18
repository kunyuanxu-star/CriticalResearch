# Gap Backlog

## Trigger

在 **Pass 2: Validation** 的 Adversarial Critique 之后填写。每个严重 critique（severity ≥ medium）必须转化为一个可搜索、可关闭的 Gap。此 Ledger 是 Checkpoint C 的核心呈现材料，驱动 Pass 3 的 Targeted Re-search。

## Example

| Gap ID | From Critique | Missing Information | Research Question | Priority | Closure Condition |
|---|---|---|---|---|---|
| G1 | A1（overclaim） | 未在真实云原生工作负载上测试 | 该机制在 Kubernetes 微服务场景下的 tail-latency 影响是否可忽略？ | high | 提供至少一个真实部署的 benchmark，对比基线为默认 Linux CFS |
| G2 | A3（missing_baseline） | 未与 Firecracker 对比 | 在相同冷启动工作负载下，本方案与 Firecracker 的启动延迟差异是否在 10ms 以内？ | medium | 引用 Firecracker 官方 benchmark 或复现实验数据 |

## Incremental Update Rules

- **追加而非删除**：每个 Re-search 轮次结束后，追加新行记录本轮关闭或新发现的 Gap。已关闭的 Gap 将状态改为 `closed`，不要从表格中物理删除。
- **与 Critique Ledger 的双向链接**：每个 Gap 的 `From Critique` 字段必须对应 Critique Ledger 中的一个有效 ID（A1, A2, ...）。反过来，Critique Ledger 中每个 severity ≥ medium 的 critique 必须在此 Backlog 中有对应的 Gap ID。
- **优先级动态调整**：随着证据积累，某些 Gap 的优先级可能变化。追加新行标注更新后的优先级，并说明原因。
- **关闭条件必须可验证**：Closure Condition 应使用可量化的标准（如"提供 X 的 benchmark"、"引用 Y 的论文"），避免模糊措辞如"需要更多研究"。

## Template

| Gap ID | From Critique | Missing Information | Research Question | Priority | Closure Condition |
|---|---|---|---|---|---|
| G1 | A1 |  |  | low / medium / high / critical |  |
