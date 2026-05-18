---
name: critical-cs-research
description: A domain-general but computer-science-specific critical research loop for OS, networking, security, databases, PL/compilers, architecture, AI infrastructure, distributed systems, software engineering, HCI/CSCW, and technical systems work. Use when Codex must validate a CS research idea, paper motivation, related-work critique, system design, experiment plan, rebuttal, survey, architecture decision, security analysis, or performance diagnosis by decomposing claims, grounding evidence, finding counterexamples, generating research gaps, re-searching, revising claims, mapping evaluation obligations, and producing evidence-backed conclusions.
---

# Critical CS Research

## Core Rule

Do not directly polish or defend the user's original idea. Run the research control loop **indefinitely until the user is convinced**:

`Problem -> Claim -> Assumption -> Evidence -> Counterexample -> Gap -> Re-search -> Revision -> Decision -> Rebuttal -> Re-search -> ... -> User Convinced? No → loop. Yes → stop.`

**Hard rule**: The process does NOT stop because a budget expired, a saturation threshold was met, or a maximum round count was reached. The ONLY valid exit condition is the user explicitly stating they are satisfied with the analysis. If the user expresses any dissatisfaction, identifies a missing angle, provides a new rebuttal, or says anything other than a clear "yes, I'm convinced" — the loop continues.

The final answer must preserve the trace from each conclusion back to claims, evidence, counterexamples, critiques, and decisions. Allow the original idea to be weakened, reframed, marked as risk, or deleted.

## When Starting

1. Identify the task type: idea validation, paper motivation, related-work critique, system design review, experiment planning, rebuttal preparation, survey construction, architecture decision, security analysis, or performance diagnosis.
2. Identify the CS area: systems, networking, security, database, PL/compiler, architecture, software engineering, AI infrastructure, distributed systems, or HCI/CSCW.
3. Read `references/domain-profiles.md` for the relevant profile when the area is clear or when profile-specific checks matter.
4. Read `references/evidence-standards.md` before doing source-backed research or assigning evidence levels.
5. Read `references/role-lenses.md` when the task is large enough to benefit from separate parsing, scouting, counterexample, review, audit, experiment, and synthesis passes.
6. Use `templates/*.md` when the user asks for reusable artifacts, files, or exhaustive output.
7. Use `hooks/run-checkpoint.sh <stage>` to validate artifacts at each checkpoint (pass1 / pass2 / rebuttal / convergence / all). Hooks enforce the quality bar before proceeding to the next stage.

If the user has not provided material, ask for it. If target venue, audience, or output form is missing, infer a reasonable default and state it briefly.

## Required Workflow

### Mode Selection (Triage)

根据用户输入的复杂度、主张数量和目标深度，在启动时选择执行模式。如果用户未指定，根据以下标准自动选择或询问。**所有模式的循环次数无上限，用户未被说服则永不停止**：

| 模式 | 适用场景 | 核心主张数 | 建议初始深度 | 外部证据 | 输出粒度 |
|---|---|---|---|---|---|
| **Lightweight** | 快速验证、想法初筛、已有明确结论的复核 | ≤3 | 首轮内部知识为主 | 不搜索 | 压缩检查清单（3-5 项） |
| **Standard** | 常规研究、设计评审、实验计划 | 4-10 | 首轮 1 次搜索 | 需要搜索 | 标准表格 + 简短报告 |
| **Deep** | 投稿级审稿、完整 rebuttal、架构决策 | >10 或不明确 | 首轮深度搜索 + 并发 Role-Lens | 深度搜索 + 并发 | 完整 Ledger + 详细报告 |

Lightweight 模式在用户要求深入时自动升级为 Standard 或 Deep。

#### Legacy 11-Phase Mode

当用户明确要求"按旧流程执行"或"使用原始 Phase 顺序"时，运行原有的线性 11-Phase 序列（Phase 0 → 11）。此时三个 Checkpoint 映射为：

- **Checkpoint A** = Phase 1（Problem Framing）结束后
- **Checkpoint B** = Phase 2（Claim Decomposition）结束后
- **Checkpoint C** = Phase 6（Adversarial Critique）结束后

Legacy 模式仍受 Budget Control 约束，但保留完整的 Phase 0-11 编号以便用户对照旧文档。

### Pass 1: Discovery

整合问题定义、主张分解和第一性原理分析。目标是建立研究对象的结构化蓝图，**不急于搜索或下结论**。

**1.1 Task Initialization**

输出紧凑的初始化块：

- Task type
- CS area
- Target output
- Target venue or rigor level
- Main risk
- Initial hypothesis

**One-Sentence Thesis（强制）**：在初始化完成后，立即写出三句话，作为整个研究论证的锚点。这三句话是活的——随着循环迭代可能被修正，但任何时刻都必须存在。

