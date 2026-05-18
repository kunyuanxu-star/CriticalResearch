# Final CS Research Report

## Trigger

在 **Pass 3: Convergence** 的 User Satisfaction Gate 通过后填写。这是整个研究循环的最终输出文件，必须由 Synthesis Writer 基于所有已验证的主张、证据和批判撰写。

## Example

### 1. One-Sentence Thesis

**问题句**：在容器安全监控场景中，现有方法无法同时满足低开销（<5% CPU）和内核兼容性（不修改内核、不维护内核模块），因为它们依赖内核态插桩（ptrace 的高上下文切换开销）或内核模块（维护成本高且稳定性风险大），而这两个假设在云原生快速部署场景中均失效。

**洞见句**：我们观察到，虽然完整追踪所有系统调用需要高开销，但在容器边界处（namespace/cgroup 切换），只需要追踪跨越安全边界的系统调用事件，就足以覆盖 95% 的安全监控需求，同时将必须插桩的路径缩短一个数量级。

**系统句**：基于这一观察，我们设计 eBPF-based 边界感知监控器，将原本需要全量系统调用追踪的问题转化为仅在安全边界处触发的事件拦截，从而在标准微服务负载下将 CPU 开销从 ptrace 的 35% 降低至 5% 以内。

### 2. Problem Framing (Basic System Definition)

- **Scene & Setting**：Kubernetes 集群中的多租户容器环境，每秒数百个容器启动/销毁，安全策略随部署动态变化。
- **Core Object**：系统调用事件——容器内进程与内核的交互点，是安全监控的基本粒度。
- **Key Constraint**：不能修改内核（无主线内核模块），不能引入 >5% CPU 开销（否则影响核心业务），必须兼容现有 seccomp-bpf 策略。
- **Necessary Assumptions**：攻击者无法绕过 eBPF verifier；内核版本 ≥5.8；工作负载为典型微服务（非 HPC）。
- **Goal & Required Properties**：同时满足 P1（CPU 开销 <5%）和 P2（无需内核修改、兼容 seccomp-bpf）。两者天然冲突：低开销通常意味着少检查，而内核兼容性限制了插桩点的选择。

### 3. Strong Claims (含 Strawman Analysis)

- SC1: 在标准微服务工作负载下，eBPF 监控的 CPU 开销 <5%（vs ptrace 的 30-40%）。
  - **Strawman S1 (全量追踪)**：追踪所有系统调用 → 满足 P2（兼容 seccomp-bpf）但违反 P1（开销 >30%）。失败模式：上下文切换频率与容器数量线性增长。
  - **Strawman S2 (采样追踪)**：仅追踪 1% 调用 → 满足 P1 但违反 P2（漏检率高，不满足安全需求）。失败模式：攻击者可利用未被采样的系统调用绕过检测。
  - **Root cause**：两个 strawman 都假设"追踪粒度 = 系统调用级别"。在容器场景中，安全相关事件仅占总系统调用的 <5%，所以全量追踪浪费开销，采样追踪丢失关键事件。
- SC2: 无需修改现有 seccomp-bpf 策略即可并行部署。
  - **Strawman S1 (内核模块)**：可并行但需要内核修改 → 违反 P2。失败模式：主线内核不接受、升级需重新编译。
  - **Strawman S2 (用户态拦截)**：不修改内核但开销极高 → 违反 P1。失败模式：每次系统调用需两次上下文切换（用户态↔内核态）。
  - **Root cause**：两者都假设监控逻辑必须在内核态或用户态二选一。eBPF 提供了第三条路——在内核态安全执行监控逻辑，但不需要修改内核源码。

### 4. Weakened Claims

- WC1: 在极端高并发（>100k events/sec）场景下，eBPF 开销可能上升至 8-12%。原 claim 中的 "<5%" 仅适用于正常负载。

### 5. Deleted Claims

- DC1: "完全替代 ptrace" — 删除。ptrace 在调试和异常注入场景仍有不可替代性。

### 6. Evidence Map

