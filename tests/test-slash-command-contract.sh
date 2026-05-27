#!/usr/bin/env bash
# test-slash-command-contract.sh — Verify slash command has proper frontmatter contract.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CMD_FILE="$SCRIPT_DIR/../commands/critical-cs-research.md"

echo "══ Slash Command Contract Tests ══"
echo "File: $CMD_FILE"
echo ""

# ── Test 1: YAML frontmatter exists ──
echo "── Test 1: YAML frontmatter exists ──"
if head -1 "$CMD_FILE" | grep -q '^---$'; then
    pass "File starts with YAML frontmatter delimiter"
else
    fail "Missing YAML frontmatter opening '---'"
fi

if grep -q '^---$' "$CMD_FILE" | head -2 | tail -1; then
    pass "YAML frontmatter closing '---' exists"
else
    # Check if there's a second --- after the first
    DELIM_COUNT=$(grep -c '^---$' "$CMD_FILE" || echo "0")
    if [ "$DELIM_COUNT" -ge 2 ]; then
        pass "YAML frontmatter has opening and closing '---'"
    else
        fail "Missing YAML frontmatter closing '---'"
    fi
fi
echo ""

# ── Test 2: allowed-tools exists in frontmatter ──
echo "── Test 2: allowed-tools exists in frontmatter ──"
# Extract frontmatter (between first two --- lines)
FRONTMATTER=$(sed -n '/^---$/,/^---$/p' "$CMD_FILE" | sed '1d;$d')
if echo "$FRONTMATTER" | grep -q '^allowed-tools:'; then
    pass "frontmatter contains allowed-tools"
else
    fail "frontmatter missing allowed-tools"
fi
echo ""

# ── Test 3: must reference cr-start-round or cr-start-paper-round ──
echo "── Test 3: must reference cr-start-round ──"
if grep -qE 'cr-start-round|cr-start-paper-round' "$CMD_FILE"; then
    pass "References cr-start-round"
else
    fail "Missing cr-start-round reference"
fi
echo ""

# ── Test 4: must NOT reference cr-new-round --mode paper ──
echo "── Test 4: must NOT reference cr-new-round --mode paper ──"
# Exclude defensive warnings like "No calling cr-new-round --mode paper"
if grep -v '^\s*-\s*\*\*' "$CMD_FILE" | grep -v 'No calling' | grep -q 'cr-new-round.*paper'; then
    fail "Contains forbidden cr-new-round --mode paper reference"
else
    pass "No cr-new-round --mode paper reference"
fi
echo ""

# ── Test 5: must declare cr close-round before completion ──
echo "── Test 5: must declare cr close-round before completion ──"
if grep -q 'cr close-round' "$CMD_FILE"; then
    pass "References cr close-round"
else
    fail "Missing cr close-round reference"
fi

if grep -q 'must not stop until.*cr close-round' "$CMD_FILE" || \
   grep -q 'Do not summarize completion until.*cr close-round' "$CMD_FILE"; then
    pass "Explicitly forbids completion before cr close-round"
else
    fail "Missing 'must not complete before cr close-round' declaration"
fi
echo ""

# ── Test 6: must reference 8-stage workflow ──
echo "── Test 6: must reference 8-stage workflow ──"
if grep -q '8-stage' "$CMD_FILE"; then
    pass "References 8-stage workflow"
else
    fail "Missing 8-stage workflow reference"
fi
echo ""

# ── Test 7: must have description in frontmatter ──
echo "── Test 7: must have description in frontmatter ──"
if echo "$FRONTMATTER" | grep -q '^description:'; then
    pass "frontmatter contains description"
else
    fail "frontmatter missing description"
fi
echo ""

# ── Test 8: must have argument-hint in frontmatter ──
echo "── Test 8: must have argument-hint in frontmatter ──"
if echo "$FRONTMATTER" | grep -q '^argument-hint:'; then
    pass "frontmatter contains argument-hint"
else
    fail "frontmatter missing argument-hint"
fi
echo ""

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
