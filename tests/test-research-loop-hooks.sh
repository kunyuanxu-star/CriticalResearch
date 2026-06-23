#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="$ROOT/scripts:$PATH"
export CR_SKILL_HOME="$ROOT"

TMP="$(mktemp -d /tmp/cr-loop-hooks-XXXXXX)"
trap 'rm -rf "$TMP"' EXIT
cd "$TMP"

NO_JQ_BIN="$TMP/no-jq-bin"
mkdir -p "$NO_JQ_BIN"
cat > "$NO_JQ_BIN/jq" <<'SH'
#!/usr/bin/env bash
echo "jq intentionally blocked by test" >&2
exit 127
SH
chmod +x "$NO_JQ_BIN/jq"
export PATH="$NO_JQ_BIN:$PATH"

passes=0
fails=0
pass() { echo "PASS $1"; passes=$((passes + 1)); }
fail() { echo "FAIL $1"; fails=$((fails + 1)); }

cr workspace init >/dev/null
cr project init other --domain systems >/dev/null
cr run other "Other objective" >/dev/null
cr project init hooks --domain systems >/dev/null
cr run hooks "Hook objective" >/dev/null

set +e
"$ROOT/scripts/cr-hook-stop" "$TMP" >/tmp/cr-stop-draft.out 2>&1
rc=$?
set -e
if [ "$rc" -ne 0 ] && grep -q "not terminal" /tmp/cr-stop-draft.out; then
    pass "stop hook blocks draft"
else
    cat /tmp/cr-stop-draft.out
    fail "stop hook blocks draft"
fi

python3 - <<'PY'
from pathlib import Path
p = Path("hooks/runs/run-001/research.md")
s = p.read_text()
s = s.replace('status: draft', 'status: blocked')
s = s.replace('phase: init', 'phase: final')
s = s.replace('next_action: Form the initial thesis and define the Basic System.', 'next_action: Ask the user to choose the target scope.')
p.write_text(s)
PY

if "$ROOT/scripts/cr-hook-stop" "$TMP" >/tmp/cr-stop-blocked.out 2>&1; then
    grep -q "approve" /tmp/cr-stop-blocked.out && pass "stop hook allows blocked with next action"
else
    cat /tmp/cr-stop-blocked.out
    fail "stop hook allows blocked with next action"
fi

python3 - <<'PY'
from pathlib import Path
p = Path("hooks/runs/run-001/research.md")
s = p.read_text()
s = s.replace('status: blocked', 'status: complete')
s = s.replace('next_action: Ask the user to choose the target scope.', 'next_action: Run the minimum experiment.')
p.write_text(s)
PY

set +e
"$ROOT/scripts/cr-hook-stop" "$TMP" >/tmp/cr-stop-invalid-complete.out 2>&1
rc=$?
set -e
if [ "$rc" -ne 0 ] && grep -q "terminal run failed validation" /tmp/cr-stop-invalid-complete.out; then
    pass "stop hook blocks invalid complete"
else
    cat /tmp/cr-stop-invalid-complete.out
    fail "stop hook blocks invalid complete"
fi

cat > hooks/runs/run-001/research.md <<'MD'
---
schema_version: "1.0.0"
project_id: "hooks"
run_id: "run-001"
status: "complete"
phase: "final"
objective: "Hook objective"
mode: "standard"
loop_count: 3
loop_budget: 3
weakest_link: "proof_plan"
next_action: "Run the minimum experiment and decide whether to continue."
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

One-sentence claim: A bounded local recovery protocol can preserve cache safety under intermittent connectivity.

Expanded thesis: The design treats disconnection as a managed uncertainty state rather than an exceptional failure.

## Basic System

- Setting: Edge cache deployments with intermittent links.
- Object: Cache entries and invalidation metadata.
- Goal: Bound recovery latency after partitions.
- Constraints: Nodes observe stale local state.
- Success condition: Recovery completes without increasing stale reads.

## Core Contradiction

- Need: The cache must make local invalidation decisions before complete global state is known.
- But: Complete global state is unavailable during partitions and expensive immediately after reconnection.
- Therefore the tension is: It must permit local progress while preserving enough recovery information to restore safety.

## Strawmen and Root Cause

### Strawman 1
- Approach: Use a fixed TTL for every cache entry.
- Why it seems plausible: It avoids coordination during partitions.
- Concrete failure mode: Short TTLs destroy hit rate while long TTLs extend stale reads after recovery.

### Strawman 2
- Approach: Require global invalidation acknowledgements.
- Why it seems plausible: Acknowledgements make safety explicit.
- Concrete failure mode: Partitions stall invalidation and make recovery depend on the slowest link.

