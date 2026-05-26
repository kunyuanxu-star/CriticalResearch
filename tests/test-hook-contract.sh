#!/usr/bin/env bash
# test-hook-contract.sh — Verify Claude Code hook contract is complete.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SETTINGS="$SCRIPT_DIR/../.claude/settings.json"
WRAPPER="$SCRIPT_DIR/../scripts/critical-research-hook"

echo "══ Hook Contract Tests ══"
echo ""

# ── Test 1: UserPromptExpansion exists in settings.json ──
echo "── Test 1: UserPromptExpansion in settings.json ──"
if [ -f "$SETTINGS" ] && grep -q '"UserPromptExpansion"' "$SETTINGS"; then
    pass "UserPromptExpansion configured"
else
    fail "UserPromptExpansion missing from settings.json"
fi
echo ""

# ── Test 2: ConfigChange exists in settings.json ──
echo "── Test 2: ConfigChange in settings.json ──"
if [ -f "$SETTINGS" ] && grep -q '"ConfigChange"' "$SETTINGS"; then
    pass "ConfigChange configured"
else
    fail "ConfigChange missing from settings.json"
fi
echo ""

# ── Test 3: UserPromptSubmit exists ──
echo "── Test 3: UserPromptSubmit in settings.json ──"
if [ -f "$SETTINGS" ] && grep -q '"UserPromptSubmit"' "$SETTINGS"; then
    pass "UserPromptSubmit configured"
else
    fail "UserPromptSubmit missing"
fi
echo ""

# ── Test 4: PreToolUse exists with correct matcher ──
echo "── Test 4: PreToolUse matcher covers Write|Edit|MultiEdit|Bash ──"
if [ -f "$SETTINGS" ] && grep -A5 '"PreToolUse"' "$SETTINGS" | grep -q 'Write|Edit|MultiEdit|Bash'; then
    pass "PreToolUse matcher correct"
else
    fail "PreToolUse matcher incorrect or missing"
fi
echo ""

# ── Test 5: PostToolUse exists ──
echo "── Test 5: PostToolUse in settings.json ──"
if [ -f "$SETTINGS" ] && grep -q '"PostToolUse"' "$SETTINGS"; then
    pass "PostToolUse configured"
else
    fail "PostToolUse missing"
fi
echo ""

# ── Test 6: Stop hook exists and dispatches critical-research-hook ──
echo "── Test 6: Stop hook dispatches critical-research-hook ──"
if [ -f "$SETTINGS" ] && grep -A5 '"Stop"' "$SETTINGS" | grep -q 'critical-research-hook stop'; then
    pass "Stop hook dispatches correctly"
else
    fail "Stop hook dispatch incorrect"
fi
echo ""

# ── Test 7: critical-research-hook wrapper dispatches all 6 events ──
echo "── Test 7: critical-research-hook dispatches all events ──"
for event in user-prompt-expansion user-prompt-submit pre-tool-use post-tool-use stop config-change; do
    if grep -q "${event})" "$WRAPPER" 2>/dev/null; then
        pass "Dispatch: $event"
    else
        fail "Missing dispatch: $event"
    fi
done
echo ""

# ── Test 8: Hook scripts exist and are executable ──
echo "── Test 8: Hook scripts are executable ──"
for script in cr-hook-user-prompt-expansion cr-hook-user-prompt-submit cr-hook-pre-tool-use cr-hook-post-tool-use cr-hook-stop cr-hook-config-change; do
    f="$SCRIPT_DIR/../scripts/$script"
    if [ -x "$f" ]; then
        pass "$script is executable"
    else
        fail "$script missing or not executable"
    fi
done
echo ""

# ── Test 9: No disableAllHooks:true in tracked files ──
echo "── Test 9: No disableAllHooks:true ──"
if grep -r '"disableAllHooks"\s*:\s*true' "$SCRIPT_DIR/.." --include="*.json" 2>/dev/null | grep -v '.git/' | grep -v 'node_modules' > /dev/null; then
    fail "disableAllHooks:true found"
else
    pass "No disableAllHooks:true found"
fi
echo ""

# ── Test 10: UserPromptExpansion matcher is critical-cs-research ──
echo "── Test 10: UserPromptExpansion matcher is critical-cs-research ──"
if [ -f "$SETTINGS" ] && grep -A3 '"UserPromptExpansion"' "$SETTINGS" | grep -q 'critical-cs-research'; then
    pass "UserPromptExpansion matcher correct"
else
    fail "UserPromptExpansion matcher incorrect"
fi
echo ""

# ── Test 11: ConfigChange matcher covers project_settings ──
echo "── Test 11: ConfigChange matcher covers project_settings ──"
if [ -f "$SETTINGS" ] && grep -A3 '"ConfigChange"' "$SETTINGS" | grep -q 'project_settings'; then
    pass "ConfigChange matcher correct"
else
    fail "ConfigChange matcher incorrect"
fi
echo ""

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
