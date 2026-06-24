#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="$ROOT/scripts:$PATH"
export CR_SKILL_HOME="$ROOT"

TMP="$(mktemp -d /tmp/cr-loop-cli-XXXXXX)"
trap 'rm -rf "$TMP"' EXIT
cd "$TMP"

passes=0
fails=0

pass() { echo "PASS $1"; passes=$((passes + 1)); }
fail() { echo "FAIL $1"; fails=$((fails + 1)); }
check() { if eval "$1"; then pass "$2"; else fail "$2"; fi; }

cr workspace init >/dev/null
cr project init edge-cache --domain systems >/dev/null

check '[ -f _cr/workspace.yaml ]' "workspace metadata created"
check '[ -f edge-cache/project.yaml ]' "project metadata created"
check '[ -d edge-cache/documents ] && [ -d edge-cache/knowledge ] && [ -d edge-cache/runs ]' "light project layout"

cr run edge-cache "Can edge cache invalidation survive intermittent connectivity?" >/dev/null
check '[ -f edge-cache/runs/run-001/research.md ]' "run-001 research.md created"
check '[ ! -f edge-cache/runs/run-001/trace.jsonl ]' "no trace by default"
check '[ "$(find edge-cache/runs/run-001 -type f | wc -l | tr -d " ")" = "1" ]' "default run writes only research.md"
check '[ "$(cr status edge-cache --field latest_run)" = "run-001" ]' "latest run field"
check '[ "$(cr status edge-cache --field status)" = "draft" ]' "draft status field"
check '[ "$(cr status edge-cache --field next_action)" = "Form the initial thesis and define the Basic System." ]' "next action field"
check 'cr status edge-cache | grep -Eq "Validation: [1-9][0-9]* errors"' "status shows live validation errors"
check 'grep -q "mode: standard" edge-cache/runs/run-001/research.md' "default standard mode recorded"
check 'grep -q "loop_budget: 3" edge-cache/runs/run-001/research.md' "standard budget recorded"
check 'grep -Eq "schema_version: ['\''\"]?3\\.0\\.0['\''\"]?" edge-cache/runs/run-001/research.md' "current schema recorded"
check 'cr show edge-cache | grep -q "# Research Brief"' "show prints research brief"

cr run edge-cache "Second objective" --mode quick --debug >/dev/null
check '[ -f edge-cache/runs/run-002/research.md ]' "run-002 research.md created"
check '[ -f edge-cache/runs/run-002/trace.jsonl ]' "trace created with debug"
check '[ "$(find edge-cache/runs/run-002 -type f | wc -l | tr -d " ")" = "2" ]' "debug run writes only research.md and trace"
check 'python3 -m json.tool edge-cache/runs/run-002/trace.jsonl >/dev/null' "debug trace is JSON"
check '! grep -Eiq "chain.?of.?thought|raw.?thought|reasoning_trace" edge-cache/runs/run-002/trace.jsonl' "debug trace omits raw thought"
check 'grep -q "mode: quick" edge-cache/runs/run-002/research.md' "quick mode recorded"
check 'grep -q "loop_budget: 1" edge-cache/runs/run-002/research.md' "quick budget recorded"

cr run edge-cache "Third objective" --mode deep >/dev/null
check '[ -f edge-cache/runs/run-003/research.md ]' "run-003 research.md created"
check 'grep -q "mode: deep" edge-cache/runs/run-003/research.md' "deep mode recorded"
check 'grep -q "loop_budget: 5" edge-cache/runs/run-003/research.md' "deep budget recorded"

cr run edge-cache "Autonomous objective" --mode deep --autonomous >/dev/null
check '[ -f edge-cache/runs/run-004/research.md ]' "autonomous research.md created"
check '[ -d edge-cache/runs/run-004/state ] && [ -d edge-cache/runs/run-004/logs ]' "autonomous state and logs directories created"
check '[ -f edge-cache/runs/run-004/state/task_spec.md ]' "autonomous task spec created"
check '[ -f edge-cache/runs/run-004/state/progress.json ]' "autonomous progress created"
check '[ -f edge-cache/runs/run-004/state/findings.jsonl ]' "autonomous findings log created"
check '[ -f edge-cache/runs/run-004/state/directions_tried.json ]' "autonomous directions file created"
check '[ -f edge-cache/runs/run-004/state/iteration_log.jsonl ]' "autonomous iteration log created"
check '[ -f edge-cache/runs/run-004/logs/work.jsonl ] && [ -f edge-cache/runs/run-004/logs/orchestrator.jsonl ] && [ -f edge-cache/runs/run-004/logs/heartbeat.jsonl ]' "autonomous log files created"
check 'grep -q "autonomous: true" edge-cache/runs/run-004/research.md' "autonomous frontmatter recorded"
check 'grep -Eq "state_ref: ['\''\"]?state/progress\\.json['\''\"]?" edge-cache/runs/run-004/research.md' "autonomous state ref recorded"
check 'python3 -m json.tool edge-cache/runs/run-004/state/progress.json >/dev/null' "autonomous progress is JSON"
check 'cr progress edge-cache --run run-004 | grep -q "Stale count: 0"' "progress prints stale count"
check 'cr progress edge-cache --run run-004 --json | python3 -m json.tool >/dev/null' "progress json output"

for old_cmd in round stage document unit workflow; do
    if cr "$old_cmd" edge-cache 2>"/tmp/cr-loop-$old_cmd.err"; then
        fail "$old_cmd unsupported"
    elif grep -q "unsupported in CriticalResearch" "/tmp/cr-loop-$old_cmd.err" &&
        grep -q 'cr run <project> "objective"' "/tmp/cr-loop-$old_cmd.err" &&
        grep -q "not workflow/stage/round state" "/tmp/cr-loop-$old_cmd.err"; then
        pass "$old_cmd unsupported"
    else
        cat "/tmp/cr-loop-$old_cmd.err"
        fail "$old_cmd unsupported"
    fi
done

echo "RESULT $passes passed, $fails failed"
[ "$fails" -eq 0 ]
