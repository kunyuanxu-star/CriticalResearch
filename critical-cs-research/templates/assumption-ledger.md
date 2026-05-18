# Assumption Ledger

## Trigger

在 **Pass 1: Discovery** 的 First-Principles Decomposition 阶段填写。每识别出一个隐藏假设或显式假设，立即追加一行。此 Ledger 是 Checkpoint A 和 Checkpoint B 的核心呈现材料之一。

## Example

| ID | Related Claim | Assumption | Why It Matters | Evidence Needed | Status |
|---|---|---|---|---|---|
| AS1 | C1 | 攻击者无法物理接触目标设备 | 决定了 TCB 的边界是否包含物理安全 | 需要明确威胁模型是否排除物理攻击 | unverified |
| AS2 | C2 | 工作负载服从 Zipf 分布 | 缓存优化策略的有效性依赖于该分布假设 | 需引用真实工作负载的分布测量数据 | supported |

## Incremental Update Rules

- **状态更新时追加行**：不要覆盖旧的假设行。当假设状态变化时，追加新行并更新状态，保留历史状态以便追溯。例如：
  - 初始：`AS1 | ... | unverified`
  - 验证后追加：`AS1-r2 | ... | supported`（或直接在原行更新状态，但在 Research Trace 中记录变更）。
- **与 Checkpoint B 联动**：Checkpoint B 中向用户呈现的"已识别的隐藏假设"直接引用此 Ledger 中所有 `status = unverified` 的条目。
- **假设被证伪时的处理**：将状态改为 `falsified`，并在 Research Trace 的 Decision Ledger 中记录由此触发的 claim 修订（weaken / delete / split）。

## Template

| ID | Related Claim | Assumption | Why It Matters | Evidence Needed | Status |
|---|---|---|---|---|---|
| AS1 | C1 |  |  |  | unverified |
