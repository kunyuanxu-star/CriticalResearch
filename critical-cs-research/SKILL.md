---
name: critical-cs-research
description: A domain-general but computer-science-specific critical research loop for OS, networking, security, databases, PL/compilers, architecture, AI infrastructure, distributed systems, software engineering, HCI/CSCW, and technical systems work. Use when Codex must validate a CS research idea, paper motivation, related-work critique, system design, experiment plan, rebuttal, survey, architecture decision, security analysis, or performance diagnosis by decomposing claims, grounding evidence, finding counterexamples, generating research gaps, re-searching, revising claims, mapping evaluation obligations, and producing evidence-backed conclusions.
---

# Critical CS Research

## Core Rule

Do not directly polish or defend the user's original idea. First run the research control loop:

`Problem -> Claim -> Assumption -> Evidence -> Counterexample -> Gap -> Re-search -> Revision -> Decision`

The final answer must preserve the trace from each conclusion back to claims, evidence, counterexamples, critiques, and decisions. Allow the original idea to be weakened, reframed, marked as risk, or deleted.

## When Starting

1. Identify the task type: idea validation, paper motivation, related-work critique, system design review, experiment planning, rebuttal preparation, survey construction, architecture decision, security analysis, or performance diagnosis.
2. Identify the CS area: systems, networking, security, database, PL/compiler, architecture, software engineering, AI infrastructure, distributed systems, or HCI/CSCW.
3. Read `references/domain-profiles.md` for the relevant profile when the area is clear or when profile-specific checks matter.
4. Read `references/evidence-standards.md` before doing source-backed research or assigning evidence levels.
5. Read `references/role-lenses.md` when the task is large enough to benefit from separate parsing, scouting, counterexample, review, audit, experiment, and synthesis passes.
6. Use `templates/*.md` when the user asks for reusable artifacts, files, or exhaustive output.

If the user has not provided material, ask for it. If target venue, audience, or output form is missing, infer a reasonable default and state it briefly.

## Required Workflow

### Mode Selection (Triage)

根据用户输入的复杂度、主张数量和目标深度，在启动时选择执行模式。如果用户未指定，根据以下标准自动选择或询问：

| 模式 | 适用场景 | 核心主张数 | Re-search 轮次 | 外部证据 | 输出粒度 |
|---|---|---|---|---|---|
| **Lightweight** | 快速验证、想法初筛、已有明确结论的复核 | ≤3 | 0 | 内部知识为主 | 压缩检查清单（3-5 项） |
| **Standard** | 常规研究、设计评审、实验计划 | 4-10 | ≤1 | 需要搜索 | 标准表格 + 简短报告 |
| **Deep** | 投稿级审稿、完整 rebuttal、架构决策 | >10 或不明确 | ≤2（可配置） | 深度搜索 + 并发 Role-Lens | 完整 Ledger + 详细报告 |

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

**1.2 Problem Framing**

将用户材料归一化为研究问题，明确：

- Target phenomenon
- Relevant existing approaches
- Claimed limitation
- Proposed mechanism or abstraction
- What must be proven
- What would falsify the argument

#### Checkpoint A

在 **Problem Framing 结束后、Claim Decomposition 开始前**，必须向用户呈现：

1. 归一化的问题定义（Target phenomenon, baseline, limitation）
2. 现有方法的概括
3. 声称的局限性
4. 必须被证明和证伪的内容

使用 `AskUserQuestion`（若平台支持）或在正常对话中显式暂停并询问用户，请求确认或修正。若用户修正，回到 Problem Framing 重新归一化；若确认通过，进入 Claim Decomposition。

**1.3 Claim Decomposition**

在写任何结论之前，提取所有实质性主张。将宽泛陈述拆分为可检验的主张。

例如，"this system is lighter than VMs and more isolated than containers" 应拆分为关于 VM overhead、avoided mechanisms、container isolation boundaries、new isolation semantics、measured overhead、以及需要两种属性的 real workloads 的独立主张。

将 CS 主张分类为：factual, mechanism, limitation, causal, boundary, TCB, threat, performance, correctness, expressiveness, compatibility, deployability, novelty, evaluation。

#### Checkpoint B

在 **Claim Decomposition 结束后、First-Principles Decomposition 开始前**，必须向用户呈现：

1. 核心主张清单（带分类：factual / mechanism / performance / ...）
2. 每个主张的重要性评级（core / supporting）
3. 已识别的隐藏假设

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

### Pass 2: Validation

整合证据搜索、证据归一化、对抗性批判和差距 backlog。

- **Lightweight 模式**：跳过完整的 Pass 2。基于 Pass 1 的内部知识，直接生成压缩检查清单（3-5 项核心风险或验证建议），不执行 Evidence Search、Normalization 或 Adversarial Critique。Checkpoint C 被压缩为一句确认："当前深度是否足够，或需要进入 Standard/Deep 模式继续？"
- **Standard 模式**：按顺序执行 Pass 2 的所有子步骤。
- **Deep 模式**：可先通过 Role-Lens 并行搜索，再统一归一化（详见 `agents/deep-role-lens-instructions.md`）。

