# Final CS Research Report

## Trigger

在 **Pass 3: Convergence** 的 Convergence Check 通过后填写。这是整个研究循环的唯一最终输出文件，必须由 Synthesis Writer 基于所有已验证的主张、证据和批判撰写。

## Example

### 1. Final Thesis

本工作提出了一种基于 eBPF 的轻量级容器安全监控机制，在不修改内核的前提下，将安全事件追踪开销从 ptrace 方案的 35% 降低至 5% 以内，同时保持与现有 seccomp-bpf 策略的兼容性。

### 2. Problem Framing

现有容器安全监控主要依赖 ptrace 或内核模块。ptrace 开销高（上下文切换频繁），内核模块需要维护成本且存在稳定性风险。eBPF 提供了一种在内核态安全执行自定义代码的机制，但其在容器安全监控场景下的系统开销和兼容性尚未被系统性验证。

### 3. Strong Claims

- SC1: 在标准微服务工作负载下，eBPF 监控的 CPU 开销 <5%（vs ptrace 的 30-40%）。
- SC2: 无需修改现有 seccomp-bpf 策略即可并行部署。

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

### 8. Remaining Risks

- ARM64 架构验证缺失。
- 高并发场景下开销上升。
- eBPF verifier 复杂性带来的潜在绕过。

### 9. Evaluation Obligations

| Claim | Required Evaluation | Baseline | Workload | Metric | Falsification |
|---|---|---|---|---|---|
| SC1 | benchmark | ptrace-based monitoring | Kubernetes microservices | CPU overhead p99 | >10% |
| SC2 | compatibility test | seccomp-bpf alone | Standard container workloads | Policy conflict count | >0 |

### 10. Paper-ready Or Proposal-ready Text

[此处插入可直接用于投稿的段落，仅使用 Evidence Map 中 allowed wording 的表述]

### 11. Research Trace Appendix

[引用完整的研究痕迹文件路径或内嵌关键决策记录]

---

## Incremental Update Rules

- Final Report 不支持增量更新。每次 Convergence 后应生成新的 Final Report。
- 若需对比历史版本，保留旧版本的 Final Report 文件（建议按日期或轮次命名，如 `final-report-round-1.md`），不要在同一文件中覆盖历史结论。
- Decision Ledger 中的每次状态转换（keep/weaken/split/merge/delete/mark_as_risk）必须在 Research Trace 中保留完整记录，Final Report 只引用最终状态。

---

## Template

### 1. Final Thesis

### 2. Problem Framing

### 3. Strong Claims

### 4. Weakened Claims

### 5. Deleted Claims

### 6. Evidence Map

| Claim | Evidence | Status | Allowed Wording | Remaining Risk |
|---|---|---|---|---|
|  |  |  |  |  |

### 7. Counterexamples And Reviewer Attacks

### 8. Remaining Risks

### 9. Evaluation Obligations

| Claim | Required Evaluation | Baseline | Workload | Metric | Falsification |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

### 10. Paper-ready Or Proposal-ready Text

### 11. Research Trace Appendix

#### Decision Ledger

| Claim | Old Version | Decision | New Version | Reason | Remaining Risk |
|---|---|---|---|---|---|
|  |  | keep / weaken / split / merge / delete / mark_as_risk |  |  |  |
