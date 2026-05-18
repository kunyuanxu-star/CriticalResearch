# Validation Scenarios

## Scenario 1: Lightweight — Vague Idea Validation

**User Input**: "我想做一个比 Docker 更快的容器启动方案，用 unikernel 怎么样？"

**Selected Mode**: Lightweight

**Checkpoint Prompts**:
- **Checkpoint A**: 向用户确认问题是否为"评估 unikernel 是否能比 Docker 更快启动容器"。用户确认。
- **Checkpoint B**: 提取到 2 个核心主张（C1: unikernel 启动更快；C2: 兼容性可接受）。用户确认无需深入。
- **Checkpoint C**: 不适用（Lightweight 无 Pass 2 完整展开）。

**Expected Artifacts**:
- `claim-ledger.md`：2 条 core claims
- `assumption-ledger.md`：1 条假设（工作负载为微服务）
- `related-work-dossier.md`：1-2 项初始条目（如 OSv, MirageOS），仅填写 Scene、Motivation 和 Relevance
- 压缩检查清单（3-5 项），无完整 Evidence Ledger

**Parallel Lenses**: 未启动。Lightweight 模式禁止启动并行 Agent。

**Saturation Calculation**: 不适用。未执行 Evidence Search。

**Convergence/Satisfaction Outcome**:
- 输出：风险评估清单（"unikernel 启动快但兼容性差，需验证具体工作负载"）
- User Satisfaction Gate：用户不满意（"太浅了，我需要具体数字"）→ 自动升级为 Standard 模式继续深挖

---

## Scenario 2: Standard — Design Review

**User Input**: "我们设计了一个基于 eBPF 的 Kubernetes 网络策略引擎，能替代 iptables 吗？"

**Selected Mode**: Standard

**Checkpoint Prompts**:
- **Checkpoint A**: 确认问题为"评估 eBPF 网络策略引擎替代 iptables 的可行性"。用户补充：需要对比 tail-latency 和规则更新延迟。
- **Checkpoint B**: 提取 6 个核心主张（C1-C6: 性能、兼容性、可维护性、扩展性、安全性、部署复杂度）。用户删除 C6（部署复杂度），认为非核心。
- **Checkpoint C**: 证据饱和度 60%（3/5 个 claims 有 A 级证据）。呈现 Gap：C2（兼容性）缺少真实混合工作负载测试。top critique：A2（missing_workload, medium）。用户选择"继续深入"。
- **Checkpoint D (Rebuttal)**: 向用户呈现 top 3 critiques。用户反驳 A2："我们的混合工作负载测试正在进行中，已有初步数据（50 个微服务、30 天 trace、平均 200 条策略规则）。" 确认为第二类 rebuttal（new_evidence）。执行 Mini Validation：对用户提供的初步数据进行 Evidence Normalization（赋 B 级，因为数据尚未公开发布）。追加 Evidence Ledger（E9，来源标注 `user_rebuttal`）。更新 Critique Ledger（A2 标注 `resolved_by_rebuttal`）。关闭 Gap G2（`closed_by_rebuttal`）。饱和度更新为 80%（4/5），触发提前收敛条件。用户确认进入 Pass 3。

**Expected Artifacts**:
- 完整 Claim Ledger（5 条）
- Evidence Ledger（9 条证据，含 1 条 user_rebuttal）
- Critique Ledger（4 条 critique，其中 1 条 resolved_by_rebuttal）
- Gap Backlog（2 条 Gap，其中 1 条 closed_by_rebuttal）
- Related Work Dossier（3-4 项，Pass 2 补全了 Contradiction Resolved、Core Design 和 Limitations）
- Rebuttal Ledger（追加到 Research Trace）

**Parallel Lenses**: 未启动。Standard 模式按顺序执行 Pass 2。

**Saturation Calculation**:
- （Rebuttal 前）分母：5（C1-C5），分子：3，饱和度：60%
- （Rebuttal 后）分母：5，分子：4，饱和度：80%（触发提前收敛）

**Convergence/Satisfaction Outcome**:
- Rebuttal 后饱和度升至 80%，内部质量门槛通过，向用户呈现 Final Report 草稿
- User Satisfaction Gate：用户确认满意（"可以了，够了"）→ 执行 Logic Audit（通过，0 LOGIC-GAP）→ 生成最终 Final Report
- 若用户不满意（如"C4 的 evidence 还是太弱"）→ 回到 Pass 2 针对 C4 补充搜索，无限循环直到用户满意
- 输出：标准 Final Report + Research Trace（含 Rebuttal Ledger 和 Logic Audit）

---

## Scenario 3: Deep — Paper-Scale Rebuttal

**User Input**: "审稿人说我们的系统比 VMs 轻但比容器隔离差，没有证据。帮我们准备 rebuttal。"

**Selected Mode**: Deep

**Checkpoint Prompts**:
- **Checkpoint A**: 确认 rebuttal 目标：证明"比 VMs 轻"和"比容器隔离强"两个方向。用户补充：需要引用 OSDI/SOSP 近 5 年工作。
- **Checkpoint B**: 提取 12 个核心主张（VM 开销、容器隔离边界、新隔离语义、测量方法、真实工作负载等）。用户确认。
- **并行 Lens 许可**（Checkpoint B 之后、Pass 2 之前）：向用户询问"是否允许启动并行分析 Agent？"用户允许。
- **Checkpoint C**: Pass 2 完成后，证据饱和度 58%（7/12 个 claims 有 ≥A 级证据且无 fatal/high critique）。用户选择继续深入。
- **Checkpoint D (Rebuttal)**: 向用户呈现 top 5 critiques（含 2 条 high severity：A2"隔离性声明缺少与 gVisor 的对比"、A4"性能对比基线仅使用默认 Docker 配置而非最优配置"）。用户反驳 A2："gVisor 使用用户态内核，与本方案的 LXC-based 方案系统调用路径不可比——我们的 rebuttal 应强调系统调用延迟而非隔离性。" 确认为第三类 rebuttal（scope_redefinition）。对受影响主张执行 split：将"隔离性优于容器"拆分为"系统调用拦截延迟低"和"隔离边界更窄"。用户承认 A4 有效（不反驳）。sat 更新为 67%（8/12）。用户选择补充 Re-search 后进入 Pass 3。