```
问题句：在场景 S 中，现有方法无法同时满足 P1 和 P2，因为它们依赖假设 A，而该假设在 S 中失效。

洞见句：我们观察到，虽然完整解决 X 很困难，但在条件 C 下，只需要维护性质 B，就足以保证目标 G。

系统句：基于这一观察，我们设计 D，将原本需要……的问题转化为……，从而在 M 指标上优于现有方法。
```

**三句话的质量标准**：
- 问题句必须包含：场景 + 需同时满足但冲突的性质 + 现有方法共享的失效假设。
- 洞见句必须包含：一个"重新组织问题"的动作（把运行时变规划时、把全局拆局部、把精确变上界、把同步变异步、把必须检查所有变只检查例外）。
- 系统句必须包含：核心设计 + 关键指标 + 相对于 baselines 的优势方向。
- 三句话连读必须形成一个完整的逻辑闭环：为什么难→为什么可以绕开→怎么绕开。

三句话写入 `research-trace.md` 的 Problem Object 中。每轮迭代后检查：三句话是否仍然准确？是否需要 weaken、narrow 或 reframe？

**1.2 Problem Framing — Basic System Definition**

科研论证必须从"什么矛盾必须被解决"开始，而不是从"我做了什么"开始。Problem Framing 的目标不是描述系统，而是建立读者理解后续 gap、challenge 和 insight 所需的最低语义背景。

将用户材料归一化为研究问题，按以下结构定义 basic system。**只引入后续 challenge 必须依赖的概念**；凡是不能直接支撑 gap、challenge、insight 或 design 的内容，不得在此出现。

**核心闭环命题**（本工作的最小逻辑单元）：

> 在场景 S 中，为了达成目标 G，系统必须同时满足性质 P1、P2、P3；但现有方法因为假设 A 或抽象边界 B，无法同时满足这些性质。我们的核心观察是 O，它改变了问题的组织方式，使得设计 D 可以在约束 C 下同时满足这些性质，并通过指标 M 被验证。

逐一填写：

- **Scene & Setting**：本文讨论的问题发生在什么运行环境、部署条件、应用形态下？Setting 的作用是限定主张的适用范围。不泛化成"所有系统都面临的问题"。
- **Core Object**：论文关注的基本对象是什么（资源、任务、请求、数据、状态、接口、策略、执行单元）？对象定义必须具体。只用"资源""状态""数据"会导致 challenge 落空。
- **Key Constraint**：使该对象难以处理的约束条件（性能、安全、可靠性、可扩展性、兼容性、资源预算、信任关系、执行时机）。Constraint 是 gap 的来源。
- **Necessary Assumptions**：本文成立依赖的前提（哪些主体可信、哪些信息可见、哪些能力在范围内）。仅当直接影响论证时才需要明确展开。
- **Goal & Required Properties**：系统需要同时满足哪些性质？这些性质是否天然冲突？为什么同时成立是困难的？
- **Relevant Existing Approaches**：按设计哲学分类现有方法，不是列举。
- **Claimed Limitation & Root Cause**：现有方法的共享假设是什么？你的场景如何破坏这个假设？注意：gap 不是"别人没做"，而是"别人做不了或不该这样做"。
- **What must be proven**
- **What would falsify the argument**

**写作原则**：
- 本节是"问题世界"，不是"解决方案世界"。不提前介绍自己的系统模块、组件名称、算法流程。
- 由后续论证反向决定前文定义。后续 challenge 依赖某概念→必须提前定义；仅在 design 中需要→后移。
- 克制且精确：每个 term 服务于后文推理。删除后不影响论证→删除。

**自检**（完成后逐条确认）：
1. Setting 是否清楚？
2. Core object 是否具体？
3. Constraint 是否明确？
4. Assumption 是否必要且清楚？
5. Goal 是否与后续 challenge 直接相关？
6. 后续每个 challenge 是否都能回到本节定义的 object、constraint 或 assumption？
7. 本节是否避免了提前介绍自己的系统模块？
8. 本节是否删除了所有不能支撑 gap 或 challenge 的术语？

同时，识别与当前研究直接相关的关键资料（论文、系统、标准、技术方案），为每项在 `related-work-dossier.md` 中创建初始条目（使用 `templates/related-work-dossier.md` 格式）。初始条目至少填写 Scene & Context、Motivation 和初步 Relevance 判断，未填字段标注 `[待补充]`。

#### Checkpoint A

在 **Problem Framing 结束后、Claim Decomposition 开始前**，必须向用户呈现：

1. 归一化的问题定义（Target phenomenon, baseline, limitation）
2. 现有方法的概括
3. 声称的局限性
4. 必须被证明和证伪的内容

在向用户呈现前，运行 `hooks/run-checkpoint.sh pass1` 验证 Pass 1 产出完整性（Problem Object / One-Sentence Thesis / Claim Ledger / Assumption Ledger / Related Work Dossier）。若 hook 报 FAIL，先修复再呈现给用户。

