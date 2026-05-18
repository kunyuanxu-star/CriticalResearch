# Plan: Optimize Critical-CS-Research Skill Workflow

## Goal Description

将现有的 11-Phase 线性串行研究循环重构为一个**有预算控制、用户检查点、并行 pass、分层深度**的自适应研究流程。解决当前流程在上下文爆炸、收敛失控、用户交互缺失、模板可用性低等方面的问题，同时保持其核心批判精神和证据标准。

---

## Acceptance Criteria

- **AC-1: 三层执行模式（Triage）**
  - Positive Tests:
    - 给定一个模糊想法，Skill 能自动选择或询问 Lightweight / Standard / Deep 模式。
    - Lightweight 模式在 1 轮交互内输出核心风险点和 3-5 条压缩检查项。
    - Deep 模式启用完整并行 Role-Lens Pass 和多轮循环。
  - Negative Tests:
    - 不允许对简单问题强制走完全部 11 个 Phase。
    - 不允许模式选择缺失导致用户困惑。

- **AC-2: 并行 Role-Lens Passes（Standard/Deep）**
  - Positive Tests:
    - Claim Parser、Research Scout、Counterexample Finder、Adversarial Reviewer 可在 Deep 模式下并发执行。
    - 并发执行后有明确的 Merge 逻辑，不产生矛盾结论。
    - 最终输出保留每个 Role-Lens 的原始痕迹。
  - Negative Tests:
    - 不允许因并行而导致证据级别被错误地重复计算。
    - 不允许 Adversarial Reviewer 的 critique 被后续 Synthesis Writer 忽略。

- **AC-3: 用户检查点（Checkpoints）**
  - Positive Tests:
    - Checkpoint A（问题框架）：Phase 1 结束后必须获得用户确认或修正。
    - Checkpoint B（核心主张）：Phase 2 结束后必须获得用户对 claim set 的确认。
    - Checkpoint C（证据摘要）：Phase 5-6 结束后提供摘要，用户可选择继续深入或提前收敛。
  - Negative Tests:
    - 不允许在没有任何检查点的情况下直接输出 11 部分的 Final Report。
    - 不允许检查点过于频繁（超过 3 个主要检查点）。

- **AC-4: 预算与收敛控制（Budget Control）**
  - Positive Tests:
    - 默认最大 Re-search 循环次数为 2 轮（可配置）。
    - 提供证据饱和度指标（如：Core Claims 有 ≥A 级证据的比例）。
    - 当饱和度达到阈值或预算耗尽时，强制进入 Convergence 并标记剩余风险。
  - Negative Tests:
    - 不允许因一个不可关闭的 Gap 导致无限循环。
    - 不允许未向用户声明预算限制就停止。

- **AC-5: 螺旋式 3-Pass 结构替代线性 11-Phase**
  - Positive Tests:
    - Pass 1 Discovery: 整合原 Phase 0-3（Task Init + Problem Framing + Claim Decomposition + First-Principles），输出 Problem Object + Claim Ledger + Assumption Ledger。
    - Pass 2 Validation: 整合原 Phase 4-7（Evidence Search + Normalization + Adversarial Critique + Gap Backlog），并发执行，输出 Evidence Ledger + Critique Ledger + Gap Backlog。
    - Pass 3 Convergence: 整合原 Phase 8-11（Re-search + Revision + Evaluation + Convergence），受预算控制，输出 Final Report + Research Trace。
    - 每个 Pass 有明确的输入/输出契约。
  - Negative Tests:
    - 不允许 Pass 之间出现信息丢失（如 Assumption Ledger 在 Pass 3 不可见）。
    - 不允许 Pass 2 的 Gap Backlog 被 Pass 3 忽略。

- **AC-6: 模板与 Ledger 可用性增强**
  - Positive Tests:
    - 每个模板文件包含"填充示例"（Example）和"何时填写"（Trigger）说明。
    - Claim Ledger、Evidence Ledger、Critique Ledger 支持增量式更新（每次只追加/修改本轮内容）。
    - 新增 `templates/assumption-ledger.md`（当前缺失但 Phase 3 需要）。
  - Negative Tests:
    - 不允许模板完全空白、无示例。
    - 不允许 Ledger 因格式问题导致 agent 解析失败。

