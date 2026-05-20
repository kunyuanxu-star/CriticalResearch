#!/usr/bin/env bash
# check-round.sh — PostToolUse hook for paper-mode round validation.
# Replaces the old check-all.sh which validated legacy research-output artifacts.
# Checks active round state: required files, critique presence, and paper-mode
# artifacts if workflow_mode is paper.
#
# Called by PostToolUse hook after every Write/Edit.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_HOME="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source common framework if available.
[ -f "$SKILL_HOME/scripts/cr-common.sh" ] && source "$SKILL_HOME/scripts/cr-common.sh"

# Find workspace root via shared resolver.
WORKSPACE_ROOT=$(cr_workspace_root 2>/dev/null || echo "${CR_WORKSPACE_ROOT:-$(pwd)}")

# Check if there's an active project.
ACTIVE_PROJECT_FILE="$WORKSPACE_ROOT/_cr/active-project"
if [ ! -f "$ACTIVE_PROJECT_FILE" ]; then
    # No active project — nothing to validate.
    exit 0
fi

ACTIVE_PROJECT=$(cat "$ACTIVE_PROJECT_FILE")
PROJECT_DIR="$WORKSPACE_ROOT/$ACTIVE_PROJECT"

if [ ! -d "$PROJECT_DIR" ]; then
    exit 0
fi

# Check project state.
STATE_FILE="$PROJECT_DIR/state/project-state.json"
if [ ! -f "$STATE_FILE" ]; then
    exit 0
fi

ACTIVE_ROUND=$(jq -r '.active_round // empty' "$STATE_FILE" 2>/dev/null || echo "")
if [ -z "$ACTIVE_ROUND" ] || [ "$ACTIVE_ROUND" = "null" ]; then
    exit 0
fi

ROUND_NUM=$(printf "%03d" "$ACTIVE_ROUND")
ROUND_DIR="$PROJECT_DIR/rounds/round-$ROUND_NUM"

if [ ! -d "$ROUND_DIR" ]; then
    exit 0
fi

# Basic artifact presence check (non-blocking warning only in PostToolUse).
MISSING=""
for req in report.md sources.md critique.md knowledge-delta.md; do
    [ ! -f "$ROUND_DIR/$req" ] && MISSING="$MISSING $req"
done

if [ -n "$MISSING" ]; then
    echo "[check-round] WARNING: Round $ACTIVE_ROUND missing:$MISSING" >&2
fi

# Paper mode: check dispositions and patches.
WORKFLOW_MODE=$(grep -E '^workflow_mode:' "$ROUND_DIR/round.yaml" 2>/dev/null | sed 's/^workflow_mode:\s*//' | xargs || echo "")
if [ "$WORKFLOW_MODE" = "paper" ]; then
    if [ ! -f "$ROUND_DIR/dispositions.yaml" ]; then
        echo "[check-round] WARNING: Paper mode round $ACTIVE_ROUND has no dispositions.yaml" >&2
    fi
    if [ -d "$ROUND_DIR/patches" ]; then
        for pf in "$ROUND_DIR/patches"/PP-*.yaml; do
            [ ! -f "$pf" ] && continue
            PP_ID=$(basename "$pf" .yaml)
            if ! grep -q 'knowledge_implication:' "$pf" 2>/dev/null; then
                echo "[check-round] WARNING: $PP_ID missing knowledge_implication" >&2
            fi
        done
    fi
fi

exit 0
