---
name: critical-cs-research
description: A domain-general but computer-science-specific critical research loop for OS, networking, security, databases, PL/compilers, architecture, AI infrastructure, distributed systems, software engineering, HCI/CSCW, and technical systems work. Use when Codex must validate a CS research idea, paper motivation, related-work critique, system design, experiment plan, rebuttal, survey, architecture decision, security analysis, or performance diagnosis by decomposing claims, grounding evidence, finding counterexamples, generating research gaps, re-searching, revising claims, mapping evaluation obligations, and producing evidence-backed conclusions.
---

# Critical CS Research

## Core Rule

Do not directly polish or defend the user's original idea. Run the research control loop **indefinitely until the user is convinced**:

`Problem -> Claim -> Assumption -> Evidence -> Counterexample -> Gap -> Re-search -> Revision -> Decision -> Rebuttal -> Re-search -> ... -> User Convinced? No → loop. Yes → stop.`

**Hard rule**: The process does NOT stop because a budget expired, a saturation threshold was met, or a maximum round count was reached. The ONLY valid exit condition is the user explicitly stating they are satisfied with the analysis. If the user expresses any dissatisfaction, identifies a missing angle, provides a new rebuttal, or says anything other than a clear "yes, I'm convinced" — the loop continues.

The final answer must preserve the trace from each conclusion back to claims, evidence, counterexamples, critiques, and decisions. Allow the original idea to be weakened, reframed, marked as risk, or deleted.

## When Starting

1. Identify the task type: idea validation, paper motivation, related-work critique, system design review, experiment planning, rebuttal preparation, survey construction, architecture decision, security analysis, or performance diagnosis.
2. Identify the CS area: systems, networking, security, database, PL/compiler, architecture, software engineering, AI infrastructure, distributed systems, or HCI/CSCW.
3. Read `references/domain-profiles.md` for the relevant profile when the area is clear or when profile-specific checks matter.
4. Read `references/evidence-standards.md` before doing source-backed research or assigning evidence levels.
5. Read `references/role-lenses.md` when the task is large enough to benefit from separate parsing, scouting, counterexample, review, audit, experiment, and synthesis passes.
6. Use `templates/*.md` when the user asks for reusable artifacts, files, or exhaustive output.
7. Run `cr validate <project>` to enforce the paper-mode validator pipeline. Use `cr close-round <project>` to close a round — it runs all validators and blocks if invariants are violated.

If the user has not provided material, ask for it. If target venue, audience, or output form is missing, infer a reasonable default and state it briefly.

## Required Workflow

### Mode Selection (Triage)

根据用户输入的复杂度、主张数量和目标深度，在启动时选择执行模式。如果用户未指定，根据以下标准自动选择或询问。**所有模式的循环次数无上限，用户未被说服则永不停止**：

| 模式 | 适用场景 | 核心主张数 | 建议初始深度 | 外部证据 | 输出粒度 |
|---|---|---|---|---|---|
| **Lightweight** | 快速验证、想法初筛、已有明确结论的复核 | ≤3 | 首轮内部知识为主 | 不搜索 | 压缩检查清单（3-5 项） |
| **Standard** | 常规研究、设计评审、实验计划 | 4-10 | 首轮 1 次搜索 | 需要搜索 | 标准表格 + 简短报告 |
| **Deep** | 投稿级审稿、完整 rebuttal、架构决策 | >10 或不明确 | 首轮深度搜索 + 并发 Role-Lens | 深度搜索 + 并发 | 完整 Ledger + 详细报告 |
| **Paper** | 以论文草稿为中心的研究：每轮同时推进论文修改与知识沉淀 | 不限 | 每轮生成 paper patch、experiment obligation、knowledge delta | 深度搜索 + 并发 | 完整 Ledger + Paper Patch + Knowledge Delta + Round Report |

Lightweight 模式在用户要求深入时自动升级为 Standard 或 Deep。

### Paper Mode

Paper mode extends Deep mode with paper-centered workflow constraints. In this mode:

1. Every medium/high/fatal critique must produce a typed **disposition record** (`critique_disposition.schema.json`)
2. Paper-patch dispositions create tracked **paper patches** with lifecycle state machines
3. Every paper patch must include a **Knowledge Implication** field
4. Every round must produce a **knowledge-delta.md** with typed update classification
5. Thinking rules are stored as **knowledge cards** with maturity tracking (candidate→used→validated→canonical)
6. **Human judgment gates** block round closure for thesis-level patches

To use paper mode, run: `cr migrate-to-paper-mode <project>` to scaffold directories, then set `workflow_mode: paper` in `round.yaml`.

**Validator pipeline** (9 validators in order): cr-validate-schema, cr-validate-artifacts, cr-validate-ids, cr-validate-references, cr-validate-anchors, cr-validate-paper-patches, cr-validate-knowledge, cr-validate-experiments, cr-validate-human-gates.

**Key invariants**: Every round preserves a complete paper draft. Critique→Disposition→Patch→Knowledge Delta chain is enforced. Round cannot close with pending human decisions or missing knowledge delta.

See `.humanize/IMPROVE.md` for the full design specification.
