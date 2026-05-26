#!/usr/bin/env bash
# test-config-change-blocks-hook-removal.sh — Verify ConfigChange hook detects enforcement weakening.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK="$SCRIPT_DIR/../scripts/cr-hook-config-change"
TEST_DIR=$(mktemp -d /tmp/cr-cc-XXXXXX)

echo "══ ConfigChange Hook Tests ══"
echo ""

# ── Helper: run hook in a temp directory with given settings.json ──
run_hook_in_dir() {
    local dir="$1"
    (cd "$dir" && "$HOOK" <<< '{}' 2>/dev/null || true)
}

# ── Test 1: all hooks present → allow ──
echo "── Test 1: all hooks present → allow ──"
mkdir -p "$TEST_DIR/good/.claude"
cat > "$TEST_DIR/good/.claude/settings.json" << 'JSON'
{
  "hooks": {
    "UserPromptExpansion": [{"hooks": [{"type": "command", "command": "hook"}]}],
    "UserPromptSubmit": [{"hooks": [{"type": "command", "command": "hook"}]}],
    "PreToolUse": [{"matcher": "Write|Edit|MultiEdit|Bash", "hooks": [{"type": "command", "command": "hook"}]}],
    "PostToolUse": [{"hooks": [{"type": "command", "command": "hook"}]}],
    "Stop": [{"hooks": [{"type": "command", "command": "critical-research-hook stop"}]}],
    "ConfigChange": [{"matcher": "project_settings", "hooks": [{"type": "command", "command": "hook"}]}]
  }
}
JSON

OUT=$(run_hook_in_dir "$TEST_DIR/good")
if echo "$OUT" | grep '"decision"' | grep -q '"allow"'; then
    pass "Allow when all hooks present"
else
    fail "Should allow when all hooks present"
    echo "$OUT"
fi
echo ""

# ── Test 2: UserPromptExpansion missing → block ──
echo "── Test 2: UserPromptExpansion missing → block ──"
mkdir -p "$TEST_DIR/no-upe/.claude"
cat > "$TEST_DIR/no-upe/.claude/settings.json" << 'JSON'
{
  "hooks": {
    "UserPromptSubmit": [{"hooks": [{"type": "command", "command": "hook"}]}],
    "PreToolUse": [{"matcher": "Write|Edit|MultiEdit|Bash", "hooks": [{"type": "command", "command": "hook"}]}],
    "PostToolUse": [{"hooks": [{"type": "command", "command": "hook"}]}],
    "Stop": [{"hooks": [{"type": "command", "command": "critical-research-hook stop"}]}],
    "ConfigChange": [{"matcher": "project_settings", "hooks": [{"type": "command", "command": "hook"}]}]
  }
}
JSON

OUT=$(run_hook_in_dir "$TEST_DIR/no-upe")
if echo "$OUT" | grep '"decision"' | grep -q '"block"'; then
    if echo "$OUT" | grep -q "UserPromptExpansion"; then
        pass "Block when UserPromptExpansion missing"
    else
        fail "Block but wrong reason"
    fi
else
    fail "Should block when UserPromptExpansion missing"
    echo "$OUT"
fi
echo ""

# ── Test 3: PreToolUse matcher weakened → block ──
echo "── Test 3: PreToolUse matcher weakened → block ──"
mkdir -p "$TEST_DIR/bad-matcher/.claude"
cat > "$TEST_DIR/bad-matcher/.claude/settings.json" << 'JSON'
{
  "hooks": {
    "UserPromptExpansion": [{"hooks": [{"type": "command", "command": "hook"}]}],
    "UserPromptSubmit": [{"hooks": [{"type": "command", "command": "hook"}]}],
    "PreToolUse": [{"matcher": "Write", "hooks": [{"type": "command", "command": "hook"}]}],
    "PostToolUse": [{"hooks": [{"type": "command", "command": "hook"}]}],
    "Stop": [{"hooks": [{"type": "command", "command": "critical-research-hook stop"}]}],
    "ConfigChange": [{"matcher": "project_settings", "hooks": [{"type": "command", "command": "hook"}]}]
  }
}
JSON

OUT=$(run_hook_in_dir "$TEST_DIR/bad-matcher")
if echo "$OUT" | grep '"decision"' | grep -q '"block"'; then
    if echo "$OUT" | grep -q "PreToolUse"; then
        pass "Block when PreToolUse matcher weakened"
    else
        fail "Block but wrong reason"
    fi
else
    fail "Should block when PreToolUse matcher weakened"
    echo "$OUT"
fi
echo ""

# ── Test 4: Stop hook does not dispatch critical-research-hook → block ──
echo "── Test 4: Stop hook dispatch wrong → block ──"
mkdir -p "$TEST_DIR/bad-stop/.claude"
cat > "$TEST_DIR/bad-stop/.claude/settings.json" << 'JSON'
{
  "hooks": {
    "UserPromptExpansion": [{"hooks": [{"type": "command", "command": "hook"}]}],
    "UserPromptSubmit": [{"hooks": [{"type": "command", "command": "hook"}]}],
    "PreToolUse": [{"matcher": "Write|Edit|MultiEdit|Bash", "hooks": [{"type": "command", "command": "hook"}]}],
    "PostToolUse": [{"hooks": [{"type": "command", "command": "hook"}]}],
    "Stop": [{"hooks": [{"type": "command", "command": "wrong-hook stop"}]}],
    "ConfigChange": [{"matcher": "project_settings", "hooks": [{"type": "command", "command": "hook"}]}]
  }
}
JSON

OUT=$(run_hook_in_dir "$TEST_DIR/bad-stop")
if echo "$OUT" | grep '"decision"' | grep -q '"block"'; then
    if echo "$OUT" | grep -q "Stop"; then
        pass "Block when Stop hook dispatch incorrect"
    else
        fail "Block but wrong reason"
    fi
else
    fail "Should block when Stop hook dispatch incorrect"
    echo "$OUT"
fi
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
