# Critique Ledger

## Trigger

在 **Pass 2: Validation** 的 Adversarial Critique 阶段填写。每个 critique 对应一个攻击角度，severity ≥ medium 的 critique 必须在 Gap Backlog 中有对应的 Gap ID。

## Example

| ID | Target Claim | Critique Type | Severity | Critique | Required Follow-up | Linked Gap |
|---|---|---|---|---|---|---|
| A1 | C1 | overclaim | high | "低于 50ms" 未说明硬件配置和并发度；在 1vCPU 虚拟机上的 50ms 与 bare-metal 不可比 | 补充实验设置细节；或在 claim 中限定部署环境 | G1 |
| A2 | C2 | missing_baseline | medium | 未与最新版本的 seccomp-bpf 对比，后者在 Linux 5.15+ 中已大幅优化 | 补充 seccomp-bpf 基线实验 | G2 |

## Incremental Update Rules

- **双向链接 Gap Backlog**：每个 severity ≥ medium 的 critique **必须**在 `templates/gap-backlog.md` 中有对应的 Gap ID。若暂时无法转化，标注 `linked_gap: PENDING` 并在 1 轮 Re-search 内补齐。
- **追加而非覆盖**：新的 critique 追加到表格底部。若对同一 claim 的 critique 在 Re-search 后被解决，追加新行标注 `resolved`，不要删除原始 critique。
- **Severity 动态调整**：随着证据积累，某些 critique 的 severity 可能变化（如从 high 降为 medium）。追加新行标注更新后的 severity，并引用导致变化的证据 ID。

## Template

| ID | Target Claim | Critique Type | Severity | Critique | Required Follow-up | Linked Gap |
|---|---|---|---|---|---|---|
| A1 | C1 | overclaim / missing_baseline / missing_workload / ambiguous_definition / weak_causality / alternative_solution / unproven_generality / evaluation_gap / artifact_gap | low / medium / high / fatal |  |  | G1 |

## Template

| ID | Target Claim | Critique Type | Severity | Critique | Required Follow-up |
|---|---|---|---|---|---|
| A1 | C1 | overclaim / missing_baseline / missing_workload / ambiguous_definition / weak_causality / alternative_solution / unproven_generality / evaluation_gap / artifact_gap | low / medium / high / fatal |  |  |
