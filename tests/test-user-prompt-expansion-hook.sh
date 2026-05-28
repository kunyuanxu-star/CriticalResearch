#!/usr/bin/env bash
# test-user-prompt-expansion-hook.sh — Verify UserPromptExpansion hook output protocol.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK="$SCRIPT_DIR/../scripts/cr-hook-user-prompt-expansion"
TEST_DIR=$(mktemp -d /tmp/cr-upe-XXXXXX)

echo "══ UserPromptExpansion Hook Tests ══"
echo ""

# ── Helper: run hook with JSON input ──
run_hook() {
    local json="$1"
    echo "$json" | "$HOOK" 2>/dev/null || true
}

# ── Test 1: missing arguments → block ──
echo "── Test 1: missing arguments → block ──"
OUT=$(run_hook '{"commandText":"/critical-cs-research"}')
if echo "$OUT" | grep '"decision"' | grep -q '"block"'; then
    if echo "$OUT" | grep -q "Usage: /critical-cs-research"; then
        pass "Block with usage message"
    else
        fail "Block but wrong reason"
    fi
else
    fail "Should return decision:block"
    echo "$OUT"
fi
echo ""

# ── Test 2: project missing → block ──
echo "── Test 2: project missing → block ──"
OUT=$(run_hook '{"commandText":"/critical-cs-research nonexistent-project test objective"}')
if echo "$OUT" | grep '"decision"' | grep -q '"block"'; then
    if echo "$OUT" | grep -q "not found"; then
        pass "Block when project missing"
    else
        fail "Block but wrong reason"
    fi
else
    fail "Should return decision:block"
    echo "$OUT"
fi
echo ""

# Initialize a minimal workspace for cr_workspace_root.
mkdir -p "$TEST_DIR/test-workspace/_cr"
echo "workspace_name: test" > "$TEST_DIR/test-workspace/_cr/workspace.yaml"

# ── Test 3: paper-draft.md missing → block ──
echo "── Test 3: paper-draft.md missing → block ──"
mkdir -p "$TEST_DIR/test-workspace/test-proj/writing" "$TEST_DIR/test-workspace/test-proj/state"
echo "schema_version: \"1.0.0\"" > "$TEST_DIR/test-workspace/test-proj/state/claim-ledger.yaml"
echo '{"active_round": null}' > "$TEST_DIR/test-workspace/test-proj/state/project-state.json"

OUT=$(cd "$TEST_DIR/test-workspace" && CR_SKILL_HOME="$SCRIPT_DIR/.." run_hook '{"commandText":"/critical-cs-research test-proj test objective"}')
if echo "$OUT" | grep '"decision"' | grep -q '"block"'; then
    if echo "$OUT" | grep -q "documents/paper.md"; then
        pass "Block when paper-draft.md missing"
    else
        fail "Block but wrong reason"
    fi
else
    fail "Should return decision:block"
    echo "$OUT"
fi
echo ""

# ── Test 4: active_round exists → block ──
echo "── Test 4: active_round exists → block ──"
mkdir -p "$TEST_DIR/test-workspace/test-proj2/documents" "$TEST_DIR/test-workspace/test-proj2/state"
echo "# test" > "$TEST_DIR/test-workspace/test-proj2/documents/paper.md"
echo "schema_version: \"1.0.0\"" > "$TEST_DIR/test-workspace/test-proj2/state/claim-ledger.yaml"
echo '{"active_round": 1}' > "$TEST_DIR/test-workspace/test-proj2/state/project-state.json"

OUT=$(cd "$TEST_DIR/test-workspace" && CR_SKILL_HOME="$SCRIPT_DIR/.." run_hook '{"commandText":"/critical-cs-research test-proj2 test objective"}')
if echo "$OUT" | grep '"decision"' | grep -q '"block"'; then
    if echo "$OUT" | grep -q "active round"; then
        pass "Block when active_round exists"
    else
        fail "Block but wrong reason"
    fi
else
    fail "Should return decision:block"
    echo "$OUT"
fi
echo ""

# ── Test 5: valid args → allow with additionalContext ──
echo "── Test 5: valid args → allow with additionalContext ──"
mkdir -p "$TEST_DIR/test-workspace/test-proj3/documents" "$TEST_DIR/test-workspace/test-proj3/state"
echo "# test" > "$TEST_DIR/test-workspace/test-proj3/documents/paper.md"
echo "schema_version: \"1.0.0\"" > "$TEST_DIR/test-workspace/test-proj3/state/claim-ledger.yaml"
echo '{"active_round": null}' > "$TEST_DIR/test-workspace/test-proj3/state/project-state.json"

OUT=$(cd "$TEST_DIR/test-workspace" && CR_SKILL_HOME="$SCRIPT_DIR/.." run_hook '{"commandText":"/critical-cs-research test-proj3 test objective"}')
if echo "$OUT" | grep -q '"hookSpecificOutput"'; then
    if echo "$OUT" | grep '"hookEventName"' | grep -q '"UserPromptExpansion"'; then
        if echo "$OUT" | grep -q "cr round start"; then
            pass "Allow with correct hookEventName and additionalContext"
        else
            fail "Missing cr round start in additionalContext"
        fi
    else
        fail "Missing hookEventName"
    fi
else
    fail "Should return hookSpecificOutput"
    echo "$OUT"
fi
echo ""

# ── Test 6: no permissionDecision in output ──
echo "── Test 6: output never contains permissionDecision ──"
for test_json in '{"commandText":"/critical-cs-research"}' \
    '{"commandText":"/critical-cs-research bad test"}' \
    '{"commandText":"/critical-cs-research test-proj3 test objective"}'; do
    OUT=$(cd "$TEST_DIR/test-workspace" && CR_SKILL_HOME="$SCRIPT_DIR/.." run_hook "$test_json")
    if echo "$OUT" | grep -q "permissionDecision"; then
        fail "Output contains legacy permissionDecision"
        echo "$OUT"
        break
    fi
done
pass "No permissionDecision in any output"
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
