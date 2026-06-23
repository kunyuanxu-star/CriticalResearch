#!/usr/bin/env python3
"""CriticalResearch thesis-centered research loop CLI."""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

try:
    import yaml as _pyyaml
except Exception:
    _pyyaml = None


VALID_STATUSES = {
    "draft",
    "forming",
    "reviewing",
    "repairing",
    "complete",
    "blocked",
    "gated",
    "budget_exhausted",
    "invalid",
}
TERMINAL_STATUSES = {"complete", "blocked", "gated", "budget_exhausted", "invalid"}
VALID_PHASES = {"init", "formation", "review", "repair", "final"}
VALID_MODES = {"quick": 1, "standard": 3, "deep": 5}
VALID_WEAKEST_LINKS = {
    "basic_system",
    "contradiction",
    "strawman",
    "root_cause",
    "insight",
    "design",
    "proof_plan",
    "evidence",
    "writing",
    "scope",
}
VALID_GATES = {
    "none",
    "user_input",
    "external_evidence",
    "data_access",
    "compute",
    "literature",
    "implementation",
}
SCHEMA_VERSION = "1.0.0"

REQUIRED_HEADINGS = [
    "# Research Brief",
    "## Thesis",
    "## Basic System",
    "## Core Contradiction",
    "## Strawmen and Root Cause",
    "## Key Insight",
    "## Design Direction",
    "## Minimal Proof Plan",
    "## Reviewer Attacks",
    "## Evidence Boundary",
    "## Weakest Link",
    "## Next Minimum Experiment",
]


@dataclass
class Finding:
    code: str
    field: str
    message: str


@dataclass
class ValidationResult:
    errors: list[Finding] = field(default_factory=list)
    warnings: list[Finding] = field(default_factory=list)
    allowed_terminal_gaps: bool = False

    @property
    def exit_code(self) -> int:
        if self.errors and not self.allowed_terminal_gaps:
            return 2
        if self.errors or self.warnings:
            return 1
        return 0

    @property
    def status_text(self) -> str:
        if self.errors and not self.allowed_terminal_gaps:
            return "INVALID"
        if self.errors or self.warnings:
            return "VALID WITH WARNINGS"
        return "VALID"


def now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def atomic_write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(f".{path.name}.tmp")
    tmp.write_text(text, encoding="utf-8")
    tmp.replace(path)


def parse_scalar(value: str) -> Any:
    value = value.strip()
    if value in {"", "null", "Null", "NULL", "~"}:
        return None
    if value in {"[]", "{}"}:
        return [] if value == "[]" else {}
    if value in {"true", "True", "TRUE"}:
        return True
    if value in {"false", "False", "FALSE"}:
        return False
    if (value.startswith('"') and value.endswith('"')) or (value.startswith("'") and value.endswith("'")):
        if value.startswith('"'):
            try:
                return json.loads(value)
            except json.JSONDecodeError:
                return value[1:-1]
        return value[1:-1].replace("''", "'")
    if re.fullmatch(r"-?\d+", value):
        try:
            return int(value)
        except ValueError:
            pass
    return value


def parse_restricted_yaml(text: str) -> dict[str, Any]:
    lines = [
        (len(line) - len(line.lstrip(" ")), line.strip())
        for line in text.splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    ]
    root: dict[str, Any] = {}
    stack: list[tuple[int, Any]] = [(-1, root)]

    for idx, (indent, stripped) in enumerate(lines):
        while stack and indent <= stack[-1][0]:
            stack.pop()
        parent = stack[-1][1]

        if stripped.startswith("- "):
            if not isinstance(parent, list):
                raise ValueError("list item without list parent")
            parent.append(parse_scalar(stripped[2:]))
            continue

        if ":" not in stripped:
            raise ValueError(f"invalid YAML line: {stripped}")
        key, raw_value = stripped.split(":", 1)
        key = key.strip()
        raw_value = raw_value.strip()
        if not isinstance(parent, dict):
            raise ValueError("mapping entry without mapping parent")

        if raw_value:
            parent[key] = parse_scalar(raw_value)
            continue

        next_is_list = False
        for next_indent, next_stripped in lines[idx + 1 :]:
            if next_indent <= indent:
                break
            next_is_list = next_stripped.startswith("- ")
            break
        container: Any = [] if next_is_list else {}
        parent[key] = container
        stack.append((indent, container))

    return root


