#!/usr/bin/env bash
# CriticalResearch Installer
# Installs the skill into ~/.claude/skills/critical-cs-research/ and
# adds CLI tools to PATH.
#
# Usage:
#   bash install.sh              # Install skill + CLI
#   bash install.sh --skill-only # Only install skill, skip CLI PATH setup
#   bash install.sh --help       # Show options

set -euo pipefail

SKILL_NAME="critical-cs-research"
SKILL_DIR="${CR_SKILL_HOME:-$HOME/.claude/skills/$SKILL_NAME}"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "CriticalResearch Installer"
echo "========================="
echo ""

# ── Dependency check ────────────────────────────────────────────
echo "Checking dependencies..."
MISSING_DEPS=""
for dep in jq git bash; do
    if ! command -v "$dep" >/dev/null 2>&1; then
        echo "  MISSING: $dep (required)"
        MISSING_DEPS="$MISSING_DEPS $dep"
    else
        echo "  FOUND: $dep"
    fi
done
if ! command -v yq >/dev/null 2>&1; then
    echo "  MISSING: yq (required for paper mode — brew install yq)"
    MISSING_DEPS="$MISSING_DEPS yq"
else
    echo "  FOUND: yq"
fi
if [ -n "$MISSING_DEPS" ]; then
    echo ""
    echo "Install missing dependencies before continuing:$MISSING_DEPS"
    echo "  brew install jq yq"
    exit 1
fi
echo ""

# ── Install skill ───────────────────────────────────────────────

echo "Installing skill to: $SKILL_DIR"

if [ "$REPO_DIR" != "$SKILL_DIR" ]; then
    mkdir -p "$(dirname "$SKILL_DIR")"
    if [ -d "$SKILL_DIR" ]; then
        echo "  Updating existing installation..."
        rsync -a --exclude '.git' --exclude '.humanize' --exclude '.claude' "$REPO_DIR/" "$SKILL_DIR/"
    else
        echo "  Creating new installation..."
        cp -r "$REPO_DIR" "$SKILL_DIR"
        rm -rf "$SKILL_DIR/.git" "$SKILL_DIR/.humanize" 2>/dev/null || true
    fi
else
    echo "  Already at install location, skipping copy."
fi

# Make all scripts executable.
chmod +x "$SKILL_DIR/scripts/"* 2>/dev/null || true
chmod +x "$SKILL_DIR/hooks/"*.sh 2>/dev/null || true
chmod +x "$SKILL_DIR/install.sh" 2>/dev/null || true

echo "  Skill installed."

# ── Install hook wrapper to PATH ─────────────────────────────────
HOOK_WRAPPER="$HOME/.local/bin/critical-research-hook"
mkdir -p "$(dirname "$HOOK_WRAPPER")"
cp "$SKILL_DIR/scripts/critical-research-hook" "$HOOK_WRAPPER"
chmod +x "$HOOK_WRAPPER"
echo "  Hook wrapper installed to $HOOK_WRAPPER"

# ── Install CLI PATH ────────────────────────────────────────────

if [ "${1:-}" != "--skill-only" ]; then
    echo ""
    echo "Adding CLI to PATH..."

    SHELL_RC=""
    case "$SHELL" in
        */zsh) SHELL_RC="$HOME/.zshrc" ;;
        */bash) SHELL_RC="$HOME/.bashrc" ;;
        *) SHELL_RC="$HOME/.profile" ;;
    esac

    EXPORT_LINE="export CR_SKILL_HOME=\"$SKILL_DIR\""
    PATH_LINE="export PATH=\"$SKILL_DIR/scripts:\$PATH\""

    if [ -f "$SHELL_RC" ]; then
        if ! grep -q "$SKILL_DIR/scripts" "$SHELL_RC" 2>/dev/null; then
            echo "" >> "$SHELL_RC"
            echo "# CriticalResearch" >> "$SHELL_RC"
            echo "$EXPORT_LINE" >> "$SHELL_RC"
            echo "$PATH_LINE" >> "$SHELL_RC"
            echo "  Added to $SHELL_RC"
        else
            echo "  PATH already configured in $SHELL_RC"
        fi
    else
        echo ""
        echo "  Add this to your shell config:"
        echo "    $EXPORT_LINE"
    fi

    echo ""
    echo "  To use CLI now, run:"
    echo "    source $SHELL_RC"
fi

echo ""
echo "Installation complete."
echo ""
echo "Quick start:"
echo "  1. cd ~/Research  (or any directory)"
echo "  2. cr workspace init"
echo "  3. cr start my-research-topic"
echo "  4. cr round my-research-topic --mode paper"
echo ""
echo "For Claude Code: the skill activates automatically when you ask"
echo "about CS research tasks. Paper mode is selected by running a round"
echo "with --mode paper or by setting workflow_mode: paper in round.yaml."
