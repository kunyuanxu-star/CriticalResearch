# Story Self-Check Checklist

## Trigger

在 **Pass 3: Convergence** 的 Logic Audit (§3.6) 阶段使用。在生成 Final Report 之前，必须逐条通过此清单。**任何答案为"否"的条目，必须在 Final Report 中显式标记为 `[STORY-GAP: 具体问题]`，并回到对应 Pass 阶段修复后重新审计。**

## 17-Point Self-Check

### 问题定义

| # | 问题 | 通过标准 | 状态 |
|---|---|---|---|
| 1 | 核心问题能否一句话说清楚？ | 问题句包含：场景 + 现有方法 + 失效假设 + 需要同时满足的性质 | |
| 2 | 场景是否具体到 actor, object, boundary, lifecycle？ | 每个概念都有明确的定义边界 | |
| 3 | Challenge 是否来自矛盾，而不是来自功能需求？ | Challenge 描述的是"不可兼得"，不是"需要支持某功能" | |
| 4 | 每个 challenge 是否有 strawman？ | 至少两个对立 strawman，每个的失败模式具体可解释 | |
| 5 | 每个 strawman 的失败是否具体？ | 失败落在一个具体可验证的指标或性质破坏上 | |
| 6 | 是否归纳出了共同 root cause？ | Root cause 解释了两个 strawman 为何同时失败 | |

### 洞见与设计

| # | 问题 | 通过标准 | 状态 |
|---|---|---|---|
| 7 | Insight 是否直接回应 root cause？ | Insight 描述了"重新组织问题"的动作，而不是"使用 X 技术" | |
| 8 | Design 是否由 insight 推导，而不是组件堆叠？ | 每个 design component 都能回答：解决哪个 challenge、利用哪个 insight、维持哪个 invariant | |
| 9 | 每个机制是否能说明"删掉会怎样"？ | 删除后会导致某个性质被破坏或某个 metric 恶化 | |

### 评估

| # | 问题 | 通过标准 | 状态 |
|---|---|---|---|
| 10 | Primary metric 是什么？ | 明确 1-2 个核心指标，直接对应核心 claim | |
| 11 | Baseline 是否是 reviewer 会认可的最强 baseline？ | Baseline 公平配置，包含最新版本，不选稻草人 | |
| 12 | Ablation 是否证明 insight？ | Ablation 去掉了 insight 对应的机制，证明性能或安全性下降 | |

### 表达

| # | 问题 | 通过标准 | 状态 |
|---|---|---|---|
| 13 | Title 是否准确覆盖贡献？ | Title 每个词都能在正文中被定义和证明 | |
| 14 | 术语是否都被定义？ | 每个术语满足：反复出现、边界清楚、参与推理、非已有术语的模糊替代 | |
| 15 | Non-goal 是否诚实？ | 明确列出本文不声称、不解决、不适用的范围 | |
| 16 | 是否提前写出了 reviewer 的攻击和 defence？ | 至少覆盖 12 种常见攻击，每种有具体 defence | |
| 17 | 读者能从工作中学到什么一般性思想？ | 能写出一句"design lesson"，可迁移到相邻问题 | |

## Writing Rules Audit

以下规则检查 Final Report 中 Paper-Ready Text 的写作质量：

### 禁止项

| # | 规则 | 检查方法 |
|---|---|---|
| W1 | 不写"我们实现了……"开头的贡献列表 | 贡献句必须以"我们提出了/发现了/证明了"开头 |
| W2 | 不使用口号式形容词（高效/轻量/灵活/安全/自动化） | 每个形容词必须有对应的可度量指标 |
| W3 | 不使用"我们认为/可能/可以/有望" | 能证明直接说，不能证明明确限定条件 |
| W4 | 摘要不写成系统功能列表 | 摘要必须包含：背景 gap insight 系统 结果 |
| W5 | 引言不过早进入 implementation | 引言先讲 why（gap/challenge），再讲 how（design） |
| W6 | 设计不"顺序介绍模块" | 设计按"问题→机制"组织，每个机制前先说明要解决什么 |
| W7 | 相关工作不写成文献综述 | 相关工作按"设计哲学"分组，每组的结论是"为什么不能覆盖你的场景" |

### 必须项

| # | 规则 | 检查方法 |
|---|---|---|
| W8 | 每段只表达一个逻辑动作 | 段落不混合背景、gap、solution、evaluation |
| W9 | 所有强 claim 都有证据出口 | 每个 claim 可追溯到 Evidence Map 中的 A 级+证据 |
| W10 | Title 比贡献小或等大，不虚 | Title 每个词有定义、有证明 |
| W11 | 包含 One-Sentence Thesis | 问题句 + 洞见句 + 系统句，三句成链 |

## One-Sentence Thesis Template

```
问题句：在场景 S 中，现有方法无法同时满足 P1 和 P2，因为它们依赖假设 A，而该假设在 S 中失效。

洞见句：我们观察到，虽然完整解决 X 很困难，但在条件 C 下，只需要维护性质 B，就足以保证目标 G。

系统句：基于这一观察，我们设计 D，将原本需要……的问题转化为……，从而在 M 指标上优于现有方法。
```

## Story Closure Table

| Challenge | Insight Part | Design Component | Invariant | Experiment | Metric | Status |
|---|---|---|---|---|---|---|
| C1: ... | I1: ... | D1: ... | Inv1: ... | Exp1: ... | M1: ... | closed / gap |
| C2: ... | I2: ... | D2: ... | Inv2: ... | Exp2: ... | M2: ... | closed / gap |

规则：
- 每个 challenge 找不到 evaluation → 空话
- 每个 design component 找不到 challenge → 噪声
- 每个 evaluation 找不到 claim → 无关实验
- 每个 claim 找不到 metric → 不可证明

## Reviewer Attack Pre-Writing Table

| # | Attack | 你的 Defence | Defence 是否可验证 |
|---|---|---|---|
| 1 | 这个问题真实存在吗？ | | |
| 2 | 为什么现有方法不能直接解决？ | | |
| 3 | 你的场景是不是人为构造的？ | | |
| 4 | 你的假设是不是太强？ | | |
| 5 | 你的 threat model 是否回避了最难的问题？ | | |
| 6 | 你的设计是否只是工程组合？ | | |
| 7 | 你的 insight 是否只是换了个说法？ | | |
| 8 | 你的实验是否只选了对你有利的 case？ | | |
| 9 | 你的 baseline 是否公平？ | | |
| 10 | 你的指标是否证明了 claim？ | | |
| 11 | 你的机制是否引入了新的问题？ | | |
| 12 | 你的贡献是否可以推广？ | | |

## Minimum Proof System Check (MVP Mindset)

在每一轮迭代中检查：

- 当前轮次要证明的**唯一 claim** 是什么？
- 当前场景是否**最能暴露核心矛盾**（而非最简单的 toy example）？
- Baseline 是否**能区分**你的方法和最自然方案？
- 指标是否包含：**核心收益 + 底线性质 + 代价**？
- 成功阈值是否**在实验前定义**？
- Non-goal 是否**明确列出**？
- 当前结论是：**支持 / 不支持 / 还无法判断**？