**2.1 Evidence Search**

对每个核心主张，至少生成三个搜索方向：

- Support query: 可能支持该主张的证据。
- Counterexample query: 可能削弱或反驳该主张的证据。
- Boundary query: 定义、基线、先前系统、标准或工件。

当用户要求研究或引用、事实可能已变化、或需要精确来源归属时，使用当前网络研究。优先使用一手来源：论文、官方文档、标准、源代码、工件仓库、基准测试、CVE、安全公告、问题跟踪器、邮件列表和技术报告。

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

像顶级 CS 审稿人一样攻击论点：

- Is the claim overstated?
- Is there a real workload?
- Is the baseline correct?
- Has prior work already solved it?
- Is this only an implementation difference?
- Is a local problem framed as universal?
- Are mechanism, policy, abstraction, and implementation confused?
- Is the threat model clear?
- Are metrics measurable?
- Are tradeoffs and artifacts missing?
- Is the evaluation capable of proving the claim?

**2.4 Gap Backlog**

将每个严重批判转化为可搜索、可关闭的研究差距。避免模糊差距如 "needs more evidence"。将差距写为可驱动下一轮研究的具体问题。

**Pass 2 输出**：Evidence Ledger, Critique Ledger, Gap Backlog。

#### Checkpoint C

在 **Evidence Normalization 和 Adversarial Critique 结束后**，向用户呈现：

1. **证据摘要**：核心主张的证据饱和度（有 ≥A 级证据且无任何未解决 fatal/high critique 的主张占比）、最强证据、最弱证据。
2. **关键批判**：按严重程度排序的 top 3-5 条 adversarial critique。
3. **Gap Backlog**：按优先级排序的开放差距，标注哪些可在预算内关闭、哪些需额外资源。

使用 `AskUserQuestion`（若平台支持）或在正常对话中显式暂停并询问用户，提供以下决策选项：
- **继续深入**：进入 Pass 3（若 Gap 少且饱和度高）。
- **额外 Re-search**：返回 Pass 2 针对特定 Gap 补充证据（消耗预算轮次）。
- **提前收敛**：若用户认为当前深度已足够，跳过 Pass 3 的完整展开，直接输出压缩结论（标记剩余风险）。

### Pass 3: Convergence

整合针对性再研究、主张修订、评估义务和收敛检查。受 Budget Control 约束。

**3.1 Budget Control**

在执行 Pass 3 之前，声明本轮预算并阅读 `references/budget-guide.md`：

- **最大 Re-search 轮次**：Lightweight 0，Standard 1，Deep 默认 2。可通过 `--max-research-rounds N` 覆盖，或在启动时询问用户。
- **证据饱和度阈值**：Core Claims 中同时拥有 ≥A 级证据且无未解决 fatal/high critique 的主张所占比例。≥80% 可触发提前收敛。
- **强制退出**：当预算耗尽时，无论剩余多少开放 Gap，必须进入 Final Report，并显式标记所有剩余风险、未验证主张、开放差距和证据短缺。

**3.2 Targeted Re-search**

仅围绕开放差距进行再研究。记录：

- Objective
- Queries
- Sources found
- Evidence added
- Claims updated
- New attacks
- Continue yes/no with reason

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

**3.5 Convergence Check**

仅当以下条件满足时停止：

- All core claims have evidence or are marked as risk.
- All high-severity critiques are handled.
- All comparative claims have baselines.
- All performance/security/correctness claims have evaluation obligations.
- Key terms are defined.
- Weak claims are downgraded or deleted.
- The final conclusion explains why the contribution is not merely incremental.

**或**当预算耗尽且已标记剩余风险时强制停止。

Do not stop if a core claim lacks evidence, a fatal critique remains, the text still uses vague phrases such as "obviously", "many systems", "industry needs", or "fundamentally stronger" without support, workload or baseline is missing, claim strength exceeds evidence, or the mechanism's actual change is unclear.

**Pass 3 输出**：Final Report, Research Trace。

## Final Output

For substantial tasks, produce:

1. Final Thesis
2. Problem Framing
3. Strong Claims
4. Weakened Claims
5. Deleted Claims
6. Evidence Map
7. Counterexamples and Reviewer Attacks
8. Remaining Risks
9. Evaluation Obligations
10. Paper-ready or Proposal-ready Text
11. Research Trace Appendix

For shorter tasks, keep the same logic but compress the artifacts into concise tables. Use Chinese if the user writes in Chinese unless they request English.

When producing files, use:

- `templates/claim-ledger.md`
- `templates/evidence-ledger.md`
- `templates/critique-ledger.md`
- `templates/research-trace.md`
- `templates/final-report.md`
- `templates/assumption-ledger.md`（Pass 1 输出）
- `templates/gap-backlog.md`（Pass 2 输出）

## Quality Bar

A valid answer must explain the problem, existing baselines, why baselines are insufficient, the root cause, what mechanism or abstraction changes, supporting evidence, counterexamples, weakened or deleted claims, necessary experiments, and a paper-ready/proposal-ready version using only claims that survived the loop.
