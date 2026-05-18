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
- 压缩检查清单（3-5 项），无完整 Evidence Ledger

**Parallel Lenses**: 未启动。Lightweight 模式禁止启动并行 Agent。

**Saturation Calculation**: 不适用。未执行 Evidence Search。

**Convergence/Budget Outcome**:
- Re-search 轮次：0
- 输出：风险评估清单（"unikernel 启动快但兼容性差，需验证具体工作负载"）
- 用户决策：用户选择进入 Standard 模式继续深挖

---

## Scenario 2: Standard — Design Review

**User Input**: "我们设计了一个基于 eBPF 的 Kubernetes 网络策略引擎，能替代 iptables 吗？"

**Selected Mode**: Standard

**Checkpoint Prompts**:
- **Checkpoint A**: 确认问题为"评估 eBPF 网络策略引擎替代 iptables 的可行性"。用户补充：需要对比 tail-latency 和规则更新延迟。
- **Checkpoint B**: 提取 6 个核心主张（C1-C6: 性能、兼容性、可维护性、扩展性、安全性、部署复杂度）。用户删除 C6（部署复杂度），认为非核心。
- **Checkpoint C**: 证据饱和度 60%（3/5 个 claims 有 A 级证据）。呈现 Gap：C2（兼容性）缺少真实混合工作负载测试。用户选择"继续深入"（消耗 1 轮 Re-search 预算）。

**Expected Artifacts**:
- 完整 Claim Ledger（5 条）
- Evidence Ledger（8 条证据）
- Critique Ledger（4 条 critique，其中 2 条 medium → Gap Backlog）
- Gap Backlog（2 条 Gap）

**Parallel Lenses**: 未启动。Standard 模式按顺序执行 Pass 2。

**Saturation Calculation**:
- 分母：5（C1-C5，C6 已删除）
- 分子：3（C1, C3, C5 有 A 级证据且无未解决 high critique）
- 饱和度：60%（<80%，需 Re-search）

**Convergence/Budget Outcome**:
- Re-search 轮次：1（Standard 默认最大 1）
- 针对 C2 补充 2 条证据后，饱和度升至 80%，触发提前收敛
- 输出：标准 Final Report + Research Trace

---

## Scenario 3: Deep — Paper-Scale Rebuttal

**User Input**: "审稿人说我们的系统比 VMs 轻但比容器隔离差，没有证据。帮我们准备 rebuttal。"

**Selected Mode**: Deep

**Checkpoint Prompts**:
- **Checkpoint A**: 确认 rebuttal 目标：证明"比 VMs 轻"和"比容器隔离强"两个方向。用户补充：需要引用 OSDI/SOSP 近 5 年工作。
- **Checkpoint B**: 提取 12 个核心主张（VM 开销、容器隔离边界、新隔离语义、测量方法、真实工作负载等）。用户确认。
- **并行 Lens 许可**（Checkpoint B 之后、Pass 2 之前）：向用户询问"是否允许启动并行分析 Agent？"用户允许。
- **Checkpoint C**: Pass 2 完成后，证据饱和度 58%（7/12 个 claims 有 ≥A 级证据且无 fatal/high critique）。用户选择继续深入。

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

**Convergence/Budget Outcome**:
- Re-search Round 1：针对 G1、G2 补充证据和基准对比。
- Re-search Round 2：补充论文引用和实验数据。
- 最终饱和度：83%（10/12），触发提前收敛。
- 输出：完整 Final Report + 详细 Research Trace（含 Raw Lens Output 章节）

---

## Ambiguity Patches Applied

在验证上述场景时，发现并修补了以下流程歧义：

1. **Lightweight 模式的 Checkpoint 范围**：明确 Lightweight 只执行 Checkpoint A 和 B，Checkpoint C 被跳过或极度压缩（仅向用户确认"是否需要深入"）。
2. **Standard 模式的饱和度触发条件**：明确 Standard 模式也可以触发提前收敛，但最大 Re-search 为 1 轮，因此提前收敛最多节省 1 轮。
3. **Deep 模式的 Agent 许可**：必须在启动并行 Lens 前显式询问用户，否则 fallback 到顺序执行。
4. **饱和度计算中的 weakened claims**：明确 weakened claims 只要拥有 ≥A 证据且无 fatal/high critique，仍计入分子。
5. **Claim Parser 的定位**：明确 Claim Parser 在 Pass 1 执行，其原始输出保留在 Research Trace 中；Deep 模式的并行 Lens 权限提示仅涉及 Pass 2 的 Research Scout / Counterexample Finder / Adversarial Reviewer。
