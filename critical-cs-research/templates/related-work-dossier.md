# Related Work Dossier

## Trigger

在 **Pass 1: Discovery** 的 Problem Framing 阶段识别关键相关资料后创建初始条目。每个被识别为与当前研究直接相关的论文、系统、标准或技术方案，建立一个独立的 Work 章节。

在 **Pass 2: Validation** 的 Evidence Search 和 Adversarial Critique 阶段、以及 **Pass 3: Convergence** 的 Targeted Re-search 阶段，随着理解加深，追加 `Understanding Evolution` 记录。

## 字段说明

每条相关工作的 7 个核心字段对应一项完整学术分析的逻辑链：

| # | 字段 | 对应问题 | 分析目的 |
|---|---|---|---|
| 1 | Scene & Context | 该工作在什么场景下运行？部署环境是什么？ | 确定适用范围和边界条件 |
| 2 | Motivation | 该工作因何而生？解决什么痛点或填补什么空白？ | 理解问题的真实性和紧迫性 |
| 3 | Contradiction Resolved | 该工作解决了什么根本性的矛盾或张力？（如隔离 vs 性能、表达力 vs 安全性、一致性 vs 延迟） | 识别核心贡献的本质——不是"做了什么"而是"解决了什么冲突" |
| 4 | Core Design / Mechanism | 关键的洞察或机制是什么？抽象层次如何变化？ | 理解技术方案的本质，而非实现细节 |
| 5 | Experimental Validation | 用什么工作负载/基准测试验证？基线是什么？关键结果和指标是什么？ | 评估声明的可验证性和实验设计的合理性 |
| 6 | Limitations & Boundaries | 该工作未解决什么？已知局限是什么？适用范围边界在哪里？ | 识别当前研究的切入点——别人没做什么 |
| 7 | Relevance to Current Research | 与当前研究的主张有何关系？支持、削弱还是限定？可以借鉴或必须区分的点是什么？ | 将该工作映射到当前研究的论证结构中 |

## Iterative Refinement Rules

- **Pass 1 初始创建**：首次识别时无需填满所有字段。至少填写 Scene & Context、Motivation 和初步的 Relevance 判断。未填字段标注 `[待补充 — Pass 2]`。
- **Pass 2 加深**：Evidence Search 获得更多信息后，补全 Contradiction Resolved、Core Design、Experimental Validation 和 Limitations。在 `Understanding Evolution` 中记录"Round 2: 新发现的要点 + 对当前研究主张的影响"。
- **Pass 3 完善**：Targeted Re-search 后，修正任何之前理解有误的字段（保留原文，用删除线标记并追加修正）。在 `Understanding Evolution` 中记录"Round 3: 最终理解 + 收敛后的 relevance 判断"。
- **Re-search 轮次**：每次 Re-search 后若有新认识，追加新的 Understanding Evolution 条目，标注轮次编号。

## Example

### Work W1: Firecracker

**Bibliographic Info**
- Title: Firecracker: Lightweight Virtualization for Serverless Applications
- Authors: Agache et al.
- Venue/Year: NSDI 2020
- Link: https://www.usenix.org/conference/nsdi20/presentation/agache

**Scene & Context**
- 场景：AWS Lambda 的多租户 serverless 环境，需要在同一物理机上运行数千个短生命周期函数实例。
- 部署环境：裸金属服务器上的 KVM-based microVM，每个函数实例运行在独立的 microVM 中。

**Motivation**
- 痛点：传统 VMs 隔离性好但启动慢（数百 ms）、内存开销大；容器启动快但共享内核，隔离边界弱（尤其是 /proc, /sys 侧信道）。
- 目标：同时达到 VM 级隔离和容器级启动速度与密度。

