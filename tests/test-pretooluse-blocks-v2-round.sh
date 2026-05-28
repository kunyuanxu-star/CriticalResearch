#!/usr/bin/env bash
# test-pretooluse-blocks-v2-round.sh — Verify PreToolUse hook blocks
# writes outside the mutable document in a v2 round.
set -euo pipefail

FAILS=0; PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'
pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
export CR_TEST_MODE=1

HOOK_SCRIPT="$SCRIPT_DIR/../scripts/cr-hook-pre-tool-use"

TEST_DIR=$(mktemp -d /tmp/cr-ptublock-XXXXXX)
trap "rm -rf $TEST_DIR" EXIT
cd "$TEST_DIR"

echo "══ PreToolUse Blocks V2 Round Test ══"
echo ""

cr workspace init > /dev/null 2>&1
cr project init ptest --domain systems > /dev/null 2>&1

echo "ptest" > _cr/active-project

cd ptest

# Create two documents
cr document add ptest paper --type paper --path documents/paper.md > /dev/null 2>&1
cr document add ptest survey --type survey --path documents/survey.md > /dev/null 2>&1
echo "# Test Paper" > documents/paper.md
echo "# Test Survey" > documents/survey.md

# Start a round targeting the paper document
cr round start ptest --workflow paper --doc paper --mode triage --objective "boundary test" > /dev/null 2>&1

ROUND_DIR=$(ls -d rounds/round-* | head -1)

echo "── Testing mutable document boundary ──"

# Simulate PreToolUse JSON input for writing to the mutable document (paper.md)
MUTABLE_INPUT=$(jq -n --arg p "$TEST_DIR/ptest/documents/paper.md" '{
    tool_name: "Write",
    tool_input: { file_path: $p }
}')

MUTABLE_OUT=$(echo "$MUTABLE_INPUT" | "$HOOK_SCRIPT" 2>/dev/null || echo "")
MUTABLE_CODE=$?

# Should allow write to the mutable document
if [ "$MUTABLE_CODE" -eq 0 ]; then
    pass "write to mutable document (paper.md) allowed"
else
    fail "write to mutable document (paper.md) blocked unexpectedly"
fi

# Simulate PreToolUse JSON input for writing to a different document (survey.md)
CROSS_INPUT=$(jq -n --arg p "$TEST_DIR/ptest/documents/survey.md" '{
    tool_name: "Write",
    tool_input: { file_path: $p }
}')

CROSS_OUT=$(echo "$CROSS_INPUT" | "$HOOK_SCRIPT" 2>/dev/null || echo "")
CROSS_CODE=$?

# Check if cross-document write is blocked
# The hook might exit 0 but output a deny decision via JSON
DENIED=false
if echo "$CROSS_OUT" | jq -e '.hookSpecificOutput.permissionDecision == "deny"' >/dev/null 2>&1; then
    DENIED=true
elif [ "$CROSS_CODE" -ne 0 ]; then
    DENIED=true
fi

if [ "$DENIED" = true ]; then
    pass "cross-document write to survey.md blocked"
else
    fail "cross-document write to survey.md was NOT blocked"
fi

echo ""
echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
