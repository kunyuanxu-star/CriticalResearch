#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

passes=0
fails=0
pass() { echo "PASS $1"; passes=$((passes + 1)); }
fail() { echo "FAIL $1"; fails=$((fails + 1)); }
check() { if eval "$1"; then pass "$2"; else fail "$2"; fi; }

for command_file in "$ROOT/commands/critical-research.md" "$ROOT/.claude/commands/critical-research.md"; do
    check "grep -q '^## Execution Contract$' '$command_file'" "$(basename "$(dirname "$command_file")") command has execution contract"
    check "grep -q '^### Required Inputs$' '$command_file'" "$(basename "$(dirname "$command_file")") command has required inputs"
    check "grep -q '^### Allowed Writes$' '$command_file'" "$(basename "$(dirname "$command_file")") command has allowed writes"
    check "grep -q '^### Required Outputs$' '$command_file'" "$(basename "$(dirname "$command_file")") command has required outputs"
    check "grep -q '^### Quality Gates$' '$command_file'" "$(basename "$(dirname "$command_file")") command has quality gates"
    check "grep -q '^### Traceability$' '$command_file'" "$(basename "$(dirname "$command_file")") command has traceability"
    check "grep -q 'cr validate' '$command_file'" "$(basename "$(dirname "$command_file")") command validates before stop"
    check "grep -q 'trace.jsonl.*--debug' '$command_file'" "$(basename "$(dirname "$command_file")") command gates trace debug"
done

check "grep -q '^## Execution Contract$' '$ROOT/SKILL.md'" "skill has execution contract"
check "grep -q 'Allowed writes:' '$ROOT/SKILL.md'" "skill has allowed writes"
check "grep -q 'Quality gates:' '$ROOT/SKILL.md'" "skill has quality gates"
check "grep -q 'Traceability:' '$ROOT/SKILL.md'" "skill has traceability"

echo "RESULT $passes passed, $fails failed"
[ "$fails" -eq 0 ]