**Contradiction Resolved**
- 根本矛盾：**隔离性 vs 启动速度与资源密度**。更强的隔离（独立内核、独立地址空间）需要更多资源和更长的初始化时间。
- 解决方案思路：不消除矛盾，而是寻找 Pareto 前沿上的新平衡点——通过极度精简的 VMM（移除 BIOS、virtio、guest OS 膨胀）将 VM 启动压到 ~125ms，从而在不牺牲隔离的前提下逼近容器的启动速度。

**Core Design / Mechanism**
- 极简 VMM：用 Rust 重写设备模型（virtio-net, virtio-block），移除传统 VMM 中的模拟硬件（BIOS、PCI 总线扫描、ACPI 表等）。
- 内存共享：通过 memory balloon 和 page sharing 减少 per-microVM 的内存占用。
- API 驱动的 MicroVM 生命周期：通过 RESTful API 创建、启动、暂停、终止 microVM，而非传统虚拟化管理栈。

**Experimental Validation**
- 工作负载：启动延迟 microbenchmark + 真实 Lambda 函数 trace。
- 基线：QEMU microVM（未优化）、Linux containers（containerd）。
- 关键结果：冷启动 125ms（vs QEMU 的 400ms+），内存开销 <5MB per microVM。容器密度 >1000 per host。
- 指标：启动延迟（p50, p99）、内存占用、CPU 开销、功能兼容性（支持的 syscall 覆盖率）。

**Limitations & Boundaries**
- 仅支持 Linux guest，不支持 Windows。
- 不支持 live migration。
- vsock 和 GPU 透传不在设计范围内。
- 强依赖 KVM，无法在非 Linux 宿主机或无硬件虚拟化的环境中运行。
- 极简 VMM 模型意味着不支持传统虚拟化的高级特性（快照、热迁移、设备热插拔）。

**Relevance to Current Research**
- 如果我们的主张是"容器隔离可通过 eBPF 加强到接近 VM 级别"：Firecracker 是一个反例——它从 VM 方向逼近，而我们是从容器方向逼近。需要在 Overhead 和隔离性两个维度上对比。
- 如果我们的主张是"我们的轻量级隔离比 Firecracker 更快"：必须澄清我们的 security boundary 是否与 Firecracker 一致——Firecracker 有独立内核，我们可能没有。
- Relevance 判断：`contextualizes`（限定了我们主张的适用范围——独立内核隔离 vs 共享内核加固是不可比的，除非显式论证 threat model 一致）。

**Understanding Evolution**
- Round 1 (Pass 1): 初始了解——Firecracker 是 AWS 的轻量级 VM。需要确认它是否是我们方案的可比基线。我们的 threat model 可能不同。
- Round 2 (Pass 2): 深入后发现 Firecracker 的 125ms 冷启动实际上是在已预热的 microVM 池中取得的（balloon 而非 cold），与我们方案的 benchmark 条件不同。这构成一个 critique：我们的对比基线可能不公平。
- Round 3 (Pass 3): 最终理解——Firecracker 应与我们的方案在相同 threat model 下对比，且 benchmark 条件需对齐（cold start from scratch vs from pool）。在 Final Report 中将此项对比标记为"不同 threat model，不可直接竞争"。

---

## Template

### Work W1: [Title]

**Bibliographic Info**
- Title:
- Authors:
- Venue/Year:
- Link:

**Scene & Context**
- 场景：
- 部署环境：

**Motivation**
- 痛点：
- 目标：

**Contradiction Resolved**
- 根本矛盾：
- 解决方案思路：

**Core Design / Mechanism**
- 关键洞察：
- 核心机制：

**Experimental Validation**
- 工作负载：
- 基线：
- 关键结果：
- 指标：

**Limitations & Boundaries**
- 未解决的问题：
- 适用范围边界：

**Relevance to Current Research**
- 与当前主张的关系（supports / weakens / contextualizes / contradicts）：
- 可借鉴点：
- 必须区分的点：
- Relevance 判断：

**Understanding Evolution**
- Round 1 (Pass 1):
- Round 2 (Pass 2):
- Round 3 (Pass 3):
- [追加额外的轮次]
