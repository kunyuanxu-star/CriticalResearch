# Budget Guide

## Saturation Formula

证据饱和度（Evidence Saturation）是决定是否提前收敛的核心指标。

```
饱和度 = (拥有 ≥A 级证据且无未解决 fatal/high critique 的 core claims 数量)
         ─────────────────────────────────────────────────────────────────
         (总 core claims 数量，不含已删除的 claims)
```

### 分子规则

- **计入**：状态为 `supported` 或 `weakened`，且至少有一个 ≥A 级证据，且 Critique Ledger 中无针对该 claim 的未解决 fatal/high severity 条目。
- **不计入**：状态为 `unverified`、`deleted`、`risk`（无 A 级证据）、或存在未解决 fatal/high critique 的 claim。
- **特殊**：若 claim 被 `split`，每个子 claim 单独计算；原 claim 不再计入。

### 分母规则

- 始终使用当前活跃的 core claims 总数（含 `supported`、`weakened`、`unverified`、`risk`）。
- 不含 `deleted` 和 `merged` 的 claims。

### 计算示例

| Claim | Status | Best Evidence | Unresolved Critique | Counted in Numerator? |
|---|---|---|---|---|
| C1 | supported | A | 无 | ✅ 是 |
| C2 | weakened | A | medium（已计划修复） | ✅ 是 |
| C3 | unverified | B | 无 | ❌ 否（证据级别不足） |
| C4 | supported | S | high（未解决） | ❌ 否（存在未解决 high critique） |
| C5 | deleted | - | - | ❌ 否（已删除，不计入分母） |

- 分母 = 4（C1, C2, C3, C4）
- 分子 = 2（C1, C2）
- 饱和度 = 2/4 = 50%

## Round Accounting (Advisory Only)

**核心规则已变更**：所有轮次和阈值均为**建议性指标**，用于跟踪进度而非强制停止。唯一退出条件是用户明确表示满意（见 SKILL.md §3.5 Convergence Check）。

| 模式 | 建议首轮深度 | 参考饱和度 |
|---|---|---|
| Lightweight | 首轮内部知识为主 | 供参考，不强制 |
| Standard | 首轮 1 次搜索 | 供参考，不强制 |
| Deep | 首轮深度搜索 + 并发 Role-Lens | 供参考，不强制 |

### 轮次计数规则

- **轮次定义**：从用户提出新反驳或新 Gap 到再次回到 User Satisfaction Gate 为 1 轮。
- **Pass 2 初始执行计为 Round 1**。
- **无最大轮次限制**：只要用户未被说服，持续循环。

## Saturation as Progress Indicator (Not Stop Condition)

证据饱和度是向用户汇报进度的指标，不是停止条件：

```
饱和度 = (拥有 ≥A 级证据且无未解决 fatal/high critique 的 core claims 数量)
         ─────────────────────────────────────────────────────────────────
         (总 core claims 数量，不含已删除的 claims)
```

- 饱和度 ≥80%：告知用户"分析已达发布级深度"，但用户仍可要求继续。
- 饱和度 <80%：告知用户当前薄弱点，建议继续深挖方向。

## Configurable Defaults (Deprecated)

~~在 Deep 模式启动时，向用户呈现预算配置选项。~~ 该机制已被 User Satisfaction Gate 取代。不再需要 --max-research-rounds 配置。若用户明确要求设置硬性预算上限，可例外启用。
