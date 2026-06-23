#!/usr/bin/env bash
# CriticalResearch installer.

set -euo pipefail

SKILL_NAME="critical-cs-research"
SKILL_DIR="${CR_SKILL_HOME:-$HOME/.claude/skills/$SKILL_NAME}"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "CriticalResearch Installer"
echo "=========================="
echo ""

MISSING=""
for dep in git bash python3; do
    if command -v "$dep" >/dev/null 2>&1; then
        echo "  FOUND: $dep"
    else
        echo "  MISSING: $dep"
        MISSING="$MISSING $dep"
    fi
done

if [ -n "$MISSING" ]; then
    echo ""
    echo "Install missing dependencies before continuing:$MISSING"
    exit 1
fi

echo ""
echo "Installing skill to: $SKILL_DIR"

if [ "$REPO_DIR" != "$SKILL_DIR" ]; then
    mkdir -p "$(dirname "$SKILL_DIR")"
    if [ -d "$SKILL_DIR" ]; then
        rsync -a --delete --exclude '.git' --exclude '.humanize' --exclude '.claude/settings.local.json' "$REPO_DIR/" "$SKILL_DIR/"
    else
        cp -R "$REPO_DIR" "$SKILL_DIR"
        rm -rf "$SKILL_DIR/.git" "$SKILL_DIR/.humanize" 2>/dev/null || true
    fi
else
    echo "  Already at install location, skipping copy."
fi

chmod +x "$SKILL_DIR/scripts/"* 2>/dev/null || true
chmod +x "$SKILL_DIR/install.sh" 2>/dev/null || true

mkdir -p "$HOME/.local/bin"
cp "$SKILL_DIR/scripts/critical-research-hook" "$HOME/.local/bin/critical-research-hook"
chmod +x "$HOME/.local/bin/critical-research-hook"

if [ "${1:-}" != "--skill-only" ]; then
    SHELL_RC="$HOME/.profile"
    case "${SHELL:-}" in
        */zsh) SHELL_RC="$HOME/.zshrc" ;;
        */bash) SHELL_RC="$HOME/.bashrc" ;;
    esac

    EXPORT_LINE="export CR_SKILL_HOME=\"$SKILL_DIR\""
    PATH_LINE="export PATH=\"$SKILL_DIR/scripts:\$PATH\""

    touch "$SHELL_RC"
    if ! grep -q "$SKILL_DIR/scripts" "$SHELL_RC" 2>/dev/null; then
        {
            echo ""
            echo "# CriticalResearch"
            echo "$EXPORT_LINE"
            echo "$PATH_LINE"
        } >> "$SHELL_RC"
        echo "  Added CLI path to $SHELL_RC"
    else
        echo "  CLI path already configured in $SHELL_RC"
    fi
fi

echo ""
echo "Installation complete."
echo ""
echo "Quick start:"
echo "  cr workspace init"
echo "  cr project init edge-cache --domain systems"
echo "  cr run edge-cache \"Can we design a cache invalidation strategy for edge deployments?\""
