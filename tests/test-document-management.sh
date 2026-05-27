#!/usr/bin/env bash
# test-document-management.sh — Verify cr document add and list commands.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-doc-mgmt-XXXXXX)
cd "$TEST_DIR"

echo "══ Document Management Tests ══"
echo "Test dir: $TEST_DIR"
echo ""

cr workspace init > /dev/null 2>&1
cr start test-mgmt > /dev/null 2>&1

# ── Test 1: document list shows default paper ──
echo "── Test 1: document list shows default paper ──"
LIST_OUT=$(cr document list test-mgmt 2>&1 || true)
if echo "$LIST_OUT" | grep -q "paper"; then
    pass "Default paper document listed"
else
    fail "Default paper document not listed"
fi

# ── Test 2: document add proposal ──
echo ""
echo "── Test 2: document add proposal ──"
ADD_OUT=$(cr document add test-mgmt proposal 2>&1 || true)
if [ -f "test-mgmt/documents/proposal.md" ]; then
    pass "proposal.md created"
else
    fail "proposal.md not created"
fi

if echo "$ADD_OUT" | grep -q "registered"; then
    pass "Proposal registered in project"
else
    fail "Proposal not registered"
fi

# ── Test 3: document list shows proposal ──
echo ""
echo "── Test 3: document list shows proposal ──"
LIST_OUT=$(cr document list test-mgmt 2>&1 || true)
if echo "$LIST_OUT" | grep -q "proposal"; then
    pass "Proposal listed after add"
else
    fail "Proposal not listed"
fi

# ── Test 4: duplicate add rejected ──
echo ""
echo "── Test 4: duplicate add rejected ──"
DUP_OUT=$(cr document add test-mgmt proposal 2>&1 || true)
if echo "$DUP_OUT" | grep -qi "already exists"; then
    pass "Duplicate add rejected"
else
    fail "Duplicate add not rejected"
fi

# ── Test 5: unknown type rejected ──
echo ""
echo "── Test 5: unknown type rejected ──"
BAD_OUT=$(cr document add test-mgmt thesis 2>&1 || true)
if echo "$BAD_OUT" | grep -qi "unknown"; then
    pass "Unknown type rejected"
else
    fail "Unknown type not rejected"
fi

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo ""
echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