使用 `AskUserQuestion`（若平台支持）或在正常对话中显式暂停并询问用户，请求确认或修正。若用户修正，回到 Problem Framing 重新归一化；若确认通过，进入 Claim Decomposition。

**1.3 Claim Decomposition & Strawman Analysis**

在写任何结论之前，提取所有实质性主张。将宽泛陈述拆分为可检验的主张。

例如，"this system is lighter than VMs and more isolated than containers" 应拆分为关于 VM overhead、avoided mechanisms、container isolation boundaries、new isolation semantics、measured overhead、以及需要两种属性的 real workloads 的独立主张。

将 CS 主张分类为：factual, mechanism, limitation, causal, boundary, TCB, threat, performance, correctness, expressiveness, compatibility, deployability, novelty, evaluation。

**Strawman Analysis（强制）**：每个 challenge claim 必须经过 strawman 审问。Challenge 不是一句"这很难"，而必须证明"最自然的方案为什么不行"。

对每个标记为 `limitation` 或与 challenge 相关的 claim，执行：

```
To achieve G, the system must satisfy P1 and P2 simultaneously.

Strawman S1: [最直接的方案]
  S1 satisfies P1 because ...
  However, S1 violates P2 because ... [具体失败模式]

Strawman S2: [相反方向的方案]
  S2 satisfies P2 because ...
  However, S2 violates P1 because ... [具体失败模式]

Root cause R: both strawmen assume A, but A no longer holds in our setting.

Therefore, the challenge is how to achieve P1 and P2 without relying on A.
```

**Strawman 质量标准**：
- S1 和 S2 必须走向相反方向（保守 vs 激进、全局 vs 局部、同步 vs 异步、精确 vs 近似），不能是同方向的两个变体。
- 每个 strawman 的失败不是"可能有问题"或"性能差"，而是破坏了一个具体的、可验证的性质或指标。
- Root cause 必须解释两个 strawman 为何同时失败——如果只解释了一个，说明 analysis 不完整。
- Root cause 将直接决定 insight 的形态：insight 必须正好打在 root cause 上。

Strawman 分析写入 Claim Ledger 的 First-Principles Decomposition 中（作为 `Strawman S1`, `Strawman S2`, `Root Cause` 字段追加到对应 claim 下）。

#### Checkpoint B

在 **Claim Decomposition 结束后、First-Principles Decomposition 开始前**，必须向用户呈现：

1. 核心主张清单（带分类：factual / mechanism / performance / ...）
2. 每个主张的重要性评级（core / supporting）
3. 已识别的隐藏假设

在向用户呈现前，运行 `hooks/run-checkpoint.sh pass1` 验证 Claim Ledger 中的 strawman analysis 和 assumption ledger。

使用 `AskUserQuestion`（若平台支持）或在正常对话中显式暂停并询问用户，请求确认或修正。若用户修正，回到 Claim Decomposition 重新提取；若确认通过，进入 First-Principles Decomposition 和后续的 Evidence Search。

**1.4 First-Principles Decomposition**

对每个核心主张，分解：

- Object: code, state, data, resource, interface, protocol, policy, workload, user, or hardware.
- Boundary: process, VM, container, language, API, trust, failure, consistency, transaction, or scheduling boundary.
- Authority: user, application, runtime, kernel, hypervisor, compiler, scheduler, database, or cloud provider.
- Mechanism: type system, scheduler, cache, protocol, replication, isolation, verification, static analysis, runtime check, or other mechanism.
- Baseline: prior system, standard approach, production system, or theoretical model.
- Limitation and root cause.
- Evidence needed.
- Evaluation needed.
- Falsification condition.

**Pass 1 输出**：Problem Object, Claim Ledger, Assumption Ledger。

**强制写文件**：Pass 1 完成后，必须立即将以下内容写入文件（不得仅在对话中呈现）：
- `claim-ledger.md`（使用 `templates/claim-ledger.md` 格式）
- `assumption-ledger.md`（使用 `templates/assumption-ledger.md` 格式）
- `related-work-dossier.md`（使用 `templates/related-work-dossier.md` 格式，每项关键资料至少填写 Scene & Context、Motivation 和 Relevance）
- `research-trace.md` 的 Problem Object 和 Assumption Ledger 章节（使用 `templates/research-trace.md` 格式）

若用户指定了输出目录，文件写入该目录；否则写入当前工作目录下的 `research-output/` 目录。写入完成后运行 `hooks/run-checkpoint.sh pass1`，确认所有必需字段已填写，然后向用户报告文件路径和验证结果。

### Pass 2: Validation

整合证据搜索、证据归一化、对抗性批判和差距 backlog。