**Parallel Lenses**:
- **Research Scout + Counterexample Finder**：并发启动，搜索支持证据和反例。
- **Adversarial Reviewer**：在首轮证据返回后启动，基于 draft evidence 进行预判 critique。
- **执行方式**：许可已在 Checkpoint B 后获得。Claim Parser 在 Pass 1 已完成，不纳入 Pass 2 并发组。

**Merge Behavior**:
- Research Scout 找到 E1-E8（支持证据）。
- Counterexample Finder 找到 X1-X3（反例：Firecracker 的轻量级 VM、gVisor 的用户态内核）。
- Adversarial Reviewer 提出 A1-A5（critique）。
- Merge 后：E1-E8 归一化；X1-X3 作为 `weakens` / `narrows` 关联到对应 claims；A1-A5 写入 Critique Ledger，其中 A2、A4 为 high severity，转化为 G1、G2。
- 饱和度计算：7/12 = 58%。

**Saturation Calculation (After Pass 2 Merge)**:
- 分母：12
- 分子：7（7 个 claims 在 Merge 后拥有 ≥A 证据且无 fatal/high critique）
- 饱和度：58%（<80%，继续 Re-search）

**Convergence/Satisfaction Outcome**:
- Round 1：针对 rebuttal 后的新 G2（gVisor 对比）、G3（最优 Docker 配置基线）补充证据和基准对比。
- Round 2：补充论文引用和实验数据。饱和度 83%（10/12），内部质量门槛通过。
- User Satisfaction Gate（Round 2）：呈现 Final Report 草稿。用户表示"C8 的评估义务不够具体，再想想怎么测"。回到 §3.4 Evaluation Obligations，细化 C8 的 falsification condition。
- Round 3：完成 C8 细化后，再次通过 User Satisfaction Gate。用户确认满意。
- Logic Audit：发现 1 个 LOGIC-GAP（Section 1 Thesis 中"显著优于"措辞超出 Evidence Map 的 allowed wording 范围），修正为"在系统调用延迟方面优于"。二次审计通过（0 LOGIC-GAP）。
- 输出：完整 Final Report + 详细 Research Trace（含 Raw Lens Output、Rebuttal Ledger、3 轮迭代记录和 Logic Audit 章节）

---

## Ambiguity Patches Applied

在验证上述场景时，发现并修补了以下流程歧义：

1. **Lightweight 模式的 Checkpoint 范围**：明确 Lightweight 只执行 Checkpoint A 和 B，Checkpoint C 被跳过或极度压缩（仅向用户确认"是否需要深入"）。
2. **Standard 模式的饱和度触发条件**：明确 Standard 模式也可以触发提前收敛，但最大 Re-search 为 1 轮，因此提前收敛最多节省 1 轮。
3. **Deep 模式的 Agent 许可**：必须在启动并行 Lens 前显式询问用户，否则 fallback 到顺序执行。
4. **饱和度计算中的 weakened claims**：明确 weakened claims 只要拥有 ≥A 证据且无 fatal/high critique，仍计入分子。
5. **Claim Parser 的定位**：明确 Claim Parser 在 Pass 1 执行，其原始输出保留在 Research Trace 中；Deep 模式的并行 Lens 权限提示仅涉及 Pass 2 的 Research Scout / Counterexample Finder / Adversarial Reviewer。
6. **Checkpoint D (Rebuttal Phase)**：在 Checkpoint C 确认"继续深入"后、Pass 3 之前强制执行。用户可对批判进行反驳（澄清型 / 新证据型 / 范围重定义型）。Rebuttal 处理后重新计算饱和度并更新所有 Ledger。不充分的 rebuttal 不得自动接受。最多循环 2 次。
7. **Logic Audit (§3.6)**：Convergence Check 通过后、生成 Final Report 前强制执行。审计句级（证据锚定、强度匹配、禁止词汇）、段级（C-E-R 链完整性）、跨段（矛盾检测、范围一致性、攻击处置）。未通过的条目标记 `[LOGIC-GAP]`。LOGIC-GAP > 5 时回到对应 Pass 重新处理。
8. **强制写文件**：每个 Pass 完成后必须将中间结果（Ledger 文件 + Related Work Dossier）写入磁盘。Pass 1→claim/assumption/related-work-dossier/research-trace；Pass 2→evidence/critique/gap-backlog/related-work-dossier 更新 + research-trace 追加；Pass 3→final-report + research-trace 最终版 + related-work-dossier 最终版。所有文件写入同一输出目录（默认 `research-output/`）。
9. **无限循环 + User Satisfaction Gate**：所有模式循环无上限。唯一退出条件为用户明确表示满意（§3.5 Convergence Check）。预算、饱和度、轮次均为进度参考指标，不具有停止效力。内部质量门槛未通过时不得向用户呈现 Final Report 草稿（自动继续迭代）。通过后由 User Satisfaction Gate 决定是否继续。
