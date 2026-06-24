#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d /tmp/cr-install-quickstart-XXXXXX)"
trap 'rm -rf "$TMP"' EXIT

passes=0
fails=0
pass() { echo "PASS $1"; passes=$((passes + 1)); }
fail() { echo "FAIL $1"; fails=$((fails + 1)); }
check() { if eval "$1"; then pass "$2"; else fail "$2"; fi; }

NO_YAML_SITE="$TMP/no-yaml-site"
mkdir -p "$NO_YAML_SITE" "$TMP/home" "$TMP/workspace"
cat > "$NO_YAML_SITE/sitecustomize.py" <<'PY'
import builtins

_real_import = builtins.__import__

def _blocked_import(name, globals=None, locals=None, fromlist=(), level=0):
    if name == "yaml" or name.startswith("yaml."):
        raise ImportError("yaml intentionally blocked by test")
    return _real_import(name, globals, locals, fromlist, level)

builtins.__import__ = _blocked_import
PY

HOME="$TMP/home" \
CR_SKILL_HOME="$TMP/skill" \
PYTHONPATH="$NO_YAML_SITE" \
bash "$ROOT/install.sh" --skill-only > "$TMP/install.out"

check 'grep -q "Installation complete" "$TMP/install.out"' "installer completes"
check '! grep -qi "PyYAML" "$TMP/install.out"' "installer does not require PyYAML"
check '[ -x "$TMP/skill/scripts/cr" ]' "installed cr is executable"

cd "$TMP/workspace"
export HOME="$TMP/home"
export CR_SKILL_HOME="$TMP/skill"
export PATH="$TMP/skill/scripts:$PATH"
export PYTHONPATH="$NO_YAML_SITE"

cr workspace init >/dev/null
cr project init edge-cache --domain systems >/dev/null
cr run edge-cache "Can edge cache invalidation survive intermittent connectivity?" --mode quick >/dev/null

check '[ -f _cr/workspace.yaml ]' "workspace metadata created after install"
check '[ -f edge-cache/project.yaml ]' "project metadata created after install"
check '[ -f edge-cache/runs/run-001/research.md ]' "research.md created after install"
check '[ "$(cr status edge-cache --field latest_run)" = "run-001" ]' "installed cr reads latest run"
check '[ "$(cr status edge-cache --field status)" = "draft" ]' "installed cr reads draft status"
check "cr show edge-cache | grep -Eq 'schema_version: \"?3\\.0\\.0\"?'" "installed cr writes current schema"

set +e
cr validate edge-cache >/tmp/cr-install-validate.out
rc=$?
set -e
if [ "$rc" -eq 2 ] && grep -q "INVALID" /tmp/cr-install-validate.out; then
    pass "installed cr validates draft fail-closed"
else
    cat /tmp/cr-install-validate.out
    fail "installed cr validates draft fail-closed"
fi

echo "RESULT $passes passed, $fails failed"
[ "$fails" -eq 0 ]