- **Lightweight 模式**：首轮跳过完整的 Pass 2。基于 Pass 1 的内部知识，直接生成压缩检查清单（3-5 项核心风险或验证建议），不执行 Evidence Search、Normalization 或 Adversarial Critique。Checkpoint C 被压缩为一句确认："当前深度是否足够，或需要进入 Standard/Deep 模式继续？" 若用户不满意，自动升级到 Standard 模式。
- **Standard 模式**：按顺序执行 Pass 2 的所有子步骤。
- **Deep 模式**：可先通过 Role-Lens 并行搜索，再统一归一化（详见 `agents/deep-role-lens-instructions.md`）。

**2.1 Evidence Search**

对每个核心主张，至少生成三个搜索方向：

- Support query: 可能支持该主张的证据。
- Counterexample query: 可能削弱或反驳该主张的证据。
- Boundary query: 定义、基线、先前系统、标准或工件。

当用户要求研究或引用、事实可能已变化、或需要精确来源归属时，使用当前网络研究。优先使用一手来源：论文、官方文档、标准、源代码、工件仓库、基准测试、CVE、安全公告、问题跟踪器、邮件列表和技术报告。

获得新信息后，立即更新 `related-work-dossier.md` 中对应条目的相关字段（Contradiction Resolved、Core Design、Experimental Validation、Limitations），并追加 `Understanding Evolution` 记录（标注 Round 2）。

**2.2 Evidence Normalization**

不要将来源直接粘贴到最终结论中。对每个重要来源归一化：

- What it directly supports.
- What it does not support.
- Applicable scenario and boundary.
- Possible misuse.
- Allowed wording.
- Forbidden wording.
- Evidence level: S, A, B, C, or D.

主线主张不应依赖 C/D 级证据。C/D 级证据仅作为线索，除非该主张明确为低置信度或推测性。

**2.3 Adversarial Critique**

像顶级 CS 审稿人一样攻击论点。批判必须具体、可操作、有证据支撑，不得使用模糊措辞（如"不够好""可能有问题"）。每条 critique 必须指向具体的 claim、说明攻击角度、给出 severity 评级、并提出可验证的 follow-up。

**Severity 操作化标准**（必须严格遵守）：

| Severity | 定义 | 触发条件 | 后果 |
|---|---|---|---|
| **fatal** | 该主张在当前形式下无法成立 | 核心假设被证伪、反例直接覆盖主张范围、关键基线根本性错误、评估方法无法证明所述属性 | 主张必须 marked_as_risk 或 deleted |
| **high** | 主张的当前表述严重过度，或缺少关键验证 | 无真实工作负载、无基线对比、泛化声明无边界条件、指标与主张不匹配 | 主张必须 weakened 或 split，且必须生成对应的 Gap |
| **medium** | 主张可能成立但支撑不足 | 证据级别不足（B/C 级支撑 core claim）、边界条件未探索、实验设置存在 confound | 必须生成对应 Gap 并在 Re-search 中关闭 |
| **low** | 表述歧义或次要遗漏 | 术语未定义但可推断、次要 tradeoff 未讨论、边缘场景未覆盖但不影响核心结论 | 记录在案，不强制生成 Gap，但 Final Report 中需标注 |

**Layer 1 — 主张层面的批判**（逐条攻击每个 core claim）：

- **Overclaim 检测**：主张的强度是否超过证据的强度？泛化范围是否超出了实验覆盖的场景？量化声明是否有误差棒和统计检验？
- **Baseline 审查**：基线是否是最强或最相关的现有方案？是否考虑了最新版本？基线配置是否对其有利（稻草人基线）？是否遗漏了 obvious hybrid baseline？
- **Workload 审查**：工作负载是否真实且具有代表性？是否覆盖了 adversarial / worst-case / skewed 场景？数据规模和时间跨度是否足够？
- **定义审查**：关键术语是否可操作化定义？度量起点和终点是否明确？比较对象是否具有可比性（apple-to-apple）？

**Layer 2 — 方法论层面的批判**（攻击实验设计和测量方法）：

- **实验设计**：是否有对照组？是否控制了混淆变量？随机化是否充分？是否存在选择偏差或幸存者偏差？
- **测量有效性**：指标是否真正度量了所声称的属性？p99/p999 是否被报告（而不仅仅是 mean）？是否报告了方差和分布？预热是否充分？冷启动和热路径是否区分？
- **统计有效性**：样本量是否足够？是否报告了置信区间？多次实验的变异系数是否合理？是否存在 p-hacking 或多重比较问题？
- **可复现性**：实验是否可被独立复现？是否提供了代码、配置、数据和脚本？硬件/软件环境是否完整描述？

**Layer 3 — 跨主张连锁批判**（攻击论点结构）：

- **依赖链断裂**：如果 claim A 被削弱，依赖 A 的 claim B 是否仍然成立？是否存在隐藏的传递性假设（"A 优于 B，B 优于 C，因此 A 优于 C"）？
- **组合爆炸**：多个 weakened claim 的组合效应是否使整体论点不可维持？是否存在"每个单独成立但组合后矛盾"的情况？
- **范围蔓延**：系统是否通过不断缩小 claim 的范围来逃避批判？缩小后的 claim 是否还有研究贡献？
- **循环论证**：结论是否预设了前提？评估是否度量了被设计来优化的指标而忽略了 tradeoff？