- **AC-7: Claim-Type 到工具/方法的显式映射**
  - Positive Tests:
    - Performance claim 自动映射到 benchmark / workload / trace 工具。
    - Correctness claim 自动映射到 proof sketch / invariant / differential test。
    - Security claim 自动映射到 CVE search / threat-model / TCB comparison。
    - 映射关系写入 `references/evidence-standards.md` 或新增 `references/claim-tool-map.md`。
  - Negative Tests:
    - 不允许所有 claim 类型使用相同的通用搜索策略。
    - 不允许映射关系与 domain-profiles.md 中的 Required Evaluation 冲突。

---

## Path Boundaries

### Upper Bound (Maximum Scope)
- 重写 `SKILL.md` 的 Required Workflow 章节，引入 3-Pass 结构。
- 新增/更新所有模板，包含示例和增量更新指南。
- 新增 `references/claim-tool-map.md` 和 `references/budget-guide.md`。
- 实现一个可运行的脚本或 Agent 指令，支持 Deep 模式下的并发 Role-Lens 执行。
- 更新 `role-lenses.md`，明确每个 lens 在并发场景下的输入输出契约。

### Lower Bound (Minimum Scope)
- 在 `SKILL.md` 中增加"模式选择"和"检查点"段落。
- 为每个模板添加最小化的填写示例（Example）。
- 在 Convergence Check 中增加最大循环次数和证据饱和度阈值。
- 修正现有模板中 Assumption Ledger 缺失的问题（当前 Phase 3 提到 Assumption，但 templates 中无对应文件）。

### Allowed Choices
- **Can use**: 现有证据标准 (S/A/B/C/D)、Domain Profiles、Role Lenses 概念。
- **Can use**: Agent 并发执行（`subagent_type`）来实现并行 passes。
- **Cannot use**: 删除原有的批判精神（不允许直接抛光/辩护原始想法）。
- **Cannot use**: 降低证据标准（C/D 证据仍不能支撑主线 claim）。
- **Cannot use**: 改变文件命名约定（保持 `SKILL.md`, `references/`, `templates/` 结构）。

---

## Dependencies and Sequence

### Milestones

1. **Milestone 1: 诊断与架构决策**
   - Phase A: 用当前 skill 的方法自我诊断现有流程（已完成）。
   - Phase B: 确定 3-Pass 结构的输入输出契约。
   - Phase C: 确定 Checkpoint 位置和 Budget 默认值。

2. **Milestone 2: SKILL.md 核心重构**
   - Phase A: 重写 Workflow 章节（Triage -> Pass 1 -> Checkpoint A -> Pass 2 -> Checkpoint B/C -> Pass 3）。
   - Phase B: 新增 Budget Control 和 Convergence Policy 段落。
   - Phase C: 更新 Final Output 章节，按 Pass 组织输出。

3. **Milestone 3: References 增强**
   - Phase A: 更新 `evidence-standards.md`，增加 Claim-Type 到工具/方法的映射。
   - Phase B: 新增 `budget-guide.md`（预算指南：默认循环次数、饱和度阈值、提前退出条件）。
   - Phase C: 更新 `role-lenses.md`，增加并发执行契约和 Merge 逻辑。

4. **Milestone 4: Templates 可用性升级**
   - Phase A: 为现有 5 个模板增加 Example 和 Trigger 说明。
   - Phase B: 新增 `assumption-ledger.md`。
   - Phase C: 新增 `gap-backlog.md`（将 critique-ledger 中的 Gap Backlog 独立出来，避免单文件过大）。

5. **Milestone 5: 集成测试与验证**
   - Phase A: 用 2-3 个不同复杂度的研究问题测试新流程（Lightweight vs Deep）。
   - Phase B: 验证并发 Role-Lens 执行不丢失信息。
   - Phase C: 验证 Budget Control 能防止无限循环。

---

## Implementation Notes

- **代码/文档不应包含 plan 术语**：更新后的 `SKILL.md` 中不应出现 "AC-1", "Milestone 2" 等 plan 内部词汇。
- **向后兼容**：如果用户明确要求 "按旧流程执行"，应保留旧 11-Phase 的执行路径（可作为 Deep 模式的详细展开）。
- **并发执行限制**：在当前 Kimi CLI 环境中，并发 Agent 数量建议不超过 3-4 个（Claim Parser + Research Scout + Counterexample Finder 可并发，Adversarial Reviewer 建议在证据归一化后执行）。
- **检查点实现方式**：检查点应使用 `AskUserQuestion` 或显式暂停等待用户输入，而不是假设用户会阅读并同意。
- **增量 Ledger 格式**：建议使用 Markdown 的折叠块 (`<details>`) 或分节标题来区分不同轮次的内容，避免单表行数爆炸。
