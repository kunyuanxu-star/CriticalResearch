# Research Trace

## Trigger

在 **Pass 3: Convergence** 期间持续填写。此文件记录研究循环的完整痕迹，包括所有原始输入、假设、反例、决策和评估映射。它应在每个 Pass 结束后追加新章节，而不是覆盖旧内容。

## Example

### Problem Object

```yaml
problem_id: P001
raw_user_input: |
  我想用 eBPF 做容器安全监控，听说比 ptrace 快，但不确定兼容性。
normalized_problem: |
  验证 eBPF 在容器安全监控场景下相对于 ptrace 的性能优势和兼容性。
cs_area:
  primary: systems
  secondary: [security]
target_output: [idea_validation]
target_venue_level: workshop
main_uncertainty: |
  eBPF 的实际开销是否足够低以替代 ptrace？
must_prove: [eBPF overhead < ptrace overhead, compatible with seccomp-bpf]
must_not_assume: [所有内核版本都支持, 所有架构都适用]
```

### Assumption Ledger

| ID | Related Claim | Assumption | Why It Matters | Evidence Needed | Status |
|---|---|---|---|---|---|
| AS1 | C1 | 目标内核 ≥5.8 | eBPF LSM hook 在 5.8 引入 | 检查用户环境内核版本 | supported |
| AS2 | C2 | 工作负载为典型微服务 | 高并发场景可能行为不同 | 需要明确工作负载定义 | risk |

### Counterexample Ledger

| ID | Target Claim | Counterexample / Prior Work / Alternative | Source | Effect On Claim | Follow-up |
|---|---|---|---|---|---|
| X1 | C1 | Firecracker 使用更轻量的 VM-based 监控 | Firecracker NSDI'20 | narrows | 明确 eBPF  vs VM-based 的适用边界 |

### Decision Ledger

| Decision ID | Target Claim | Decision | Old Claim | New Claim | Reason | Remaining Risk |
|---|---|---|---|---|---|---|
| D1 | C1 | weaken | "eBPF 总是优于 ptrace" | "eBPF 在标准微服务负载下优于 ptrace" | 未在高并发场景验证 | 高并发场景性能未知 |
| D2 | C3 | delete | "完全替代 ptrace" | - | ptrace 在调试场景不可替代 | - |

### Claim-to-Evaluation Map

| Claim | Required Evaluation | Baseline | Workload | Metric | Falsification |
|---|---|---|---|---|---|
| C1 | benchmark | ptrace | Kubernetes microservices | CPU overhead p99 | >10% |

---

## Incremental Update Rules

- **追加而非覆盖**：每个新的 Pass 或 Re-search 轮次应在文件末尾新增一个章节（如 `## Research Round 1`），保留所有历史内容。
- **已废弃条目不删除**：若假设被证伪或主张被删除，将其状态更新为 `falsified` / `deleted`，并追加 Decision Ledger 记录，不要从历史表格中物理删除行。
- **Lens 原始输出保留**：在 Deep 模式下，每个 Role-Lens 的原始输出应作为子章节保留（`## Raw Lens Output: Research Scout` 等），即使部分内容未进入最终结论。
- **决策链可追溯**：任何 Decision Ledger 的变更必须能通过行号/章节引用回溯到具体的证据或批判条目。

---

## Template

### Problem Object

```yaml
problem_id: P001
raw_user_input: |
  
normalized_problem: |
  
cs_area:
  primary:
  secondary: []
target_output: []
target_venue_level:
main_uncertainty: |
  
must_prove: []
must_not_assume: []
```

### Assumption Ledger

| ID | Related Claim | Assumption | Why It Matters | Evidence Needed | Status |
|---|---|---|---|---|---|
| AS1 | C1 |  |  |  | unverified |

### Counterexample Ledger

| ID | Target Claim | Counterexample / Prior Work / Alternative | Source | Effect On Claim | Follow-up |
|---|---|---|---|---|---|
| X1 | C1 |  |  | weakens / contradicts / narrows / contextualizes |  |

### Decision Ledger

| Decision ID | Target Claim | Decision | Old Claim | New Claim | Reason | Remaining Risk |
|---|---|---|---|---|---|---|
| D1 | C1 | keep / weaken / split / merge / delete / mark_as_risk |  |  |  |  |

### Claim-to-Evaluation Map

| Claim | Required Evaluation | Baseline | Workload | Metric | Falsification |
|---|---|---|---|---|---|
| C1 |  |  |  |  |  |