**Layer 4 — 遗漏审查**（攻击论证的盲区）：

- **遗漏的 tradeoff**：性能提升的代价是什么（复杂度、可维护性、兼容性、安全性）？是否只报喜不报忧？
- **遗漏的替代方案**：是否存在更简单的方案能达到类似效果？非技术方案（配置调优、硬件升级、架构简化）是否被忽略？
- **遗漏的失败模式**：系统在什么条件下会失败？失败时是 graceful degradation 还是 catastrophic？是否分析了 corner case？
- **遗漏的 artifact**：代码、模型、数据集是否可获取？若不可获取，如何验证声称的结果？

每条 severity ≥ medium 的 critique 必须在 Gap Backlog 中有对应的 Gap ID（双向链接）。批判完成后，对所有 core claims 进行**批判饱和度评估**：每个 claim 被至少一个 Layer 覆盖、所有 Layer 合计至少产生 3 条 medium+ critique（若不足，说明批判不够深入，需重新审视）。

**2.4 Gap Backlog**

将每个严重批判转化为可搜索、可关闭的研究差距。避免模糊差距如 "needs more evidence"。将差距写为可驱动下一轮研究的具体问题。

**Pass 2 输出**：Evidence Ledger, Critique Ledger, Gap Backlog。

**强制写文件**：Pass 2 的每个子步骤完成后，必须立即将中间结果写入文件：
- `evidence-ledger.md`（Evidence Search 和 Normalization 完成后写入，使用 `templates/evidence-ledger.md` 格式）
- `critique-ledger.md`（Adversarial Critique 完成后写入，使用 `templates/critique-ledger.md` 格式）
- `gap-backlog.md`（Gap Backlog 生成后写入，使用 `templates/gap-backlog.md` 格式）
- `related-work-dossier.md` 更新（补全之前标注 `[待补充]` 的字段，追加 Round 2 的 Understanding Evolution）
- `research-trace.md` 追加 Counterexample Ledger 和 Decision Ledger 章节

所有文件写入同一输出目录。每次 Re-search 轮次更新文件时，保留历史内容（追加而非覆盖）。写入完成后运行 `hooks/run-checkpoint.sh pass2` 验证 Evidence/Critique/Gap 的完整性和双向链接，然后向用户报告文件路径和变更摘要。

#### Checkpoint C

在 **Evidence Normalization 和 Adversarial Critique 结束后**，运行 `hooks/run-checkpoint.sh pass2` 做最终验证（evidence levels, critique severity coverage, gap-critique bidirectional links, saturation estimate）。所有 FAIL 项修复后，向用户呈现：

1. **证据摘要**：核心主张的证据饱和度（有 ≥A 级证据且无任何未解决 fatal/high critique 的主张占比）、最强证据、最弱证据。
2. **关键批判**：按严重程度排序的 top 3-5 条 adversarial critique。
3. **Gap Backlog**：按优先级排序的开放差距，标注哪些可在预算内关闭、哪些需额外资源。

使用 `AskUserQuestion`（若平台支持）或在正常对话中显式暂停并询问用户，提供以下决策选项：
- **继续深入**：进入 Rebuttal Phase（Checkpoint D），然后进入 Pass 3。
- **额外 Re-search**：返回 Pass 2 针对特定 Gap 补充证据。
- **用户满意，进入收敛**：若用户认为当前深度已足够且无反驳，跳过 Rebuttal Phase，直接进入 Pass 3 Convergence，最终由 User Satisfaction Gate 确认退出。

#### Checkpoint D: Rebuttal Phase

在 Checkpoint C 确认"继续深入"之后、Pass 3 Convergence 之前，必须执行 Rebuttal Phase。此阶段的目的是让用户对 Adversarial Critique 的结果进行反驳——用户可能拥有审稿人不知道的上下文、数据或论证角度。

**D.1 呈现批判摘要**

向用户呈现 Checkpoint C 的批判摘要（top 3-5 critiques + Gap Backlog 摘要），然后显式询问：

> "以上是批判分析的结果。在进入最终收敛阶段之前，你是否对这些批判有任何反驳？例如：批判误解了你的设计、遗漏了关键上下文、引用了不适用于本场景的基线、或你已有未在材料中提及的证据可以回应某些批判。"

**D.2 收集并确认 Rebuttal**

若用户提供了反驳：

