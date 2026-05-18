# Role Lenses

Use these as mental passes inside the same agent by default. Only create actual subagents if the user explicitly asks for parallel agents or delegation.

## Claim Parser

Only decompose the material. Do not research or conclude.

Outputs: problem framing, claim ledger, assumption ledger.

## Research Scout

Only gather and normalize supporting evidence. Do not write the final conclusion.

Outputs: evidence ledger, source notes.

## Counterexample Finder

Search for prior work, baselines, edge cases, and counterexamples.

Outputs: counterexample ledger, baseline map.

## Adversarial Reviewer

Attack the argument like a top-tier CS reviewer.

Outputs: critique ledger, gap backlog.

## Evidence Auditor

Check whether each claim is stronger than the evidence allows.

Outputs: evidence audit, allowed wording, forbidden wording.

## Experiment Mapper

Map claims to evaluation obligations.

Outputs: claim-to-evaluation map, experiment obligations.

## Synthesis Writer

Write only from claims that survived critique and evidence audit.

Outputs: final report, paper-ready or proposal-ready text.

---

## Concurrency Contract (Standard / Deep Mode)

在 Standard 和 Deep 模式下，以下 Role-Lens 可作为并行 Pass 执行：

### Parallel Pass 1: Discovery Lenses

可并发：
- **Claim Parser**（分解主张）
- **Research Scout**（预搜集基线信息）

不可并发：First-Principles Decomposition 必须在 Claim Decomposition 完成后执行。

### Parallel Pass 2: Validation Lenses

可并发：
- **Research Scout**（深度证据搜索与归一化）
- **Counterexample Finder**（搜索反例和基线）
- **Adversarial Reviewer**（基于 draft claim 进行预判 critique）

注意：Adversarial Reviewer 的预判 critique 在 Evidence Normalization 后可能需要修正；最终 Critique Ledger 必须反映证据归一化后的状态。

### Merge Rules

1. **证据冲突**：若 Research Scout 和 Counterexample Finder 对同一主张找到矛盾证据，记录为 `contradicts`，提升该主张的审查优先级，不自动删除。
2. **批判重叠**：若 Adversarial Reviewer 和 Counterexample Finder 提出相同 critique，合并为一条并标注双重来源。
3. **信息丢失禁止**：任何 Lens 的原始输出必须保留在 Research Trace Appendix 中，即使未进入 Final Report。
4. **饱和度计算**：由 Evidence Auditor 在 Merge 后统一计算，不允许单个 Lens 自行声明饱和度。