def dump_scalar(value: Any) -> str:
    if value is None:
        return "null"
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, int):
        return str(value)
    text = str(value)
    if text and re.fullmatch(r"[A-Za-z0-9_./@+-]+", text) and text not in {"null", "true", "false"}:
        return text
    return json.dumps(text, ensure_ascii=False)


def dump_restricted_yaml(data: dict[str, Any], indent: int = 0) -> str:
    lines: list[str] = []
    prefix = " " * indent
    for key, value in data.items():
        if isinstance(value, dict):
            if value:
                lines.append(f"{prefix}{key}:")
                lines.append(dump_restricted_yaml(value, indent + 2))
            else:
                lines.append(f"{prefix}{key}: {{}}")
        elif isinstance(value, list):
            if value:
                lines.append(f"{prefix}{key}:")
                for item in value:
                    lines.append(f"{' ' * (indent + 2)}- {dump_scalar(item)}")
            else:
                lines.append(f"{prefix}{key}: []")
        else:
            lines.append(f"{prefix}{key}: {dump_scalar(value)}")
    return "\n".join(lines)


def yaml_load(text: str) -> dict[str, Any]:
    if _pyyaml is not None:
        data = _pyyaml.safe_load(text)
    else:
        data = parse_restricted_yaml(text)
    return data if isinstance(data, dict) else {}


def yaml_dump(data: dict[str, Any]) -> str:
    if _pyyaml is not None:
        return _pyyaml.safe_dump(data, sort_keys=False, allow_unicode=True)
    return dump_restricted_yaml(data) + "\n"


