#!/usr/bin/env bash
# test-directory-hash-proof.sh — Verify directory hash includes relative paths.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
TEST_DIR=$(mktemp -d /tmp/cr-dirhash-XXXXXX)

echo "══ Directory Hash Proof Tests ══"
echo ""

# Setup a fake project/round.
mkdir -p "$TEST_DIR/proj/round"

# ── Test 1: same content, different file names -> different hashes ──
echo "── Test 1: file rename changes directory hash ──"
mkdir -p "$TEST_DIR/proj/round/dir1" "$TEST_DIR/proj/round/dir2"
echo "same content" > "$TEST_DIR/proj/round/dir1/file-a.txt"
echo "same content" > "$TEST_DIR/proj/round/dir2/file-b.txt"

H1=$(cr-hash-artifact "$TEST_DIR/proj" "$TEST_DIR/proj/round" "round:dir1" 2>/dev/null || echo "")
H2=$(cr-hash-artifact "$TEST_DIR/proj" "$TEST_DIR/proj/round" "round:dir2" 2>/dev/null || echo "")

if [ -n "$H1" ] && [ -n "$H2" ] && [ "$H1" != "$H2" ]; then
    pass "Directory hash changes when file is renamed"
else
    fail "Directory hash did not change on rename (H1=$H1 H2=$H2)"
fi
echo ""

# ── Test 2: same content, same name -> identical hashes ──
echo "── Test 2: identical directories produce identical hashes ──"
mkdir -p "$TEST_DIR/proj/round/dir3" "$TEST_DIR/proj/round/dir4"
echo "same content" > "$TEST_DIR/proj/round/dir3/x.txt"
echo "same content" > "$TEST_DIR/proj/round/dir4/x.txt"

H3=$(cr-hash-artifact "$TEST_DIR/proj" "$TEST_DIR/proj/round" "round:dir3" 2>/dev/null || echo "")
H4=$(cr-hash-artifact "$TEST_DIR/proj" "$TEST_DIR/proj/round" "round:dir4" 2>/dev/null || echo "")

if [ "$H3" = "$H4" ] && [ -n "$H3" ]; then
    pass "Identical directories have identical hashes"
else
    fail "Identical directories have different hashes (H3=$H3 H4=$H4)"
fi
echo ""

# ── Test 3: file moved to subdirectory changes hash ──
echo "── Test 3: file move to subdirectory changes directory hash ──"
mkdir -p "$TEST_DIR/proj/round/dir5" "$TEST_DIR/proj/round/dir6/sub"
echo "content" > "$TEST_DIR/proj/round/dir5/top.txt"
echo "content" > "$TEST_DIR/proj/round/dir6/sub/top.txt"

H5=$(cr-hash-artifact "$TEST_DIR/proj" "$TEST_DIR/proj/round" "round:dir5" 2>/dev/null || echo "")
H6=$(cr-hash-artifact "$TEST_DIR/proj" "$TEST_DIR/proj/round" "round:dir6" 2>/dev/null || echo "")

if [ -n "$H5" ] && [ -n "$H6" ] && [ "$H5" != "$H6" ]; then
    pass "Directory hash changes when file moves to subdirectory"
else
    fail "Directory hash did not change on move (H5=$H5 H6=$H6)"
fi
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
