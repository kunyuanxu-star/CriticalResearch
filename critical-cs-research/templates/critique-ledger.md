# Critique Ledger

## Trigger

在 **Pass 2: Validation** 的 Adversarial Critique 阶段填写。每个 critique 对应一个攻击角度，severity ≥ medium 的 critique 必须在 Gap Backlog 中有对应的 Gap ID。

## Severity Operationalization Standards

每条 critique 必须严格按照以下标准评定 severity，不得使用直觉判断：

| Severity | 定义 | 触发条件 | 后果 |
|---|---|---|---|
| **fatal** | 该主张在当前形式下无法成立 | 核心假设被证伪 / 反例直接覆盖主张范围 / 关键基线根本性错误 / 评估方法无法证明所述属性 | 主张必须 marked_as_risk 或 deleted |
| **high** | 主张的当前表述严重过度，或缺少关键验证 | 无真实工作负载 / 无基线对比 / 泛化声明无边界条件 / 指标与主张不匹配 | 主张必须 weakened 或 split，且必须生成对应的 Gap |
| **medium** | 主张可能成立但支撑不足 | 证据级别不足（B/C 级支撑 core claim）/ 边界条件未探索 / 实验设置存在 confound | 必须生成对应 Gap 并在 Re-search 中关闭 |
| **low** | 表述歧义或次要遗漏 | 术语未定义但可推断 / 次要 tradeoff 未讨论 / 边缘场景未覆盖但不影响核心结论 | 记录在案，不强制生成 Gap，但 Final Report 中需标注 |

## Critique Type 枚举

| Type | 说明 | 常见于 |
|---|---|---|
| `overclaim` | 主张强度超过证据强度 | 泛化声明无边界条件、量化声明无误差棒 |
| `missing_baseline` | 缺少关键基线对比 | 未与最强现有方案对比、基线配置不公 |
| `missing_workload` | 工作负载不真实或不具代表性 | 仅测试合成负载、未覆盖 adversarial 场景 |
| `ambiguous_definition` | 关键术语未操作化定义 | 度量起点/终点不明确、比较对象不可比 |
| `weak_causality` | 因果关系未建立 | 相关性当作因果、未控制混淆变量 |
| `alternative_solution` | 存在更简单或已知的替代方案 | 非技术方案被忽略、更简单方案未对比 |
| `unproven_generality` | 局部结论泛化为全局结论 | 单一配置结果推广到所有场景 |
| `evaluation_gap` | 评估方法与主张不匹配 | 指标不度量所声称的属性、缺少关键指标 |
| `artifact_gap` | 缺少可验证的工件 | 代码/数据/模型不可获取 |
| `methodology_flaw` | 实验方法存在缺陷 | 无对照组、未控制混淆变量、统计方法错误 |
| `dependency_break` | 主张依赖链断裂 | 前置主张被削弱导致后续主张不成立 |
| `missing_tradeoff` | 未报告关键 tradeoff | 只报喜不报忧、忽略复杂度/兼容性代价 |
| `circular_reasoning` | 循环论证 | 结论预设了前提、评估仅度量被设计来优化的指标 |

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
|---|---|---|---|---|---|---|---|
| A1 | C1 | overclaim / missing_baseline / missing_workload / ambiguous_definition / weak_causality / alternative_solution / unproven_generality / evaluation_gap / artifact_gap / methodology_flaw / dependency_break / missing_tradeoff / circular_reasoning | low / medium / high / fatal |  |  | G1 |