1. **逐条记录**：将用户的每条 rebuttal 记录到 Rebuttal Ledger（追加到 Research Trace 中），格式为 `| Rebuttal ID | 目标 Critique ID | Rebuttal 内容 | 所需新证据 | 状态 |`
2. **确认理解**：向用户复述每条 rebuttal 的核心逻辑，询问"我的理解是否准确？"用户确认后方可继续。
3. **分类处理**：
   - **第一类 — 澄清型**：用户指出批判基于误解。确认后，在 Critique Ledger 中将对应 critique 标注为 `resolved_by_clarification`，并在 Final Report 中记录澄清内容。
   - **第二类 — 新证据型**：用户声称拥有可回应批判的证据但未在原始材料中提供。要求用户提供该证据（论文引用、数据、实验描述等），然后执行 **Mini Validation**：对每条新证据进行 Evidence Normalization（赋级别、定边界、写 allowed/forbidden wording）。新证据归入 Evidence Ledger（标注来源为 `user_rebuttal`）。
   - **第三类 — 范围重定义型**：用户承认批判有效，但认为应缩小主张范围而非削弱主张本身。此时回到 Claim Decomposition，对受影响的主张执行 split / narrow 操作，更新 Claim Ledger。

**D.3 重新完善资料**

Rebuttal 处理完毕后，必须执行以下步骤重新完善整个研究资料：

1. **更新 Claim Ledger**：根据 rebuttal 结果修订单个主张的状态、范围和表述。若 rebuttal 引入了新证据，检查是否有主张的状态可从 `unverified` 变为 `supported`。
2. **更新 Evidence Ledger**：将 rebuttal 中引入的新证据归一化后追加。若 rebuttal 解决了某些 critique，检查受影响主张的证据饱和度是否提升。
3. **更新 Critique Ledger**：标注被 rebuttal 解决的 critique（`resolved_by_rebuttal`），但保留原始 critique 条目（不物理删除）。
4. **更新 Gap Backlog**：关闭已被 rebuttal 解决的 Gap（状态改为 `closed_by_rebuttal`）。
5. **更新 Related Work Dossier**：若 rebuttal 引入了新资料或对已有资料的新理解，更新 `related-work-dossier.md` 对应字段并追加 Understanding Evolution（标注 Rebuttal Phase）。
6. **重新计算饱和度**：基于更新后的 Claim/Evidence/Critique Ledger 重新计算证据饱和度。
7. **检查是否需要额外 Re-search**：若 rebuttal 引入了新的主张或暴露了新的 Gap，可能需要返回 Pass 2 进行补充搜索。
8. **向用户呈现完善结果**：简要报告 rebuttal 导致的变更（X 条主张状态变更、Y 条批判被解决、Z 条 Dossier 更新、饱和度从 A% 变为 B%）。

**D.4 Rebuttal 后的决策**

Rebuttal 处理完毕后，运行 `hooks/run-checkpoint.sh rebuttal` 验证 Rebuttal Ledger 完整性（type 分类、resolution 状态、post-rebuttal ledger sync、saturation recalculation）。验证通过后，再次呈现决策选项：

- **进入 Pass 3**：若 rebuttal 后饱和度足够且无新 Gap，进入 Convergence。
- **补充 Re-search**：若 rebuttal 暴露了新 Gap 或引入了需要验证的新主张，返回 Pass 2 补充搜索。
- **循环 Rebuttal**：若用户对完善后的结果仍有反驳，再次执行 Checkpoint D。**无循环次数上限**——在用户满意之前持续循环。

**D.5 Rebuttal 不充分的处理**

若用户的反驳存在以下情况，不得自动接受，必须指出问题：

- 反驳缺乏证据支撑且无法归类为"澄清型"
- 反驳与已确立的证据矛盾
- 反驳引入了新的未验证假设
- 反驳试图将 fatal critique 降级但未提供实质性新信息

此时应向用户说明为何该反驳不足以解决对应批判，并建议替代路径（如 weaken claim、mark as risk、或接受批判并将其作为 remaining risk）。

### Pass 3: Convergence

整合针对性再研究、主张修订、评估义务和收敛检查。**循环无上限**——用户未被说服则永不停止。

**3.1 Advisory Budget & Progress Tracking**

预算控制是**建议性的**，用于帮助用户了解当前进度，绝不强制退出。每轮迭代开始时声明当前状态：

- **当前轮次编号**（起于 1，每次完成完整 Pass 2/3/D 循环后 +1）。
- **证据饱和度**：Core Claims 中同时拥有 ≥A 级证据且无未解决 fatal/high critique 的主张所占比例。≥80% 时告知用户"饱和度已达发布级"，但用户仍可要求继续深挖。
- **本轮目标**：本轮要解决的 Gap 或要回应的用户反驳。
- **本轮产出**：完成后报告新增/更新的证据、变更的主张、解决的批判。

饱和度计算细节参见 `references/budget-guide.md`。注意：预算指南中的"最大轮次"和"强制退出"条款已被本规则覆盖——仅在用户表示满意时退出。

**3.2 Targeted Re-search**

仅围绕开放差距进行再研究。记录：

- Objective
- Queries
- Sources found
- Evidence added
- Claims updated
- New attacks
- Continue yes/no with reason

