#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="$ROOT/scripts:$PATH"
export CR_SKILL_HOME="$ROOT"

TMP="$(mktemp -d /tmp/cr-schema-contract-XXXXXX)"
trap 'rm -rf "$TMP"' EXIT
cd "$TMP"

passes=0
fails=0
pass() { echo "PASS $1"; passes=$((passes + 1)); }
fail() { echo "FAIL $1"; fails=$((fails + 1)); }

cr workspace init >/dev/null
cr project init schema-check --domain systems >/dev/null
cr run schema-check "Schema contract objective" --mode deep >/dev/null
cr run schema-check "Autonomous schema objective" --mode deep --autonomous >/dev/null

if ROOT="$ROOT" python3 - <<'PY'
import importlib.util
import json
import os
import sys
from pathlib import Path

root = Path(os.environ["ROOT"])
schema = json.loads((root / "schemas/research-frontmatter.schema.json").read_text())
progress_schema = json.loads((root / "schemas/autonomous-progress.schema.json").read_text())
spec = importlib.util.spec_from_file_location("cr_cli", root / "engine/research_loop/cli.py")
cli = importlib.util.module_from_spec(spec)
assert spec.loader is not None
sys.modules["cr_cli"] = cli
spec.loader.exec_module(cli)

required = set(schema["required"])
expected_required = {
    "schema_version",
    "project_id",
    "run_id",
    "status",
    "phase",
    "objective",
    "mode",
    "loop_count",
    "loop_budget",
    "weakest_link",
    "next_action",
    "autonomous",
    "state_ref",
    "validation",
    "convergence",
    "gate",
    "debug_trace",
    "created_at",
    "updated_at",
}
assert required == expected_required, sorted(required ^ expected_required)
assert schema["properties"]["schema_version"]["const"] == cli.SCHEMA_VERSION
assert set(schema["properties"]["status"]["enum"]) == set(cli.VALID_STATUSES)
assert set(schema["properties"]["phase"]["enum"]) == set(cli.VALID_PHASES)
assert set(schema["properties"]["mode"]["enum"]) == set(cli.VALID_MODES)
assert set(schema["properties"]["weakest_link"]["enum"]) == set(cli.VALID_WEAKEST_LINKS)
assert set(schema["properties"]["gate"]["properties"]["type"]["enum"]) == set(cli.VALID_GATES)

text = Path("schema-check/runs/run-001/research.md").read_text()
frontmatter, _ = cli.parse_frontmatter(text)
assert required <= set(frontmatter), sorted(required - set(frontmatter))

for key in ("validation", "convergence", "gate"):
    subschema = schema["properties"][key]
    assert set(subschema["required"]) <= set(frontmatter[key]), key

assert frontmatter["schema_version"] == cli.SCHEMA_VERSION
assert frontmatter["autonomous"] is False
assert frontmatter["state_ref"] is None
assert frontmatter["mode"] == "deep"
assert frontmatter["loop_budget"] == cli.VALID_MODES["deep"]

progress_required = set(progress_schema["required"])
expected_progress_required = {
    "schema_version",
    "run_id",
    "iteration",
    "status",
    "last_seen",
    "stale_count",
    "total_findings",
    "validation_error_count",
    "warning_count",
    "blocking_attack_count",
    "weakest_link",
    "current_direction_id",
    "terminal_reason",
}
assert progress_required == expected_progress_required, sorted(progress_required ^ expected_progress_required)
assert progress_schema["properties"]["schema_version"]["const"] == cli.SCHEMA_VERSION
assert set(progress_schema["properties"]["status"]["enum"]) == set(cli.VALID_STATUSES)
assert set(progress_schema["properties"]["weakest_link"]["enum"]) == set(cli.VALID_WEAKEST_LINKS)

progress = json.loads(Path("schema-check/runs/run-002/state/progress.json").read_text())
assert progress_required <= set(progress), sorted(progress_required - set(progress))
assert progress["schema_version"] == cli.SCHEMA_VERSION
assert progress["run_id"] == "run-002"
assert progress["status"] == "draft"
assert progress["weakest_link"] == "basic_system"
PY
then
    pass "frontmatter schema matches CLI constants and generated run"
else
    fail "frontmatter schema matches CLI constants and generated run"
fi

echo "RESULT $passes passed, $fails failed"
[ "$fails" -eq 0 ]