def read_yaml(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    return yaml_load(path.read_text(encoding="utf-8"))


def write_yaml(path: Path, data: dict[str, Any]) -> None:
    atomic_write(path, yaml_dump(data))


def workspace_root() -> Path:
    env_root = os.environ.get("CR_WORKSPACE_ROOT")
    if env_root:
        return Path(env_root).expanduser().resolve()

    cur = Path.cwd().resolve()
    for candidate in [cur, *cur.parents]:
        if (candidate / "_cr" / "workspace.yaml").exists():
            return candidate

    try:
        out = subprocess.check_output(["git", "rev-parse", "--show-toplevel"], stderr=subprocess.DEVNULL)
        return Path(out.decode().strip()).resolve()
    except Exception:
        return cur


def sanitize_project_id(raw: str) -> str:
    value = raw.strip().lower().replace("_", "-").replace(" ", "-")
    value = re.sub(r"[^a-z0-9-]", "", value)
    value = re.sub(r"-+", "-", value).strip("-")
    if not value or not re.match(r"^[a-z0-9][a-z0-9-]*$", value):
        raise SystemExit(f"Error: invalid project id '{raw}'")
    return value


def project_dir(project: str) -> Path:
    return workspace_root() / project


def require_workspace() -> Path:
    root = workspace_root()
    if not (root / "_cr" / "workspace.yaml").exists():
        raise SystemExit("Error: workspace not initialized. Run: cr workspace init")
    return root


def require_project(project: str) -> Path:
    root = require_workspace()
    path = root / project
    if not (path / "project.yaml").exists():
        raise SystemExit(f"Error: project '{project}' not found at {path}")
    return path


def update_workspace_project(root: Path, project: str) -> None:
    workspace_file = root / "_cr" / "workspace.yaml"
    data = read_yaml(workspace_file)
    projects = data.get("projects") or []
    if project not in projects:
        projects.append(project)
    data.update({"schema_version": SCHEMA_VERSION, "projects": projects})
    data.setdefault("created_at", now_iso())
    data["updated_at"] = now_iso()
    write_yaml(workspace_file, data)


def latest_run_id(proj: Path) -> str | None:
    data = read_yaml(proj / "project.yaml")
    latest = data.get("latest_run")
    return latest if isinstance(latest, str) and latest else None


def next_run_id(proj: Path) -> str:
    runs = proj / "runs"
    runs.mkdir(parents=True, exist_ok=True)
    nums: list[int] = []
    for child in runs.iterdir():
        if child.is_dir():
            match = re.match(r"run-(\d{3})$", child.name)
            if match:
                nums.append(int(match.group(1)))
    return f"run-{(max(nums) + 1) if nums else 1:03d}"


def research_path(proj: Path, run_id: str) -> Path:
    return proj / "runs" / run_id / "research.md"


def parse_frontmatter(text: str) -> tuple[dict[str, Any], str]:
    if not text.startswith("---\n"):
        raise ValueError("missing YAML frontmatter")
    end = text.find("\n---\n", 4)
    if end == -1:
        raise ValueError("unterminated YAML frontmatter")
    raw = text[4:end]
    body = text[end + 5 :]
    data = yaml_load(raw)
    if not data:
        raise ValueError("frontmatter is not a mapping")
    return data, body


def render_research_template(project: str, run_id: str, objective: str, mode: str, debug: bool) -> str:
    budget = VALID_MODES[mode]
    fm = {
        "schema_version": SCHEMA_VERSION,
        "project_id": project,
        "run_id": run_id,
        "status": "draft",
        "phase": "init",
        "objective": objective,
        "mode": mode,
        "loop_count": 0,
        "loop_budget": budget,
        "weakest_link": "basic_system",
        "next_action": "Form the initial thesis and define the Basic System.",
        "validation": {"error_count": 0, "warning_count": 0, "blocking_attack_count": 0},
        "convergence": {
            "stall_count": 0,
            "repeated_attack_count": 0,
            "scope_challenge_count": 0,
            "progress_signal": "",
        },
        "gate": {"type": "none", "description": ""},
        "debug_trace": bool(debug),
        "created_at": now_iso(),
        "updated_at": now_iso(),
    }
    frontmatter = yaml_dump(fm).strip()
    body = f"""# Research Brief

## Thesis

One-sentence claim:

Expanded thesis:

## Basic System

- Setting:
- Object:
- Goal:
- Constraints:
- Success condition:

## Core Contradiction

- Need:
- But:
- Therefore the tension is:

## Strawmen and Root Cause

### Strawman 1
- Approach:
- Why it seems plausible:
- Concrete failure mode:

### Strawman 2
- Approach:
- Why it seems plausible:
- Concrete failure mode:

### Shared Root Cause
- Common failure:
- Deeper cause:

## Key Insight

- Insight:
- Why this addresses the root cause:
- What becomes possible:

## Design Direction

- Principle:
- Mechanism:
- Non-goals:

## Minimal Proof Plan

- Claim to test:
- Metric:
- Baseline:
- Minimum experiment:
- Expected evidence:
- Failure signal:
- Decision rule:

## Reviewer Attacks

### Attack A1
- Role:
- Field:
- Type:
- Severity:
- Scope:
- Argument:
- Required repair:
- Disposition:

### Attack A2
- Role:
- Field:
- Type:
- Severity:
- Scope:
- Argument:
- Required repair:
- Disposition:

## Evidence Boundary

- Known:
- Assumed:
- Unknown:
- Thesis-breaking unknown:
- Out of scope:

## Weakest Link

- Current weakest link:
- Why it is weakest:
- What changed in this loop:

## Next Minimum Experiment

- Action:
- Input needed:
- Output expected:
- Decision rule:
"""
    return f"---\n{frontmatter}\n---\n\n{body}"


def sections(body: str) -> dict[str, str]:
    result: dict[str, str] = {}
    matches = list(re.finditer(r"^(#{1,2})\s+(.+?)\s*$", body, flags=re.MULTILINE))
    for idx, match in enumerate(matches):
        heading = f"{match.group(1)} {match.group(2)}"
        start = match.end()
        end = matches[idx + 1].start() if idx + 1 < len(matches) else len(body)
        result[heading] = body[start:end]
    return result


def label_value(section: str, label: str) -> str:
    pattern = re.compile(rf"^[ \t]*(?:[-*][ \t]*)?{re.escape(label)}:[ \t]*(.*)$", re.MULTILINE)
    match = pattern.search(section)
    if not match:
        return ""
    value = match.group(1).strip()
    return value if value and value not in {"...", "TODO", "TBD", "null"} else ""


def has_label(section: str, label: str) -> bool:
    return bool(label_value(section, label))


def validate_research(path: Path, strict: bool = False) -> tuple[ValidationResult, dict[str, Any]]:
    result = ValidationResult()
    fm: dict[str, Any] = {}

    if not path.exists():
        result.errors.append(Finding("E000", "file", f"research.md not found: {path}"))
        return result, fm

    try:
        fm, body = parse_frontmatter(path.read_text(encoding="utf-8"))
    except Exception as exc:
        result.errors.append(Finding("E001", "frontmatter", str(exc)))
        return result, fm

    run_id = path.parent.name
    if fm.get("schema_version") != SCHEMA_VERSION:
        result.errors.append(Finding("E002", "frontmatter", f"schema_version must be {SCHEMA_VERSION}"))
    if fm.get("run_id") != run_id:
        result.errors.append(Finding("E003", "frontmatter", f"run_id must match directory '{run_id}'"))
    if fm.get("status") not in VALID_STATUSES:
        result.errors.append(Finding("E004", "frontmatter", "invalid status"))
    if fm.get("phase") not in VALID_PHASES:
        result.errors.append(Finding("E005", "frontmatter", "invalid phase"))
    if fm.get("mode") not in VALID_MODES:
        result.errors.append(Finding("E006", "frontmatter", "invalid mode"))
    if fm.get("weakest_link") not in VALID_WEAKEST_LINKS:
        result.errors.append(Finding("E007", "frontmatter", "invalid weakest_link"))
    if not str(fm.get("objective") or "").strip():
        result.errors.append(Finding("E008", "frontmatter", "objective is empty"))

    sec = sections(body)
    for heading in REQUIRED_HEADINGS:
        if heading not in sec:
            result.errors.append(Finding("E100", "section", f"missing required heading: {heading}"))

    thesis = sec.get("## Thesis", "")
    basic = sec.get("## Basic System", "")
    contradiction = sec.get("## Core Contradiction", "")
    straw = sec.get("## Strawmen and Root Cause", "")
    insight = sec.get("## Key Insight", "")
    proof = sec.get("## Minimal Proof Plan", "")
    evidence = sec.get("## Evidence Boundary", "")
    next_exp = sec.get("## Next Minimum Experiment", "")

    if thesis and not has_label(thesis, "One-sentence claim"):
        result.errors.append(Finding("E110", "Thesis", "missing one-sentence claim"))
    for label in ("Setting", "Object", "Goal"):
        if basic and not has_label(basic, label):
            result.errors.append(Finding("E120", "Basic System", f"missing {label}"))
    for label in ("Need", "But", "Therefore the tension is"):
        if contradiction and not has_label(contradiction, label):
            result.errors.append(Finding("E130", "Core Contradiction", f"missing {label}"))

    strawman_matches = list(re.finditer(r"^### Strawman\s+\d+", straw, flags=re.MULTILINE))
    if straw and len(strawman_matches) < 2:
        result.errors.append(Finding("E140", "Strawmen", "fewer than two strawmen"))
    for idx, match in enumerate(strawman_matches):
        start = match.end()
        end = strawman_matches[idx + 1].start() if idx + 1 < len(strawman_matches) else straw.find("### Shared Root Cause")
        if end == -1:
            end = len(straw)
        block = straw[start:end]
        if not has_label(block, "Concrete failure mode"):
            result.errors.append(Finding("E141", "Strawmen", f"{match.group(0)} missing concrete failure mode"))
    shared_root = straw.split("### Shared Root Cause", 1)[1] if "### Shared Root Cause" in straw else ""
    if straw and not shared_root:
        result.errors.append(Finding("E150", "Root Cause", "missing Shared Root Cause"))
    elif shared_root:
        if not has_label(shared_root, "Common failure"):
            result.errors.append(Finding("E150", "Root Cause", "missing Common failure"))
        if not has_label(shared_root, "Deeper cause"):
            result.errors.append(Finding("E151", "Root Cause", "missing Deeper cause"))

    if insight and not has_label(insight, "Insight"):
        result.errors.append(Finding("E160", "Key Insight", "missing Insight"))
    for label in ("Metric", "Baseline", "Minimum experiment", "Decision rule"):
        if proof and not has_label(proof, label):
            result.errors.append(Finding("E170", "Minimal Proof Plan", f"missing {label}"))
    for label in ("Known", "Assumed", "Unknown"):
        if evidence and not has_label(evidence, label):
            result.errors.append(Finding("E180", "Evidence Boundary", f"missing {label}"))
    for label in ("Action", "Decision rule"):
        if next_exp and not has_label(next_exp, label):
            result.errors.append(Finding("E190", "Next Minimum Experiment", f"missing {label}"))

    need = label_value(contradiction, "Need")
    if need and re.search(r"\b(faster|better|cheaper|efficient|support|optimi[sz]e|improve)\b", need, re.I):
        result.warnings.append(Finding("W030", "Core Contradiction", "contradiction may be feature-demand shaped"))
    common = label_value(shared_root, "Common failure")
    deeper = label_value(shared_root, "Deeper cause")
    if common and deeper and common.lower() == deeper.lower():
        result.warnings.append(Finding("W050", "Root Cause", "root cause appears to restate the failure"))
    insight_value = label_value(insight, "Insight")
    if insight_value and re.match(r"^(use|using|we use|apply|build)\b", insight_value, re.I):
        result.warnings.append(Finding("W060", "Key Insight", "insight may be solution-shaped"))
    if evidence and not has_label(evidence, "Thesis-breaking unknown"):
        result.warnings.append(Finding("W080", "Evidence Boundary", "missing thesis-breaking unknown"))
    next_action = str(fm.get("next_action") or "").strip()
    if next_action and re.fullmatch(r"(continue|improve|research more|explore|keep working)\.?", next_action, re.I):
        result.warnings.append(Finding("W100", "Next Action", "next_action is too broad"))

    status = fm.get("status")
    gate = fm.get("gate") if isinstance(fm.get("gate"), dict) else {}
    loop_count = int(fm.get("loop_count") or 0)
    loop_budget = int(fm.get("loop_budget") or VALID_MODES.get(fm.get("mode"), 0))

    if status in TERMINAL_STATUSES and status != "invalid" and not next_action:
        result.errors.append(Finding("E008", "frontmatter", "terminal status requires next_action"))
    if status == "blocked":
        if re.search(r"\b(user|decision|input|scope|clarif|choose|provide)\b", next_action, re.I):
            result.allowed_terminal_gaps = bool(result.errors)
    elif status == "gated":
        if gate.get("type") in VALID_GATES - {"none"} and next_action:
            result.allowed_terminal_gaps = bool(result.errors)
        else:
            result.errors.append(Finding("E009", "gate", "gated status requires non-none gate.type and next_action"))
    elif status == "budget_exhausted":
        if loop_count >= loop_budget and next_action:
            result.allowed_terminal_gaps = bool(result.errors)
        else:
            result.errors.append(Finding("E010", "convergence", "budget_exhausted requires loop_count >= loop_budget and next_action"))

    if strict and result.warnings:
        result.errors.extend(Finding(w.code.replace("W", "E", 1), w.field, w.message) for w in result.warnings)
        result.warnings.clear()

    return result, fm


def print_validation(result: ValidationResult, json_output: bool = False) -> None:
    if json_output:
        payload = {
            "status": result.status_text.lower().replace(" ", "_"),
            "errors": [finding.__dict__ for finding in result.errors],
            "warnings": [finding.__dict__ for finding in result.warnings],
            "allowed_terminal_gaps": result.allowed_terminal_gaps,
        }
        print(json.dumps(payload, ensure_ascii=False, indent=2))
        return
    print(result.status_text)
    if result.errors:
        print("\nErrors:")
        for finding in result.errors:
            print(f"  {finding.code} [{finding.field}] {finding.message}")
    if result.warnings:
        print("\nWarnings:")
        for finding in result.warnings:
            print(f"  {finding.code} [{finding.field}] {finding.message}")


def resolve_run(proj: Path, run: str | None) -> str:
    if run:
        return run
    latest = latest_run_id(proj)
    if not latest:
        raise SystemExit("Error: project has no runs. Run: cr run <project> \"objective\"")
    return latest


def cmd_workspace(args: argparse.Namespace) -> int:
    root = workspace_root()
    (root / "_cr" / "sessions").mkdir(parents=True, exist_ok=True)
    workspace_file = root / "_cr" / "workspace.yaml"
    data = read_yaml(workspace_file)
    data.setdefault("created_at", now_iso())
    data["schema_version"] = SCHEMA_VERSION
    data.setdefault("projects", [])
    data["updated_at"] = now_iso()
    write_yaml(workspace_file, data)
    print(f"Workspace initialized at {root}")
    return 0


def cmd_project(args: argparse.Namespace) -> int:
    root = require_workspace()
    project = sanitize_project_id(args.id)
    proj = root / project
    if (proj / "project.yaml").exists():
        raise SystemExit(f"Error: project '{project}' already exists")
    now = now_iso()
    (proj / "documents").mkdir(parents=True, exist_ok=True)
    (proj / "knowledge").mkdir(parents=True, exist_ok=True)
    (proj / "runs").mkdir(parents=True, exist_ok=True)
    write_yaml(
        proj / "project.yaml",
        {
            "schema_version": SCHEMA_VERSION,
            "project_id": project,
            "domain": args.domain,
            "created_at": now,
            "updated_at": now,
            "latest_run": None,
            "status": "active",
            "defaults": {
                "mode": "standard",
                "language": "auto",
                "evidence_policy": "brief",
            },
            "constraints": {
                "default_loop_budget": {"quick": 1, "standard": 3, "deep": 5}
            },
        },
    )
    update_workspace_project(root, project)
    atomic_write(root / "_cr" / "active-project", f"{project}\n")
    print(f"Project '{project}' created at {proj}")
    return 0


def cmd_run(args: argparse.Namespace) -> int:
    proj = require_project(args.project)
    mode = args.mode
    run_id = next_run_id(proj)
    path = research_path(proj, run_id)
    atomic_write(path, render_research_template(args.project, run_id, args.objective, mode, args.debug))

    if args.debug:
        atomic_write(
            path.parent / "trace.jsonl",
            json.dumps(
                {
                    "type": "run_created",
                    "run_id": run_id,
                    "mode": mode,
                    "weakest_link": "basic_system",
                    "created_at": now_iso(),
                },
                ensure_ascii=False,
            )
            + "\n",
        )

    project_yaml = read_yaml(proj / "project.yaml")
    project_yaml["latest_run"] = run_id
    project_yaml["updated_at"] = now_iso()
    write_yaml(proj / "project.yaml", project_yaml)

    print(f"Run created: {path}")
    print("Status: draft")
    print("Next: use /critical-research or edit research.md, then run cr validate")
    return 0


def cmd_status(args: argparse.Namespace) -> int:
    proj = require_project(args.project)
    project_yaml = read_yaml(proj / "project.yaml")
    run_id = resolve_run(proj, args.run)
    path = research_path(proj, run_id)
    fm: dict[str, Any] = {}
    if path.exists():
        try:
            fm, _ = parse_frontmatter(path.read_text(encoding="utf-8"))
        except Exception:
            fm = {"status": "invalid", "weakest_link": "basic_system", "next_action": "Repair research.md frontmatter."}

    fields = {
        "latest_run": run_id,
        "status": fm.get("status", "missing"),
        "weakest_link": fm.get("weakest_link", ""),
    }
    if args.field:
        print(fields.get(args.field, ""))
        return 0

    print(f"Project: {project_yaml.get('project_id', args.project)}")
    print(f"Domain: {project_yaml.get('domain', '')}")
    print(f"Latest run: {run_id}")
    print(f"Status: {fields['status']}")
    print(f"Mode: {fm.get('mode', '')}")
    print(f"Loops: {fm.get('loop_count', 0)}/{fm.get('loop_budget', 0)}")
    print(f"Weakest link: {fields['weakest_link']}")
    print(f"Next action: {fm.get('next_action', '')}")
    validation_result, _ = validate_research(path)
    print(f"Validation: {len(validation_result.errors)} errors, {len(validation_result.warnings)} warnings")
    return 0


def cmd_show(args: argparse.Namespace) -> int:
    proj = require_project(args.project)
    run_id = resolve_run(proj, args.run)
    path = research_path(proj, run_id)
    if not path.exists():
        raise SystemExit(f"Error: research.md not found for {run_id}")
    print(path.read_text(encoding="utf-8"), end="")
    return 0


def cmd_validate(args: argparse.Namespace) -> int:
    proj = require_project(args.project)
    run_id = resolve_run(proj, args.run)
    result, _ = validate_research(research_path(proj, run_id), strict=args.strict)
    print_validation(result, args.json)
    return result.exit_code


def cmd_audit(args: argparse.Namespace) -> int:
    require_project(args.project)
    print("cr audit is reserved for a reviewer gate. Use cr validate for current checks.")
    return 2


def unsupported(command: str) -> int:
    print(f"ERROR: 'cr {command}' is unsupported in CriticalResearch.\n", file=sys.stderr)
    print("Replacement:", file=sys.stderr)
    print('  cr run <project> "objective"', file=sys.stderr)
    print("  cr status <project>", file=sys.stderr)
    print("  cr validate <project>", file=sys.stderr)
    print("\nReason: CriticalResearch uses a thesis-centered research loop over research.md, not workflow/stage/round state.", file=sys.stderr)
    return 2


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="cr", description="CriticalResearch CLI")
    sub = parser.add_subparsers(dest="command")

    ws = sub.add_parser("workspace", help="Workspace commands")
    ws_sub = ws.add_subparsers(dest="workspace_command")
    ws_init = ws_sub.add_parser("init", help="Initialize workspace")
    ws_init.set_defaults(func=cmd_workspace)

    project = sub.add_parser("project", help="Project commands")
    project_sub = project.add_subparsers(dest="project_command")
    project_init = project_sub.add_parser("init", help="Create a project")
    project_init.add_argument("id")
    project_init.add_argument("--domain", required=True)
    project_init.set_defaults(func=cmd_project)

    run = sub.add_parser("run", help="Create a thesis-centered run")
    run.add_argument("project")
    run.add_argument("objective", nargs="+")
    run.add_argument("--mode", choices=sorted(VALID_MODES), default="standard")
    run.add_argument("--debug", action="store_true")
    run.set_defaults(func=lambda args: cmd_run(argparse.Namespace(**{**vars(args), "objective": " ".join(args.objective)})))

    status = sub.add_parser("status", help="Show project/run status")
    status.add_argument("project")
    status.add_argument("--run")
    status.add_argument("--field", choices=["status", "latest_run", "weakest_link"])
    status.set_defaults(func=cmd_status)

    show = sub.add_parser("show", help="Print research.md")
    show.add_argument("project")
    show.add_argument("--run")
    show.set_defaults(func=cmd_show)

    validate = sub.add_parser("validate", help="Validate research.md")
    validate.add_argument("project")
    validate.add_argument("--run")
    validate.add_argument("--json", action="store_true")
    validate.add_argument("--strict", action="store_true")
    validate.set_defaults(func=cmd_validate)

    audit = sub.add_parser("audit", help="Reserved reviewer gate")
    audit.add_argument("project")
    audit.add_argument("--run")
    audit.set_defaults(func=cmd_audit)

    return parser


def main(argv: list[str] | None = None) -> int:
    argv = list(sys.argv[1:] if argv is None else argv)
    if argv and argv[0] in {"round", "stage", "document", "unit", "workflow"}:
        return unsupported(argv[0])
    parser = build_parser()
    args = parser.parse_args(argv)
    if not hasattr(args, "func"):
        parser.print_help()
        return 2
    if getattr(args, "command", None) == "workspace" and getattr(args, "workspace_command", None) != "init":
        print("Usage: cr workspace init", file=sys.stderr)
        return 2
    if getattr(args, "command", None) == "project" and getattr(args, "project_command", None) != "init":
        print("Usage: cr project init <id> --domain <domain>", file=sys.stderr)
        return 2
    return int(args.func(args))


if __name__ == "__main__":
    sys.exit(main())
