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
# Priority: CR_WORKSPACE_ROOT env var > nearest _cr/workspace.yaml ancestor > git root > pwd.
cr_workspace_root() {
    if [ -n "${CR_WORKSPACE_ROOT:-}" ]; then
        echo "$CR_WORKSPACE_ROOT"
        return
    fi

    # Walk up from CWD looking for _cr/workspace.yaml.
    local dir
    dir="${CR_CWD:-$(pwd)}"
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/_cr/workspace.yaml" ]; then
            echo "$dir"
            return
        fi
        dir=$(dirname "$dir")
    done

    if git rev-parse --show-toplevel >/dev/null 2>&1; then
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

# Validate JSON data against a JSON Schema (Draft-07 subset).
# Uses jq to enforce required fields, types, enums, patterns, and numeric constraints.
# This is a pragmatic subset — not full JSON Schema. It covers the hard gates defined
# by the plan: file presence (caller checks), schema validity, ID uniqueness (separate
# validator), and required references (separate validator).
#
# Usage: cr_validate_json_schema <data_json> <schema_json>
# Returns 0 on pass, non-zero on failure. Outputs [PASS]/[FAIL] lines via pass()/fail().
cr_validate_json_schema() {
    local data_json="${1:-}"
    local schema_json="${2:-}"

    [ -z "$data_json" ] && { fail "Schema validation: no data provided"; return 1; }
    [ -z "$schema_json" ] && { fail "Schema validation: no schema provided"; return 1; }

    # Check that data is valid JSON.
    if ! printf '%s' "$data_json" | jq -e . >/dev/null 2>&1; then
        fail "Schema validation: data is not valid JSON"
        return 1
    fi

    # Check that schema is valid JSON.
    if ! printf '%s' "$schema_json" | jq -e . >/dev/null 2>&1; then
        fail "Schema validation: schema is not valid JSON"
        return 1
    fi

    local errors=0

    # ── required fields ──────────────────────────────────────────
    local req_fields
    req_fields=$(printf '%s' "$schema_json" | jq -r '.required // [] | .[]' 2>/dev/null)
    for field in $req_fields; do
        [ -z "$field" ] && continue
        local val
        val=$(printf '%s' "$data_json" | jq -r --arg f "$field" '.[$f] // empty' 2>/dev/null)
        if [ -z "$val" ] || [ "$val" = "null" ]; then
            fail "Schema validation: missing required field '$field'"
            errors=$((errors + 1))
        fi
    done

    # ── properties: type checks ──────────────────────────────────
    local prop_keys
    prop_keys=$(printf '%s' "$schema_json" | jq -r '.properties // {} | keys[]' 2>/dev/null)
    for key in $prop_keys; do
        [ -z "$key" ] && continue

        # Only validate properties that exist (required handled above, optional can be absent).
        local has_key
        has_key=$(printf '%s' "$data_json" | jq -r --arg k "$key" 'has($k)' 2>/dev/null)
        [ "$has_key" != "true" ] && continue

        local val_is_null
        val_is_null=$(printf '%s' "$data_json" | jq -r --arg k "$key" '.[$k] == null' 2>/dev/null)
        [ "$val_is_null" = "true" ] && continue

        # ── type constraint ──────────────────────────────────
        local exp_type
        exp_type=$(printf '%s' "$schema_json" | jq -r --arg k "$key" '.properties[$k].type // empty' 2>/dev/null)

        # Handle type being an array (e.g., ["string","null"]).
        if echo "$exp_type" | jq -e 'type == "array"' >/dev/null 2>&1; then
            local actual_type
            actual_type=$(printf '%s' "$data_json" | jq -r --arg k "$key" '.[$k] | type' 2>/dev/null)
            local type_match
            type_match=$(echo "$exp_type" | jq -r --arg at "$actual_type" '
              map(if . == "integer" then "number" else . end) | index($at) != null' 2>/dev/null)
            if [ "$type_match" != "true" ]; then
                fail "Schema validation: '$key' type is '$actual_type', expected one of $(echo "$exp_type" | jq -r 'join(",")')"
                errors=$((errors + 1))
            fi
        elif [ -n "$exp_type" ] && [ "$exp_type" != "null" ]; then
            local actual_type
            actual_type=$(printf '%s' "$data_json" | jq -r --arg k "$key" '.[$k] | type' 2>/dev/null)
            # JSON Schema "integer" maps to JSON type "number".
            local exp_normalized="$exp_type"
            [ "$exp_type" = "integer" ] && exp_normalized="number"
            if [ "$actual_type" != "$exp_normalized" ] && [ "$actual_type" != "null" ]; then
                fail "Schema validation: '$key' type is '$actual_type', expected '$exp_type'"
                errors=$((errors + 1))
            fi
        fi

        # ── enum constraint ──────────────────────────────────
        local enum_vals
        enum_vals=$(printf '%s' "$schema_json" | jq -r --arg k "$key" '.properties[$k].enum // empty' 2>/dev/null)
        if [ -n "$enum_vals" ] && [ "$enum_vals" != "null" ]; then
            local actual_val
            actual_val=$(printf '%s' "$data_json" | jq -r --arg k "$key" '.[$k] // empty' 2>/dev/null)
            if [ -n "$actual_val" ] && [ "$actual_val" != "null" ]; then
                local in_enum
                in_enum=$(echo "$enum_vals" | jq -r --arg av "$actual_val" 'index($av) != null' 2>/dev/null)
                if [ "$in_enum" != "true" ]; then
                    fail "Schema validation: '$key' value '$actual_val' not in allowed enum"
                    errors=$((errors + 1))
                fi
            fi
        fi

        # ── pattern constraint ───────────────────────────────
        local pattern
        pattern=$(printf '%s' "$schema_json" | jq -r --arg k "$key" '.properties[$k].pattern // empty' 2>/dev/null)
        if [ -n "$pattern" ] && [ "$pattern" != "null" ]; then
            local str_val
            str_val=$(printf '%s' "$data_json" | jq -r --arg k "$key" '.[$k] // empty' 2>/dev/null)
            if [ -n "$str_val" ] && [ "$str_val" != "null" ]; then
                if ! echo "$str_val" | grep -qE "$pattern" 2>/dev/null; then
                    fail "Schema validation: '$key' value '$str_val' does not match pattern '$pattern'"
                    errors=$((errors + 1))
                fi
            fi
        fi

        # ── minimum / maximum ────────────────────────────────
        local minimum
        minimum=$(printf '%s' "$schema_json" | jq -r --arg k "$key" '.properties[$k].minimum // empty' 2>/dev/null)
        if [ -n "$minimum" ] && [ "$minimum" != "null" ]; then
            local num_val
            num_val=$(printf '%s' "$data_json" | jq -r --arg k "$key" '.[$k] // empty' 2>/dev/null)
            if [ -n "$num_val" ] && [ "$num_val" != "null" ]; then
                if ! echo "$num_val" | jq -e --argjson min "$minimum" '. >= $min' >/dev/null 2>&1; then
                    fail "Schema validation: '$key' value $num_val is below minimum $minimum"
                    errors=$((errors + 1))
                fi
            fi
        fi

        local maximum
        maximum=$(printf '%s' "$schema_json" | jq -r --arg k "$key" '.properties[$k].maximum // empty' 2>/dev/null)
        if [ -n "$maximum" ] && [ "$maximum" != "null" ]; then
            local num_val2
            num_val2=$(printf '%s' "$data_json" | jq -r --arg k "$key" '.[$k] // empty' 2>/dev/null)
            if [ -n "$num_val2" ] && [ "$num_val2" != "null" ]; then
                if ! echo "$num_val2" | jq -e --argjson max "$maximum" '. <= $max' >/dev/null 2>&1; then
                    fail "Schema validation: '$key' value $num_val2 is above maximum $maximum"
                    errors=$((errors + 1))
                fi
            fi
        fi
    done

    # ── array constraints (minItems, uniqueItems) ──────────────────
    for key in $prop_keys; do
        [ -z "$key" ] && continue
        local has_key2
        has_key2=$(printf '%s' "$data_json" | jq -r --arg k "$key" 'has($k)' 2>/dev/null)
        [ "$has_key2" != "true" ] && continue

        local arr_type
        arr_type=$(printf '%s' "$data_json" | jq -r --arg k "$key" '.[$k] | type' 2>/dev/null)
        [ "$arr_type" != "array" ] && continue

        local min_items
        min_items=$(printf '%s' "$schema_json" | jq -r --arg k "$key" '.properties[$k].minItems // empty' 2>/dev/null)
        if [ -n "$min_items" ] && [ "$min_items" != "null" ]; then
            local arr_len
            arr_len=$(printf '%s' "$data_json" | jq -r --arg k "$key" '.[$k] | length' 2>/dev/null)
            if [ "$arr_len" -lt "$min_items" ]; then
                fail "Schema validation: '$key' has $arr_len items, minimum is $min_items"
                errors=$((errors + 1))
            fi
        fi

        local unique_items
        unique_items=$(printf '%s' "$schema_json" | jq -r --arg k "$key" '.properties[$k].uniqueItems // false' 2>/dev/null)
        if [ "$unique_items" = "true" ]; then
            local dup_count
            dup_count=$(printf '%s' "$data_json" | jq -r --arg k "$key" '.[$k] | group_by(.) | map(select(length > 1)) | length' 2>/dev/null)
            if [ "${dup_count:-0}" -gt 0 ]; then
                fail "Schema validation: '$key' has duplicate items (uniqueItems required)"
                errors=$((errors + 1))
            fi
        fi
    done

    if [ "$errors" -gt 0 ]; then
        fail "Schema validation: $errors constraint violation(s)"
        return 1
    fi
    return 0
}

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

    local data_json schema_json
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

    schema_json="$(cat "$schema_file")"

    # First check data is valid JSON.
    if ! printf '%s' "$data_json" | jq -e . >/dev/null 2>&1; then
        fail "Schema validation failed: $data_file is not valid JSON"
        return 1
    fi

    # Run constraint-level validation against the schema.
    cr_validate_json_schema "$data_json" "$schema_json" || {
        return 1
    }

    pass "Schema validation passed: $(basename "$data_file")"
    return 0
}

# ── Artifact registry helpers ─────────────────────────────────

# Load the artifact registry JSON. Returns path or empty.
cr_artifact_registry_path() {
    local skill_home
    skill_home="$(cr_skill_home)"
    if [ -f "$skill_home/schemas/artifact-registry.json" ]; then
        echo "$skill_home/schemas/artifact-registry.json"
    else
        echo ""
    fi
}

# Get required output keys for a given round type and workflow mode.
# Usage: cr_required_outputs <round_yaml> -> space-separated list of output keys
cr_required_outputs() {
    local round_yaml="${1:-}"
    [ -z "$round_yaml" ] && { echo "report evidence_update critique_update writing_diff knowledge_delta"; return; }
    [ ! -f "$round_yaml" ] && { echo "report evidence_update critique_update writing_diff knowledge_delta"; return; }

    # Extract required_outputs from round.yaml.
    if command -v yq >/dev/null 2>&1; then
        yq -r '.required_outputs // [] | join(" ")' "$round_yaml" 2>/dev/null || \
            echo "report evidence_update critique_update writing_diff knowledge_delta"
    else
        # Fallback: parse YAML manually.
        grep -E '^\s*-\s+' "$round_yaml" 2>/dev/null | \
            sed 's/^\s*-\s*//' | tr '\n' ' ' || \
            echo "report evidence_update critique_update writing_diff knowledge_delta"
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