每次 Targeted Re-search 后，检查 `related-work-dossier.md` 中是否有字段因新发现而需要修正。若有新理解，追加 `Understanding Evolution` 记录（标注对应 Re-search 轮次，如 Round 3、Round 4），并修正相关字段（保留原文用删除线）。

**3.3 Claim Revision**

使用状态机：

`unverified -> supported -> weakened -> split -> merged -> deleted -> risk -> final`

记录每个 keep、weaken、split、merge、delete 或 risk 决策的原因和剩余风险。

**3.4 Evaluation Obligations**

将每个最终的 performance、security、correctness、compatibility、expressiveness、deployability 或 novelty 主张映射到评估义务：

- Performance: latency, throughput, utilization, scalability, cost.
- Security: threat model, attack case, bug class, TCB comparison.
- Correctness: proof, model checking, invariant, differential test.
- Compatibility: API coverage, workload coverage, regression suite.
- Expressiveness: case studies, supported patterns, impossible baseline.
- Deployability: code changes, operational complexity, migration cost.

**3.5 Convergence Check — User Satisfaction Gate**

**唯一退出条件**：用户明确表示满意。其他所有条件（饱和度、轮次数、Gap 数量）均为参考指标，不具有停止效力。

在每轮迭代完成（Pass 3 输出草稿 Final Report）后，必须执行 User Satisfaction Gate：

0. **运行 Convergence Hook**：`hooks/run-checkpoint.sh convergence`。此 hook 执行内部质量门槛检查（§3.5 内部质量门槛 + Logic Audit + Story Quality Audit + Story Closure）。若 hook 以 exit code 2 退出（FAIL），不得向用户呈现 Final Report 草稿——自动继续迭代直到所有 FAIL 修复。若 hook 通过（exit 0），继续下一步。
1. 呈现本轮迭代的变更摘要（新增/更新证据、主张状态变更、批判解决情况、饱和度变化）以及 hook 验证结果。
2. 显式询问用户：

> "本轮分析已完成。当前证据饱和度 XX%（XX/XX core claims 有 A 级+证据且无 fatal/high critique）。你对当前的分析深度满意吗？是否有任何反驳、补充、或需要进一步深挖的角度？"

3. **用户反馈的分流**：
   - **用户表示满意**（"可以了""满意""没有更多问题了""就这样"）→ 退出循环，执行 Logic Audit（§3.6），然后生成最终 Final Report。
   - **用户提出新的反驳** → 回到 Checkpoint D（Rebuttal Phase），处理反驳后重新进入 Pass 2/3。
   - **用户要求深挖特定 Gap** → 回到 Pass 2 Targeted Re-search，针对指定 Gap 补充证据。
   - **用户要求扩大搜索范围**（"再看看有没有遗漏的基线""有没有更新的论文"）→ 回到 Pass 2 Evidence Search，扩展搜索。
   - **用户表示不确定 / 不够深入** → 自动判断最薄弱的主张或最严重的 critique，主动建议下一步深挖方向，让用户选择。
   - **用户无响应或模糊回应** → 视为不满意，继续迭代。

**内部质量门槛**（必须满足才向用户呈现 Final Report 草稿，否则自动继续迭代）：

- All core claims have evidence or are marked as risk.
- All high-severity critiques are at least addressed (resolved / rebutted / accepted as risk).
- All comparative claims have baselines.
- All performance/security/correctness claims have evaluation obligations.
- Key terms are defined.
- Weak claims are downgraded or deleted.
- The final conclusion explains why the contribution is not merely incremental.
- No vague phrases such as "obviously", "many systems", "industry needs", or "fundamentally stronger" without support.

若内部质量门槛未通过，**不得向用户呈现 Final Report 草稿**，必须先自动迭代直到门槛通过。通过后，由 User Satisfaction Gate 决定是否继续。

**3.6 Logic Audit & Story Quality Audit**

Convergence Check 通过后、生成 Final Report 之前，必须执行两个独立的审计：

- **Logic Audit**：检查"从证据到结论的推理是否严密"。
- **Story Quality Audit**：检查"论证是否符合系统研究写作方法论"。

两者均使用 `templates/story-checklist.md` 执行。

**Logic Audit（三个粒度）**详见 `templates/final-report.md` Section 12：

**句级**：证据锚定、强度匹配、禁止词汇。
**段级**：C-E-R 链完整、逻辑跳跃检测、前提声明。
**跨段**：矛盾检测、范围一致性、攻击处置完整性。

**Story Quality Audit（新增）**：逐条通过 `templates/story-checklist.md` 的 17 项检查和 11 项写作规则。关键检查：

