# Final CS Research Report

## Trigger

在 **Pass 3: Convergence** 的 User Satisfaction Gate 通过后填写。这是整个研究循环的最终输出文件，必须由 Synthesis Writer 基于所有已验证的主张、证据和批判撰写。

## Example (illustrative — replace with your domain)

### 1. One-Sentence Thesis

**问题句**：在 <domain> 场景中，现有方法无法同时满足 <property-P1> 和 <property-P2>，因为它们依赖 <assumption-A1> 或 <assumption-A2>，而这两个假设在 <realistic-setting> 中均失效。

**洞见句**：我们观察到，虽然 <naive-approach> 需要 <full-cost>，但在 <key-boundary-or-structure> 处，只需要 <reduced-scope>，就足以覆盖 <coverage-fraction> 的需求，同时将 <cost-dimension> 缩短一个数量级。

**系统句**：基于这一观察，我们设计 <method-name>，将原本需要 <full-problem> 的问题转化为仅在 <restricted-condition> 处触发的 <core-mechanism>，从而在 <standard-workload> 下将 <metric> 从 <baseline-value> 降低至 <target-value> 以内。

### 2. Problem Framing (Basic System Definition)

- **Scene & Setting**：<concrete environment — cluster, compiler pipeline, training loop, query engine, UI framework, etc.>
- **Core Object**：<the thing being studied — events, IR nodes, gradients, query plans, interaction traces, etc.>
- **Key Constraint**：<inviolable constraint — cannot modify X, must stay under Y ms, must preserve Z invariant>
- **Necessary Assumptions**：<named assumptions A1, A2, ... — each falsifiable>
- **Goal & Required Properties**：<P1, P2 with concrete thresholds or guarantees>

### 3. Strong Claims (含 Strawman Analysis)

- SC1: <claim text with concrete metric and baseline comparison>.
  - **Strawman S1 (<most-obvious-approach>)**：<description> → satisfies <P> because ___ but violates <P'> because ___.
  - **Strawman S2 (<opposite-direction-approach>)**：<description> → satisfies <P'> because ___ but violates <P> because ___.
  - **Root cause**：Both strawmans assume <shared-assumption>. In <real-setting>, <why-that-assumption-fails>.

### 4. Weakened Claims

- WC1: Under <edge-condition>, <metric> may degrade to <worse-value>. The original claim "<original>" applies only under <normal-condition>.

### 5. Deleted Claims

- DC1: "<deleted-claim-text>" — deleted because <concrete-reason>.

### 6. Evidence Map

| Claim | Evidence | Status | Allowed Wording | Remaining Risk |
|---|---|---|---|---|
| SC1 | E1 (<venue> <system>), E2 (self benchmark) | supported | <calibrated claim text matching evidence strength> | <unverified condition> |
| SC2 | E3 (<source>) | supported | <calibrated claim text> | <constraint> |

### 7. Counterexamples And Reviewer Attacks

#### Reviewer Attack Defence Table

| # | Attack | Defence |
|---|---|---|
| 1 | 这个问题真实存在吗？ | <cite production data, failure report, or practitioner survey> |
| 2 | 为什么现有方法不能直接解决？ | <state the shared assumption that existing methods rely on, and why it fails> |
| 3 | 场景是否人为构造？ | <cite real traces, benchmarks, or datasets> |
| 4 | 假设是否太强？ | <justify each assumption with deployment data or standard practice> |
| 5 | threat model 是否回避最难的问题？ | <explicit non-goal statement with justification> |
| 6 | 设计是否只是工程组合？ | <state the non-obvious design principle or insight, not the implementation choice> |
| 7 | insight 是否只是换了个说法？ | <explain the problem reformulation, not the tool used> |
| 8 | 实验是否只选了有利 case？ | <describe adversarial or stress workloads included> |
| 9 | baseline 是否公平？ | <describe baseline configuration; confirm it is the strongest reasonable version> |
| 10 | 指标是否证明了 claim？ | <state primary metric and explain why it captures the claimed property> |
| 11 | 机制是否引入了新问题？ | <list known downsides and why they are acceptable or out of scope> |
| 12 | 贡献是否可以推广？ | <state the design lesson or principle that transfers beyond this system> |

### 8. Remaining Risks

- <unverified platform, edge condition, or assumption>
- <known limitation of the mechanism itself>

### 9. Evaluation Obligations

**Primary Metric**：<M1 — the one metric that proves/disproves the core claim>
**Cost Metric**：<M2 — what the approach costs (latency, memory, annotation effort, etc.)>
**Robustness Metric**：<M3 — stress, longevity, adversarial, cross-platform, or ablation>

| Claim | Required Evaluation | Baseline | Workload | Metric | Falsification |
|---|---|---|---|---|---|
| SC1 | <benchmark / proof / user-study / ablation> | <strongest baseline> | <representative workload> | <M1> | <threshold that would refute> |
| SC2 | <compatibility / correctness / generalization test> | <baseline> | <workload> | <M2> | <refute threshold> |

### 10. Story Closure Table

| Challenge | Insight Part | Design Component | Invariant | Experiment | Metric | Status |
|---|---|---|---|---|---|---|
| C1: <tradeoff description> | I1: <key observation> | D1: <mechanism> | <invariant maintained> | Exp1 | M1 | closed |
| C2: <second tradeoff> | I2: <second observation> | D2: <mechanism> | <invariant> | Exp2 | M2 | closed |

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
