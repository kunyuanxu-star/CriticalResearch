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

## Round Accounting

| 模式 | 默认最大 Re-search 轮次 | 配置方式 | 提前收敛阈值 |
|---|---|---|---|
| Lightweight | 0 | 不可配置 | 不适用（无 Re-search） |
| Standard | 1 | 不可配置 | 不适用（通常一轮即完成） |
| Deep | 2 | `--max-research-rounds N` 或启动时询问用户 | 饱和度 ≥80% |

### 轮次计数规则

- **轮次定义**：从 Checkpoint C 决定"额外 Re-search"到再次回到 Checkpoint C 为 1 轮。
- **Pass 2 初始执行不计入 Re-search 轮次**：Re-search 仅指针对性的补充搜索。
- **最大轮次到达时**：强制进入 Final Report，无论饱和度多少。

## Forced-Stop Final Report Wording

当预算耗尽时，Final Report 必须包含以下章节：

```markdown
## Remaining Risks and Open Gaps (Budget-Forced Stop)

由于达到最大 Re-search 预算（N 轮），以下项目未完全关闭，已标记为风险：

- **未验证主张**：...
- **开放差距**：...
- **证据短缺**：...
- **未解决批判**：...

这些风险不影响已完成验证的结论，但限制了本研究的适用范围。
```

## Configurable Defaults

在 Deep 模式启动时，向用户呈现预算配置选项：

```
Deep 模式默认预算：
- 最大 Re-search 轮次：2
- 提前收敛阈值：80%

是否需要调整？[直接回车确认 / 输入 --max-research-rounds N 修改]
```

若用户未响应，使用默认值并继续。
