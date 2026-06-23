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
check '[ "$(cr status edge-cache --field latest_run)" = "run-001" ]' "latest run field"
check '[ "$(cr status edge-cache --field status)" = "draft" ]' "draft status field"
check 'cr show edge-cache | grep -q "# Research Brief"' "show prints research brief"

cr run edge-cache "Second objective" --mode quick --debug >/dev/null
check '[ -f edge-cache/runs/run-002/research.md ]' "run-002 research.md created"
check '[ -f edge-cache/runs/run-002/trace.jsonl ]' "trace created with debug"
check 'grep -q "mode: quick" edge-cache/runs/run-002/research.md' "quick mode recorded"
check 'grep -q "loop_budget: 1" edge-cache/runs/run-002/research.md' "quick budget recorded"

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
