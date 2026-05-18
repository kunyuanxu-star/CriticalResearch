# Critique Ledger

## Trigger

在 **Pass 2: Validation** 的 Adversarial Critique 阶段填写。每个 critique 对应一个攻击角度，severity ≥ medium 的 critique 必须在 Gap Backlog 中有对应的 Gap ID。

## Example

| ID | Target Claim | Critique Type | Severity | Critique | Required Follow-up |
|---|---|---|---|---|---|
| A1 | C1 | overclaim | high | "低于 50ms" 未说明硬件配置和并发度；在 1vCPU 虚拟机上的 50ms 与 bare-metal 不可比 | 补充实验设置细节；或在 claim 中限定部署环境 |
| A2 | C2 | missing_baseline | medium | 未与最新版本的 seccomp-bpf 对比，后者在 Linux 5.15+ 中已大幅优化 | 补充 seccomp-bpf 基线实验 |

## Template

| ID | Target Claim | Critique Type | Severity | Critique | Required Follow-up |
|---|---|---|---|---|---|
| A1 | C1 | overclaim / missing_baseline / missing_workload / ambiguous_definition / weak_causality / alternative_solution / unproven_generality / evaluation_gap / artifact_gap | low / medium / high / fatal |  |  |