- One-Sentence Thesis 三句话是否仍然成立？
- 每个 challenge 是否有 strawman analysis（S1 / S2 / root cause）？
- Gap 是否为"assumption gap / abstraction gap / trade-off gap / granularity gap"之一——而非"别人没做"？
- Insight 是否描述了"重新组织问题"的动作——而非"使用 X 技术"？
- Primary metric 是否在实验前定义——而非实验后挑选？
- 术语是否全部被定义且承担推理功能——无口号式形容词？
- Non-goal 是否明确列出？
- Reviewer 12 种常见攻击是否都有 defence？
- 读者能否学到一句可迁移的 design lesson？

**Story 审计通过标准**：
- 17 项自检全部为"是"
- 写作规则 W1-W11 全部通过
- Story Closure Table 中每个 challenge 有对应的 evaluation，每个 design component 有对应的 challenge
- One-Sentence Thesis 三句话连读形成完整逻辑闭环

未通过项标为 `[STORY-GAP: 具体问题]`。STORY-GAP > 3 时回到对应 Pass 修复。

**3.7 Story Closure Check**

Logic Audit 和 Story Quality Audit 通过后，执行最终的论证闭环检查。此检查验证 challenge、design、evaluation 之间的一一映射关系。

构建 **Story Closure Table**（写入 Final Report）：

| Challenge | Insight Part | Design Component | Invariant | Experiment | Metric | Status |
|---|---|---|---|---|---|---|
| C1 | I1 | D1 | Inv1 | Exp1 | M1 | closed / gap |

**闭包规则**（每项必须为 closed）：
- 每个 challenge 找不到 evaluation → **空话**（`gap: missing_evaluation`）
- 每个 design component 找不到 challenge → **噪声**（`gap: orphan_design`）
- 每个 evaluation 找不到 claim → **无关实验**（`gap: unclaimed_experiment`）
- 每个 claim 找不到 metric → **不可证明**（`gap: unmeasurable_claim`）
- 每个 insight part 找不到对应的 strawman root cause → **洞见悬空**（`gap: ungrounded_insight`）

存在任何 gap 时，必须回到对应 Pass 修复，不得生成最终 Final Report。

**Pass 3 输出**：Final Report（含 Logic Audit、Story Quality Audit、Story Closure Table）, Research Trace（含 Rebuttal Ledger 和全部审计原始记录）。

## Final Output

For substantial tasks, produce:

1. One-Sentence Thesis (问题句 + 洞见句 + 系统句)
2. Problem Framing (完整 basic system definition)
3. Related Work Dossier (完整的结构化相关资料分析)
4. Strong Claims (含 strawman analysis)
5. Weakened Claims
6. Deleted Claims
7. Evidence Map
8. Counterexamples and Reviewer Attacks (含 12 种 reviewer attack 的 defence 表)
9. Remaining Risks
10. Evaluation Obligations (primary + cost + robustness metrics)
11. Story Closure Table (challenge-design-evaluation 映射)
12. Paper-ready or Proposal-ready Text
13. Research Trace Appendix (含 Rebuttal Ledger)
14. Logic Consistency Audit
15. Story Quality Audit (17-point checklist result)

For shorter tasks, keep the same logic but compress the artifacts into concise tables. Use Chinese if the user writes in Chinese unless they request English.

**强制写文件**：Final Report 必须写入文件（`final-report.md`），Research Trace 必须写入文件（`research-trace.md`）。研究过程中所有 Ledger 文件（claim/evidence/critique/assumption/gap-backlog）以及 Related Work Dossier 必须在对应 Pass 完成后立即写入文件，不得仅在对话中呈现。所有文件写入同一输出目录，完成后向用户报告完整文件清单和路径。

When producing files, use:

- `templates/claim-ledger.md`
- `templates/evidence-ledger.md`
- `templates/critique-ledger.md`
- `templates/research-trace.md`
- `templates/final-report.md`
- `templates/assumption-ledger.md`（Pass 1 输出）
- `templates/gap-backlog.md`（Pass 2 输出）
- `templates/related-work-dossier.md`（Pass 1 创建，Pass 2/3 迭代完善）
- `templates/story-checklist.md`（Pass 3 Logic Audit 和 Story Quality Audit 使用）
- `hooks/run-checkpoint.sh <pass1|pass2|rebuttal|convergence|all>`（每个 Checkpoint 强制运行）

## Quality Bar

A valid answer must explain the problem, existing baselines, why baselines are insufficient, the root cause, what mechanism or abstraction changes, supporting evidence, counterexamples, weakened or deleted claims, necessary experiments, and a paper-ready/proposal-ready version using only claims that survived the loop. Every sentence in the final output must trace back to evidence or declare its premises. Every paragraph must contain a complete Claim-Evidence-Reasoning chain. All intermediate results must be written to files and their paths reported. Every checkpoint hook (pass1 / pass2 / rebuttal / convergence) must return exit code 0 before proceeding. The user must have been offered a Rebuttal Phase, and the loop must not have stopped until the user explicitly confirmed satisfaction. A saturation metric alone never ends the process.
