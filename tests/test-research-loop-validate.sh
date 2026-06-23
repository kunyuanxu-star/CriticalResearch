#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="$ROOT/scripts:$PATH"
export CR_SKILL_HOME="$ROOT"

TMP="$(mktemp -d /tmp/cr-loop-val-XXXXXX)"
trap 'rm -rf "$TMP"' EXIT
cd "$TMP"

passes=0
fails=0

pass() { echo "PASS $1"; passes=$((passes + 1)); }
fail() { echo "FAIL $1"; fails=$((fails + 1)); }

cr workspace init >/dev/null
cr project init proof --domain systems >/dev/null
cr run proof "Test objective" >/dev/null

cat > proof/runs/run-001/research.md <<'MD'
---
schema_version: "1.0.0"
project_id: "proof"
run_id: "run-001"
status: "complete"
phase: "final"
objective: "Test objective"
mode: "standard"
loop_count: 3
loop_budget: 3
weakest_link: "proof_plan"
next_action: "Run the minimum experiment and decide whether to keep or narrow the thesis."
validation:
  error_count: 0
  warning_count: 0
  blocking_attack_count: 0
convergence:
  stall_count: 0
  repeated_attack_count: 0
  scope_challenge_count: 0
  progress_signal: "proof_plan_executable"
gate:
  type: "none"
  description: ""
debug_trace: false
created_at: "2026-06-23T00:00:00Z"
updated_at: "2026-06-23T00:00:00Z"
---

# Research Brief

## Thesis

One-sentence claim: In edge cache deployments with intermittent connectivity, bounded stale observations can be used to preserve recovery latency while avoiding global invalidation.

Expanded thesis: The work argues for a cache invalidation design that treats disconnection as a first-class uncertainty rather than an exceptional failure.

## Basic System

- Setting: Edge deployments with intermittent links between nodes.
- Object: Cache entries and invalidation metadata.
- Goal: Recover correctness after partitions while bounding latency.
- Constraints: Nodes have stale local observations and limited coordination.
- Success condition: Recovery latency improves without violating invalidation safety.

## Core Contradiction

- Need: The system needs timely invalidation decisions before global state is fully known.
- But: Global state is only knowable after reconnection or expensive coordination.
- Therefore the tension is: It must make safe enough local decisions while preserving recoverability under stale observations.

## Strawmen and Root Cause

### Strawman 1
- Approach: Use a fixed TTL for all cache entries.
- Why it seems plausible: TTL avoids coordination during disconnection.
- Concrete failure mode: Short TTLs destroy hit rate while long TTLs extend stale reads after reconnection.

### Strawman 2
- Approach: Require global invalidation acknowledgements.
- Why it seems plausible: Acknowledgements make invalidation status explicit.
- Concrete failure mode: Partitions stall invalidations and make recovery latency depend on the slowest link.

### Shared Root Cause
- Common failure: Both approaches bind correctness to either fixed time or complete global knowledge.
- Deeper cause: They do not model stale observation as a managed state with measurable recovery obligations.

## Key Insight

- Insight: Treating stale observation as an explicit state allows the system to bound recovery work without requiring global knowledge at decision time.
- Why this addresses the root cause: It avoids relying on either fixed time or complete acknowledgements as the only correctness signal.
- What becomes possible: The design can compare recovery latency and stale-read risk against TTL and acknowledgement baselines.

## Design Direction

- Principle: Preserve local progress while making uncertainty recoverable.
- Mechanism: Track per-entry uncertainty metadata and prioritize recovery when connectivity returns.
- Non-goals: Proving full production deployability or all workload classes.

## Minimal Proof Plan

- Claim to test: Explicit uncertainty metadata reduces recovery latency without increasing stale-read violations.
- Metric: Recovery latency and stale-read violation rate.
- Baseline: Fixed TTL and global acknowledgement invalidation.
- Minimum experiment: Simulate partitions and reconnections over representative cache workloads.
- Expected evidence: Lower recovery latency at comparable stale-read violation rate.
- Failure signal: Recovery latency or stale-read violation rate is not better than both baselines.
- Decision rule: Continue only if recovery latency improves by at least 20% without increasing stale-read violations.

## Reviewer Attacks

### Attack A1
- Role: skeptical_reviewer
- Field: proof_plan
- Type: baseline_missing
- Severity: major
- Scope: in_scope
- Argument: TTL and acknowledgement baselines may not be strongest enough.
- Required repair: Add a production invalidation baseline in deep mode.
- Disposition: accepted_risk

### Attack A2
- Role: industry_practitioner
- Field: evidence
- Type: external_gate
- Severity: major
- Scope: gated
- Argument: Real edge traces may be needed before deployment claims.
- Required repair: Mark deployment claims out of scope until traces exist.
- Disposition: deferred

## Evidence Boundary

- Known: TTL and acknowledgement strategies expose a latency/safety tradeoff.
- Assumed: The simulated workload represents edge cache pressure.
- Unknown: Whether production traces show the same partition pattern.
- Thesis-breaking unknown: Production workloads may have no meaningful recovery-latency bottleneck.
- Out of scope: Full production deployment.

## Weakest Link

- Current weakest link: proof_plan
- Why it is weakest: The experiment still needs a stronger production-like baseline.
- What changed in this loop: Added concrete metrics, baselines, and a decision rule.

## Next Minimum Experiment

- Action: Simulate partitions against TTL and acknowledgement baselines.
- Input needed: Synthetic cache workload and partition schedule.
- Output expected: Recovery latency and stale-read violation measurements.
- Decision rule: Continue only if recovery latency improves by at least 20% without increasing stale-read violations.
MD

if cr validate proof >/tmp/cr-valid.out; then
    pass "valid complete brief"
else
    cat /tmp/cr-valid.out
    fail "valid complete brief"
fi

perl -0pi -e 's/### Strawman 2.*?### Shared Root Cause/### Shared Root Cause/s' proof/runs/run-001/research.md
if cr validate proof >/tmp/cr-invalid.out 2>&1; then
    fail "one strawman should fail"
else
    grep -q "E140" /tmp/cr-invalid.out && pass "one strawman fails"
fi

cp proof/runs/run-001/research.md /tmp/invalid.md
cr run proof "Blocked objective" >/dev/null
cat /tmp/invalid.md > proof/runs/run-002/research.md
python3 - <<'PY'
from pathlib import Path
p = Path("proof/runs/run-002/research.md")
s = p.read_text()
s = s.replace('status: "complete"', 'status: "blocked"')
s = s.replace('next_action: "Run the minimum experiment and decide whether to keep or narrow the thesis."', 'next_action: "Ask the user to choose the target scope."')
p.write_text(s)
PY
set +e
cr validate proof --run run-002 >/tmp/cr-blocked.out
rc=$?
set -e
if [ "$rc" -ne 2 ]; then
    pass "blocked terminal allowance"
else
    cat /tmp/cr-blocked.out
    fail "blocked terminal allowance"
fi

echo "RESULT $passes passed, $fails failed"
[ "$fails" -eq 0 ]
