# Evidence Ledger

## Trigger

在 **Pass 2: Validation** 的 Evidence Search 和 Normalization 阶段填写。每找到并归一化一个重要来源，追加一行并完成其 Normalization 详情。

## Example

| ID | Source | Type | Level | Related Claims | Relation | Direct Support | Limits | Allowed Wording | Forbidden Wording |
|---|---|---|---|---|---|---|---|---|---|
| E1 | OSDI'23 "FooSystem" | paper | S | C1 | supports | 在 1000-node 集群上测得 p99 延迟 42ms | 仅测试了批处理工作负载，未覆盖流式处理 | FooSystem 在批处理场景下将 p99 延迟降低至 50ms 以下 | FooSystem 在所有场景下都优于基线 |
| E2 | Linux kernel sched/core.c L3120 | source_code | A | C2 | supports | eBPF 程序在用户态与内核态切换时无需保存完整寄存器上下文 | 仅适用于 x86_64，ARM64 路径不同 | eBPF 上下文切换开销低于 ptrace | eBPF 在所有架构上都优于 ptrace |

## Incremental Update Rules

- **追加新证据**：每归一化一个新的来源，在表格底部追加一行。同一来源被多个 Lens 引用时，只保留一个 Evidence ID，但在 `Related Claims` 或备注中标注多个 Lens 的独立评估。
- **证据级别变更时追加记录**：若后续 Re-search 导致证据级别变化（如 `B` → `A` 或 `A` → `C`），追加新行（如 `E1-rev1`）标注更新后的级别和原因，保留原行。必须在 Research Trace 中引用导致变化的来源。
- **冲突证据保留可见性**：同一 claim 存在支持证据和削弱证据时，两条都保留在表格中，分别标注 `supports` 和 `contradicts`（或 `weakens`）。不得因冲突而隐藏或删除任一方。
- **Duplicate source handling**：若两个 Lens 引用了同一篇论文的同一章节，合并为一条证据条目，但在 Evidence Normalization 的备注中记录 `"cross-lens annotations: Scout assessed as A, Counterexample assessed as B"`。
- **禁止物理删除**：任何证据条目不得删除。即使后续被证伪或发现来源不可靠，将其 `Level` 改为 `D` 或 `relation` 改为 `contradicts`，保留原始记录。

## Template

| ID | Source | Type | Level | Related Claims | Relation | Direct Support | Limits | Allowed Wording | Forbidden Wording |
|---|---|---|---|---|---|---|---|---|---|
| E1 |  | paper / official_doc / artifact / cve / benchmark / issue / standard / technical_report | S / A / B / C / D | C1 | supports / weakens / contextualizes / contradicts |  |  |  |  |

## Evidence Normalization

### Evidence E1

Source:

Type:

Level:

Related claim:

What it directly supports:

What it does not support:

Applicable scenario:

Boundary:

Possible misuse:

Allowed wording:

Forbidden wording:
