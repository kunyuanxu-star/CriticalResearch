# Deep Mode Role-Lens Execution Instructions

## Trigger

仅在 **Deep 模式** 的 **Pass 2: Validation** 阶段使用。Standard 和 Lightweight 模式跳过此文件，按顺序执行 Pass 2 即可。

## User Permission Check (Mandatory)

在启动任何并行 Role-Lens 之前，必须向用户说明：

> "Deep 模式建议启用并行 Role-Lens（Claim Parser / Research Scout / Counterexample Finder / Adversarial Reviewer）以加速验证。这需要启动多个分析 Agent。是否允许？"

- **若用户允许**：使用 `Agent` 工具并发启动各 Lens（见下方 Concurrent Execution）。
- **若用户拒绝或平台不支持并发 Agent**：使用 **Non-Subagent Fallback**（见下方），在同一 Agent 上下文中按顺序执行 Lens passes，但保留相同的输出格式和 Merge Rules。

## Concurrent Execution (User Allowed)

并发限制：最多 3 个 Lens 同时运行（避免上下文爆炸）。推荐分组：

- **Group 1**: Research Scout + Counterexample Finder（两者独立搜索，互不依赖）
- **Group 2**: Adversarial Reviewer（基于 Claim Ledger 和已有证据进行预判 critique，可在 Group 1 开始后 30 秒或首轮证据返回后启动）

Claim Parser 已在 Pass 1 完成，无需重复。

### Lens Prompts

#### Research Scout

```
你是一名研究侦察员。你的唯一任务是：针对给定的 Claim Ledger，为每个核心主张搜索支持证据、反例和边界定义。

输入：Claim Ledger（仅 core claims）
输出格式：Evidence Ledger 的初始条目，每条证据必须包含 Source、Type、Level（预评估）、Related Claim、Relation。
约束：
- 不要写结论。
- 不要评价主张真假。
- 仅输出可归一化的证据条目。
```

#### Counterexample Finder

```
你是一名反例寻找员。你的唯一任务是：针对给定的 Claim Ledger，寻找可能削弱、反驳或限定每个核心主张的先前工作、边缘案例和替代方案。

输入：Claim Ledger + Domain Profile（如有）
输出格式：Counterexample Ledger 条目，每条包含：Target Claim、Counterexample / Prior Work / Alternative、Source、Effect On Claim（weakens / contradicts / narrows / contextualizes）。
约束：
- 优先寻找 OSDI/SOSP/NSDI/SIGCOMM/PLDI/POPL 等顶会论文。
- 明确说明反例适用的边界条件。
- 不要输出结论性判断。
```

#### Adversarial Reviewer

```
你是一名顶级 CS 审稿人。你的唯一任务是：基于当前的 Claim Ledger 和已收集的证据（如有），对论点进行系统性攻击。

输入：Claim Ledger +（可选）初步证据摘要
输出格式：Critique Ledger 条目，每条包含：Target Claim、Critique Type、Severity、Critique、Required Follow-up。
约束：
- 关注 overclaim、missing baseline、missing workload、evaluation gap。
- 每个 severity ≥ medium 的 critique 必须对应一个可关闭的研究问题。
- 不要提出修复建议，只提出攻击。
```

## Non-Subagent Fallback (User Denied or Platform Limited)

若无法启动真实 subagents，在同一 Agent 中按以下顺序执行 Lens passes：

1. **Pass 2a - Research Scout pass**: 模拟 Research Scout，输出 Evidence Ledger 草稿。
2. **Pass 2b - Counterexample Finder pass**: 模拟 Counterexample Finder，输出 Counterexample Ledger。
3. **Pass 2c - Adversarial Reviewer pass**: 基于 2a 和 2b 的结果，模拟 Adversarial Reviewer，输出 Critique Ledger。

每个 pass 的输入输出格式与并发模式完全相同。在 Final Report 的 Research Trace 中标注 `"execution_mode: sequential_fallback"`。

## Merge Rules (Mandatory)

无论并发还是顺序执行，Pass 2 结束后必须按以下顺序合并：

1. **Normalize Evidence**: 将 Research Scout 和 Counterexample Finder 的所有证据条目统一归一化（Evidence Normalization 字段）。冲突证据（同一主张既有支持又有削弱）保留两条，标注 `relation: contradicts`，不自动仲裁。
2. **Merge Counterexamples**: 将 Counterexample Ledger 中的反例按 Target Claim 分组，并入 Evidence Ledger 的对应条目下，标注 `relation: weakens / contradicts / narrows / contextualizes`。
3. **Merge Critiques**: 将 Adversarial Reviewer 的 critique 按 Target Claim 分组，写入 Critique Ledger。若 critique 与 Counterexample 重叠（针对同一主张的同一弱点），合并为一条 critique，标注双重来源（`sources: adversarial_review + counterexample_finder`）。
4. **Compute Saturation Once**: 由 Evidence Auditor（可作为单独 pass 或内置步骤）统一计算饱和度：
   - 分子：拥有 ≥A 级证据且无未解决 fatal/high critique 的 core claims 数量。
   - 分母：总 core claims 数量（不含 deleted）。
   - 被 weakened 的 claim 仍计入分母，但分子仅统计 supported 或 weakened（有 A 级证据）的 claim。
5. **Write Raw Traces**: 每个 Lens 的原始输出（未合并前的完整文本）必须写入 Research Trace Appendix，作为独立章节（`## Raw Lens Output: Research Scout` 等）。

## Anti-Duplication Rules

- **证据冲突不重复计数**：同一来源被两个 Lens 引用时，只计为一个证据条目，但保留两个 Lens 的独立评估注释。
- **Critique 不可丢弃**：Adversarial Reviewer 的 critique 必须全部进入 Critique Ledger。Synthesis Writer 不得在未记录理由的情况下丢弃任何 critique。
- **饱和度不可由各 Lens 自行计算**：仅由 Evidence Auditor 在 Merge 后统一计算并公布。