| Claim | Evidence | Status | Allowed Wording | Remaining Risk |
|---|---|---|---|---|
| SC1 | E1 (OSDI'23 FooSystem), E2 (self benchmark) | supported | 在标准微服务负载下，eBPF 方案将 CPU 开销降低至 5% 以内 | 未在 ARM64 上验证 |
| SC2 | E3 (Linux kernel docs) | supported | 可与现有 seccomp-bpf 策略并行部署 | 需内核 ≥5.8 |

### 7. Counterexamples And Reviewer Attacks

- A1: 未与 Firecracker 的轻量级监控对比。
- A2: 威胁模型未覆盖恶意容器利用 eBPF verifier 绕过的情况。

#### Reviewer Attack Defence Table

| # | Attack | Defence |
|---|---|---|
| 1 | 这个问题真实存在吗？ | Falco 在生产环境中因 ptrace 开销导致 15% 的请求延迟上升（引用 Datadog 2023 报告） |
| 2 | 为什么现有方法不能直接解决？ | ptrace 和内核模块共享假设"监控逻辑必须在用户态或内核模块中"，eBPF 绕开了这个假设 |
| 3 | 场景是否人为构造？ | 使用 Azure 公开 trace，覆盖 1M+ 容器生命周期事件 |
| 4 | 假设是否太强？ | 内核 ≥5.8 已在主流云厂商普及（AKS 1.21+, GKE 1.20+） |
| 5 | threat model 是否回避最难的问题？ | 明确 non-goal：eBPF verifier 绕过（硬件漏洞级别），不在本文 scope |
| 6 | 设计是否只是工程组合？ | 核心贡献不是"用 eBPF"，而是"边界感知的追踪粒度选择"——边界处的语义信息使追踪量减少 95% |
| 7 | insight 是否只是换了个说法？ | 不是"我们做了 eBPF 监控"，而是"将全量追踪问题转化为边界处事件拦截问题" |
| 8 | 实验是否只选了有利 case？ | 包含 adversarial workload：高频短生命周期容器 + 密集系统调用 |
| 9 | baseline 是否公平？ | ptrace baseline 使用最优配置（seccomp filter + BPF_PROG_TYPE），非稻草人 |
| 10 | 指标是否证明了 claim？ | Primary metric = CPU overhead p99；底线性质 = seccomp 策略兼容性（policy conflict count = 0） |
| 11 | 机制是否引入了新问题？ | eBPF verifier 复杂性是已知风险（见 Remaining Risks），但 eBPF 主线化已降低此风险 |
| 12 | 贡献是否可以推广？ | Design lesson：当监控粒度与安全边界对齐时，追踪开销可以从 O(n) 降为 O(boundary_crossings) |

### 8. Remaining Risks

- ARM64 架构验证缺失。
- 高并发场景下开销上升。
- eBPF verifier 复杂性带来的潜在绕过。

### 9. Evaluation Obligations

**Primary Metric**：CPU overhead p99（证明核心 claim SC1）
**Cost Metric**：额外内存占用（eBPF map 大小）、eBPF 程序加载时间
**Robustness Metric**：高并发（>100 containers/s）、长稳运行（72h）、ARM64 等价性

| Claim | Required Evaluation | Baseline | Workload | Metric | Falsification |
|---|---|---|---|---|---|
| SC1 | benchmark | ptrace-based monitoring | Kubernetes microservices | CPU overhead p99 | >10% |
| SC2 | compatibility test | seccomp-bpf alone | Standard container workloads | Policy conflict count | >0 |

### 10. Story Closure Table

| Challenge | Insight Part | Design Component | Invariant | Experiment | Metric | Status |
|---|---|---|---|---|---|---|
| C1: CPU 开销与兼容性不可兼得 | I1: 边界处追踪替代全量追踪 | D1: Boundary-aware eBPF hook | 仅安全边界处触发监控 | Exp1: benchmark | M1: CPU overhead p99 | closed |
| C2: 内核兼容性与可部署性不可兼得 | I2: eBPF 提供第三条路 | D2: eBPF 运行时在内核态安全执行 | seccomp-bpf 策略不冲突 | Exp2: compatibility test | M2: Policy conflict count = 0 | closed |

### 11. Paper-ready Or Proposal-ready Text

[此处插入可直接用于投稿的段落，仅使用 Evidence Map 中 allowed wording 的表述]

### 12. Research Trace Appendix

[引用完整的研究痕迹文件路径或内嵌关键决策记录]

### 13. Logic Consistency Audit

在 Final Report 的每个 section 完成后，必须执行以下逻辑一致性检查。此 Audit 的结果应内嵌于 Final Report 中，或作为独立附录 `logic-audit.md` 输出。

#### 句级逻辑验证

对 section 1-10 中的每个陈述句执行：

- **证据锚定**：每句话是否可追溯到 Evidence Map 中的至少一条证据？若陈述为推理而非事实，是否标注了推理前提？
- **强度匹配**：陈述的确定性与证据级别是否匹配？（S 级→"证明/确立"，A 级→"表明/展示"，B 级→"暗示/初步表明"，无证据→标注"推测/假设"）
- **禁止词汇**：是否使用了"obviously""clearly""fundamentally""many systems""industry needs""always""never""all""none"等无支撑的绝对化表述？若有，必须删除或附加限定条件。

#### 段级逻辑验证

对 section 1-10 中的每个段落（≥3 句的语义段落）执行：

- **Claim-Evidence-Reasoning 链**：段落是否包含明确的主张句 → 证据引用句 → 推理连接句？三者缺一不可。
- **逻辑跳跃检测**：从证据到结论的推理步骤是否每步清晰？是否存在"A 快，所以 A 更好"式的隐含价值判断（"快"不一定"更好"，需说明为什么快是决定性指标）？
- **前提声明**：推理中使用的任何未在 Evidence Map 中出现的前提必须显式声明并标注为"未验证前提"。

#### 跨段逻辑一致性

对整个 Final Report 执行：

- **矛盾检测**：Section 3 (Strong Claims) 和 Section 4 (Weakened Claims) 之间是否存在语义矛盾？Section 7 (Counterexamples) 是否与 Section 3 中的任何声称冲突？
- **范围一致性**：Section 1 (Final Thesis) 的表述范围是否 ≤ Evidence Map 中各条 allowed wording 范围的交集？Thesis 不得超出证据支撑的范围。
- **未解决批判追踪**：Section 7 (Counterexamples) 中的每个 attack 是否在 Section 8 (Remaining Risks) 或 Section 9 (Evaluation Obligations) 中有对应处置？任何未处置的 critical/high severity attack 即为逻辑漏洞。

#### 逻辑 Audit 通过标准

- 0 个"无证据锚定的陈述句"（推理句除外，但推理前提必须声明）
- 0 个"强度不匹配"的陈述（A 级证据支撑 S 级确定性表述）
- 0 个禁止词汇
- 0 个"缺少推理连接的段落"
- 0 个"未解决的跨段矛盾"
- 0 个"未处置的 fatal/high attack"

未能通过的条目必须在 Final Report 中显式标记（在对应句子/段落后标注 `[LOGIC-GAP: 具体问题]`），并在 Section 8 Remaining Risks 中加入"逻辑风险"条目。

### 14. Story Quality Audit

逐条通过 `templates/story-checklist.md` 的 17 项自检和 11 项写作规则。在此记录审计结果：

#### One-Sentence Thesis Check

| 句子 | 质量检查 | 状态 |
|---|---|---|
| 问题句 | 场景 + 冲突性质 + 失效假设 齐全？ | PASS / GAP |
| 洞见句 | 包含"重新组织问题"的动作？ | PASS / GAP |
| 系统句 | 核心设计 + 关键指标 + 相对 baseline 优势？ | PASS / GAP |
| 三句连读 | 形成完整逻辑闭环？ | PASS / GAP |

#### 17-Point Self-Check Summary

| # | 检查项 | 状态 |
|---|---|---|
| 1 | 核心问题能否一句话说清楚？ | |
| 2 | 场景是否具体？ | |
| ... | ... | |
| 17 | 读者能学到一般性思想？ | |

未通过项 = `[STORY-GAP: ...]`。STORY-GAP > 3 时不得生成最终 Final Report。

#### Writing Rules Summary

| # | 规则 | 状态 |
|---|---|---|
| W1 | 贡献不以"我们实现了"开头 | |
| W2 | 无口号式形容词 | |
| ... | ... | |
| W11 | 包含 One-Sentence Thesis | |

---

## Incremental Update Rules

- Final Report 不支持增量更新。每次 Convergence 后应生成新的 Final Report。
- 若需对比历史版本，保留旧版本的 Final Report 文件（建议按日期或轮次命名，如 `final-report-round-1.md`），不要在同一文件中覆盖历史结论。
- Decision Ledger 中的每次状态转换（keep/weaken/split/merge/delete/mark_as_risk）必须在 Research Trace 中保留完整记录，Final Report 只引用最终状态。

---

## Template

### 1. One-Sentence Thesis

**问题句**：

**洞见句**：

**系统句**：

### 2. Problem Framing (Basic System Definition)

- **Scene & Setting**：
- **Core Object**：
- **Key Constraint**：
- **Necessary Assumptions**：
- **Goal & Required Properties**：
- **Relevant Existing Approaches**（按设计哲学分类）：
- **Claimed Limitation & Root Cause**：

### 3. Strong Claims (含 Strawman Analysis)

- SC1: [claim text]
  - **Strawman S1**：[最直接的方案]。Satisfies ___ because ___. Violates ___ because ___.
  - **Strawman S2**：[相反方向的方案]。Satisfies ___ because ___. Violates ___ because ___.
  - **Root cause**：

### 4. Weakened Claims

### 5. Deleted Claims

### 6. Evidence Map

| Claim | Evidence | Status | Allowed Wording | Remaining Risk |
|---|---|---|---|---|
|  |  |  |  |  |

### 7. Counterexamples And Reviewer Attacks

#### Reviewer Attack Defence Table

| # | Attack | Defence |
|---|---|---|
| 1 | 这个问题真实存在吗？ | |
| 2 | 为什么现有方法不能直接解决？ | |
| 3 | 场景是否人为构造？ | |
| 4 | 假设是否太强？ | |
| 5 | threat model 是否回避最难问题？ | |
| 6 | 设计是否只是工程组合？ | |
| 7 | insight 是否只是换了个说法？ | |
| 8 | 实验是否只选了有利 case？ | |
| 9 | baseline 是否公平？ | |
| 10 | 指标是否证明了 claim？ | |
| 11 | 机制是否引入了新问题？ | |
| 12 | 贡献是否可以推广？ | |

### 8. Remaining Risks

### 9. Evaluation Obligations

**Primary Metric**：
**Cost Metric**：
**Robustness Metric**：

| Claim | Required Evaluation | Baseline | Workload | Metric | Falsification |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

### 10. Story Closure Table

| Challenge | Insight Part | Design Component | Invariant | Experiment | Metric | Status |
|---|---|---|---|---|---|---|
|  |  |  |  |  |  | closed / gap |

闭包检查：每个 challenge 有 evaluation？每个 design 有 challenge？每个 evaluation 有 claim？每个 claim 有 metric？

### 11. Paper-ready Or Proposal-ready Text

### 12. Research Trace Appendix

#### Decision Ledger

| Claim | Old Version | Decision | New Version | Reason | Remaining Risk |
|---|---|---|---|---|---|
|  |  | keep / weaken / split / merge / delete / mark_as_risk |  |  |  |

### 13. Logic Consistency Audit

#### 句级检查

| Section | 句子 | 证据锚定 | 强度匹配 | 禁止词汇 | 状态 |
|---|---|---|---|---|---|
|  |  |  |  |  | PASS / LOGIC-GAP |

#### 段级检查

| Section | 段落 | C-E-R 链完整 | 逻辑跳跃 | 前提声明 | 状态 |
|---|---|---|---|---|---|
|  |  |  |  |  | PASS / LOGIC-GAP |

#### 跨段检查

| 检查项 | 涉及 Sections | 结果 | 处置 |
|---|---|---|---|
| Strong vs Weakened 矛盾 | §3 ↔ §4 |  |  |
| Counterexample vs Strong 冲突 | §7 ↔ §3 |  |  |
| Thesis 范围 ≤ Evidence 范围 | §1 ↔ §6 |  |  |
| Attack 处置完整性 | §7 ↔ §8 ↔ §9 |  |  |

### 14. Story Quality Audit

#### One-Sentence Thesis Check

| 句子 | 状态 |
|---|---|
| 问题句 | PASS / GAP |
| 洞见句 | PASS / GAP |
| 系统句 | PASS / GAP |
| 三句连读 | PASS / GAP |

#### 17-Point Self-Check

| # | 检查项 | 状态 |
|---|---|---|
| 1-6 | 问题定义 | |
| 7-9 | 洞见与设计 | |
| 10-12 | 评估 | |
| 13-17 | 表达 | |

#### Writing Rules Check

| # | 规则 | 状态 |
|---|---|---|
| W1-W7 | 禁止项 | |
| W8-W11 | 必须项 | |
