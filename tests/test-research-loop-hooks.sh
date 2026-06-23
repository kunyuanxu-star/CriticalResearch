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