### Shared Root Cause
- Common failure: Both approaches bind correctness to either fixed time or complete global knowledge.
- Deeper cause: They do not model stale observation as a recoverable state with measurable obligations.

## Key Insight

- Insight: Treating stale observation as explicit metadata lets the system defer global knowledge while bounding recovery work.
- Why this addresses the root cause: It replaces fixed time and complete acknowledgement as the only safety signals.
- What becomes possible: The proof can measure recovery latency and stale-read risk against concrete baselines.

## Design Direction

- Principle: Preserve local progress while making uncertainty recoverable.
- Mechanism: Track uncertainty metadata per entry and prioritize reconciliation when connectivity returns.
- Non-goals: Full production deployment or all cache workloads.

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
- Argument: The baselines may not represent production invalidation systems.
- Required repair: Add a production-like invalidation baseline before stronger claims.
- Disposition: accepted_risk

### Attack A2
- Role: industry_practitioner
- Field: evidence
- Type: external_gate
- Severity: major
- Scope: gated
- Argument: Real edge traces may differ from simulated partitions.
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
- Why it is weakest: The experiment still needs a production-like baseline.
- What changed in this loop: Added concrete metrics, baselines, and a decision rule.

## Next Minimum Experiment

- Action: Simulate partitions against TTL and acknowledgement baselines.
- Input needed: Synthetic cache workload and partition schedule.
- Output expected: Recovery latency and stale-read violation measurements.
- Decision rule: Continue only if recovery latency improves by at least 20% without increasing stale-read violations.
MD

if "$ROOT/scripts/cr-hook-stop" "$TMP" >/tmp/cr-stop-valid-complete.out 2>&1; then
    grep -q "approve" /tmp/cr-stop-valid-complete.out && pass "stop hook allows valid complete"
else
    cat /tmp/cr-stop-valid-complete.out
    fail "stop hook allows valid complete"
fi

DELETE_INPUT='{"tool_name":"Bash","tool_input":{"command":"rm hooks/runs/run-001/research.md"}}'
if printf '%s' "$DELETE_INPUT" | "$ROOT/scripts/cr-hook-pre-tool-use" | grep -q '"permissionDecision": "deny"'; then
    pass "pre-tool hook blocks research.md deletion"
else
    fail "pre-tool hook blocks research.md deletion"
fi

CROSS_WRITE_INPUT='{"tool_name":"Write","tool_input":{"file_path":"other/notes.md","content":"x"}}'
if printf '%s' "$CROSS_WRITE_INPUT" | "$ROOT/scripts/cr-hook-pre-tool-use" | grep -q '"permissionDecision": "deny"'; then
    pass "pre-tool hook blocks cross-project Write"
else
    fail "pre-tool hook blocks cross-project Write"
fi

STATE_WRITE_INPUT='{"tool_name":"Write","tool_input":{"file_path":"_cr/sessions/bad.yaml","content":"x"}}'
if printf '%s' "$STATE_WRITE_INPUT" | "$ROOT/scripts/cr-hook-pre-tool-use" | grep -q '"permissionDecision": "deny"'; then
    pass "pre-tool hook blocks workspace state Write"
else
    fail "pre-tool hook blocks workspace state Write"
fi

CROSS_BASH_INPUT='{"tool_name":"Bash","tool_input":{"command":"touch other/notes.md"}}'
if printf '%s' "$CROSS_BASH_INPUT" | "$ROOT/scripts/cr-hook-pre-tool-use" | grep -q '"permissionDecision": "deny"'; then
    pass "pre-tool hook blocks cross-project Bash mutation"
else
    fail "pre-tool hook blocks cross-project Bash mutation"
fi

IMMUTABLE_INPUT="$(python3 - <<'PY'
import json
from pathlib import Path

p = Path("hooks/runs/run-001/research.md")
s = p.read_text()
old = "project_id: hooks"
if old not in s:
    old = 'project_id: "hooks"'
print(json.dumps({
    "tool_name": "Edit",
    "tool_input": {
        "file_path": str(p),
        "old_string": old,
        "new_string": old.replace("hooks", "other"),
    },
}))
PY
)"
if printf '%s' "$IMMUTABLE_INPUT" | "$ROOT/scripts/cr-hook-pre-tool-use" | grep -q '"permissionDecision": "deny"'; then
    pass "pre-tool hook blocks immutable frontmatter mutation"
else
    fail "pre-tool hook blocks immutable frontmatter mutation"
fi

echo "RESULT $passes passed, $fails failed"
[ "$fails" -eq 0 ]
