#!/usr/bin/env bash
# cr-common.sh — Shared validation framework for CriticalResearch scripts.
# Source this file in other cr-* scripts to get error formatting, path
# resolution, and schema validation helpers.
#
# Usage: source "$(dirname "$0")/cr-common.sh"

set -euo pipefail

# ── Colour and output helpers ─────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; CR_ERRORS=$((CR_ERRORS + 1)); }
warn() { echo -e "  ${YELLOW}[WARN]${NC} $1"; CR_WARNINGS=$((CR_WARNINGS + 1)); }

# ── Global error counters ────────────────────────────────────────

CR_ERRORS=0
CR_WARNINGS=0

# ── Path resolution ──────────────────────────────────────────────

# Resolve the workspace root.
# Priority: CR_WORKSPACE_ROOT env var > git root > current directory.
cr_workspace_root() {
    if [ -n "${CR_WORKSPACE_ROOT:-}" ]; then
        echo "$CR_WORKSPACE_ROOT"
    elif git rev-parse --show-toplevel >/dev/null 2>&1; then
        git rev-parse --show-toplevel
    else
        pwd
    fi
}

# Resolve the skill install directory.
# Priority: CR_SKILL_HOME env var > parent of this script's directory.
cr_skill_home() {
    if [ -n "${CR_SKILL_HOME:-}" ]; then
        echo "$CR_SKILL_HOME"
    else
        cd "$(dirname "$0")/.." && pwd
    fi
}

# Normalize a path: resolve symlinks and collapse relative segments.
cr_realpath() {
    local target="${1:-}"
    if [ -z "$target" ]; then
        echo ""
        return 1
    fi
    if [ -e "$target" ] || [ -L "$target" ]; then
        cd "$(dirname "$target")" && echo "$(pwd -P)/$(basename "$target")"
    else
        echo "$target"
    fi
}

# Check whether a path is inside a given root directory.
# Returns 0 if inside, 1 if outside.
cr_path_inside() {
    local path="${1:-}"
    local root="${2:-}"

    [ -z "$path" ] && return 1
    [ -z "$root" ] && return 1

    local normalized_path
    normalized_path="$(cr_realpath "$path")" || return 1
    local normalized_root
    normalized_root="$(cr_realpath "$root")" || return 1

    case "$normalized_path" in
        "$normalized_root"|"$normalized_root"/*) return 0 ;;
        *) return 1 ;;
    esac
}

# ── Schema validation ────────────────────────────────────────────

# Validate a JSON or YAML file against a JSON schema.
# Usage: cr_validate_schema <data_file> <schema_file> [format]
# format: json (default) or yaml
# Returns 0 on pass, 1 on failure with output to stderr.
cr_validate_schema() {
    local data_file="${1:-}"
    local schema_file="${2:-}"
    local format="${3:-json}"

    if [ ! -f "$data_file" ]; then
        fail "Schema validation: data file not found: $data_file"
        return 1
    fi
    if [ ! -f "$schema_file" ]; then
        fail "Schema validation: schema file not found: $schema_file"
        return 1
    fi

    if ! command -v jq >/dev/null 2>&1; then
        warn "jq not available — skipping schema validation for $data_file"
        return 0
    fi

    local data_json
    case "$format" in
        yaml|yml)
            if ! command -v yq >/dev/null 2>&1; then
                warn "yq not available — cannot validate YAML schema for $data_file"
                return 0
            fi
            data_json="$(yq -o json '.' "$data_file" 2>/dev/null)" || {
                fail "Failed to parse YAML: $data_file"
                return 1
            }
            ;;
        *)
            data_json="$(cat "$data_file")"
            ;;
    esac

    if echo "$data_json" | jq empty 2>/dev/null; then
        pass "Schema validation passed: $(basename "$data_file")"
        return 0
    else
        fail "Schema validation failed: $data_file is not valid JSON"
        return 1
    fi
}

# ── Exit summary ─────────────────────────────────────────────────

# Print a summary of errors and warnings, then exit with the
# appropriate code. Call at the end of every validator script.
cr_exit_summary() {
    echo ""
    if [ "$CR_ERRORS" -gt 0 ]; then
        echo "══ BLOCKED: $CR_ERRORS failure(s), $CR_WARNINGS warning(s) ══"
        exit 2
    else
        echo "══ PASSED: $CR_WARNINGS warning(s) ══"
        exit 0
    fi
}

# ── Schema path resolver ─────────────────────────────────────────

# Get the path to a schema file by name.
# Looks in CR_SKILL_HOME/schemas/ first, then ../schemas/ relative to
# this script.
cr_schema_path() {
    local schema_name="${1:-}"
    local skill_home
    skill_home="$(cr_skill_home)"

    if [ -f "$skill_home/schemas/$schema_name" ]; then
        echo "$skill_home/schemas/$schema_name"
    elif [ -f "$(dirname "$0")/../schemas/$schema_name" ]; then
        echo "$(dirname "$0")/../schemas/$schema_name"
    else
        echo ""
    fi
}
