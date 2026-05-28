#!/usr/bin/env bash
# test-hook-injects-v2-mandate.sh — Verify UserPromptSubmit hook injects
# v2 stage mandate from workflow-state.yaml (not v1 phase mandate).
set -euo pipefail

FAILS=0; PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'
pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
export CR_TEST_MODE=1

HOOK_SCRIPT="$SCRIPT_DIR/../scripts/cr-hook-user-prompt-submit"

TEST_DIR=$(mktemp -d /tmp/cr-hookv2-XXXXXX)
trap "rm -rf $TEST_DIR" EXIT
cd "$TEST_DIR"

echo "══ Hook Injects V2 Mandate Test ══"
echo ""

cr workspace init > /dev/null 2>&1
cr project init htest --domain systems > /dev/null 2>&1

# Set active project
echo "htest" > _cr/active-project

cd htest
cr document add htest paper --type paper --path documents/paper.md > /dev/null 2>&1
echo "# Test Paper" > documents/paper.md

cr round start htest --workflow paper --doc paper --mode triage --objective "hook test" > /dev/null 2>&1

ROUND_DIR=$(ls -d rounds/round-* | head -1)
WF_STATE="$ROUND_DIR/workflow-state.yaml"

echo "── Running hook ──"
HOOK_OUT=$("$HOOK_SCRIPT" 2>/dev/null || echo '{}')
echo "$HOOK_OUT"

# 1. Hook output is valid JSON
if echo "$HOOK_OUT" | jq -e '.hookSpecificOutput' > /dev/null 2>&1; then
    pass "hook output is valid JSON"
else
    fail "hook output not valid JSON"
fi

# 2. Hook mentions "Stage" not "Phase"
CTX=$(echo "$HOOK_OUT" | jq -r '.hookSpecificOutput.additionalContext // ""')
if echo "$CTX" | grep -q "Stage Execution Required"; then
    pass "hook says 'Stage Execution Required' (v2)"
else
    fail "hook does NOT say 'Stage Execution Required'"
fi

# 3. Hook references current_stage from workflow-state.yaml
CUR=$(yq -r '.current_stage' "$WF_STATE" 2>/dev/null || echo "")
if echo "$CTX" | grep -q "$CUR"; then
    pass "hook references current stage '$CUR'"
else
    fail "hook does not reference current stage '$CUR'"
fi

# 4. Hook says 'cr stage advance' not 'cr step advance'
if echo "$CTX" | grep -q "cr stage advance"; then
    pass "hook says 'cr stage advance' (v2)"
else
    fail "hook does NOT say 'cr stage advance'"
fi

# 5. Hook should NOT say 'cr step' (v1)
if echo "$CTX" | grep -q "cr step"; then
    fail "hook still references 'cr step' (v1)"
else
    pass "hook does NOT reference 'cr step' (no v1)"
fi

echo ""
echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
