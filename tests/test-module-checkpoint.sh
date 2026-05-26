#!/usr/bin/env bash
# test-module-checkpoint.sh — Verify module checkpoint blocks when review is missing.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-module-check-XXXXXX)
cd "$TEST_DIR"

echo "══ Module Checkpoint Tests ══"
echo "Test dir: $TEST_DIR"
echo ""

# ── Setup ──
cr workspace init > /dev/null 2>&1
cr start e2e-check > /dev/null 2>&1
jq '.active_round = null' e2e-check/state/project-state.json > e2e-check/state/project-state.json.tmp && \
    mv e2e-check/state/project-state.json.tmp e2e-check/state/project-state.json

mkdir -p e2e-check/writing e2e-check/state
echo "# test paper" > e2e-check/writing/paper-draft.md
echo "schema_version: \"1.0.0\"" > e2e-check/state/claim-ledger.yaml

cr-start-paper-round e2e-check "test module checkpoint" > /dev/null 2>&1
ROUND_DIR="e2e-check/rounds/round-002"
mkdir -p "$ROUND_DIR/_cr/knowledge"

# Create phase 1 artifacts.
echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/paper-state.yaml"
echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/round-objective.yaml"

# ── Test 1: no completed modules → checkpoint passes ──
echo "── Test 1: no completed modules → checkpoint passes ──"
if cr-validate-module-checkpoint "$TEST_DIR/e2e-check" "$ROUND_DIR" > /tmp/mc1.out 2>&1; then
    pass "Checkpoint passes when no modules complete"
else
    fail "Checkpoint should pass with no completed modules"
    cat /tmp/mc1.out
fi
echo ""

# ── Test 2: M0 boundary phase complete, review missing → fail ──
echo "── Test 2: M0 complete, review missing → checkpoint fails ──"
# Mark freeze_full_paper_coverage (M0 boundary) as complete.
yq -i '.phases.freeze_full_paper_coverage.status = "complete"' "$ROUND_DIR/state.yaml" 2>/dev/null || true

if cr-validate-module-checkpoint "$TEST_DIR/e2e-check" "$ROUND_DIR" > /tmp/mc2.out 2>&1; then
    fail "Checkpoint should fail when M0 review is missing"
else
    if grep -q "Module M0 review missing" /tmp/mc2.out; then
        pass "Checkpoint detects missing M0 review"
    else
        fail "Wrong error message"
        cat /tmp/mc2.out
    fi
fi
echo ""

# ── Test 3: M0 review exists but status=pending → fail ──
echo "── Test 3: M0 review pending → checkpoint fails ──"
mkdir -p "$ROUND_DIR/phase-reviews"
cat > "$ROUND_DIR/phase-reviews/M0-review.yaml" << 'RV'
schema_version: "1.0.0"
module: M0
status: pending
blocking_findings: []
minor_findings: []
RV

if cr-validate-module-checkpoint "$TEST_DIR/e2e-check" "$ROUND_DIR" > /tmp/mc3.out 2>&1; then
    fail "Checkpoint should fail when M0 review is pending"
else
    if grep -q "Module M0 review status='pending'" /tmp/mc3.out; then
        pass "Checkpoint detects pending M0 review"
    else
        fail "Wrong error message"
        cat /tmp/mc3.out
    fi
fi
echo ""

# ── Test 4: M0 review status=pass, blocking findings > 0 → fail ──
echo "── Test 4: M0 review pass but blocking findings → checkpoint fails ──"
cat > "$ROUND_DIR/phase-reviews/M0-review.yaml" << 'RV2'
schema_version: "1.0.0"
module: M0
status: pass
blocking_findings:
  - "Missing evidence chain"
minor_findings: []
RV2

if cr-validate-module-checkpoint "$TEST_DIR/e2e-check" "$ROUND_DIR" > /tmp/mc4.out 2>&1; then
    fail "Checkpoint should fail when M0 review has blocking findings"
else
    if grep -q "Module M0 review has 1 blocking finding" /tmp/mc4.out; then
        pass "Checkpoint detects blocking findings in M0 review"
    else
        fail "Wrong error message"
        cat /tmp/mc4.out
    fi
fi
echo ""

# ── Test 5: M0 review status=pass, zero blocking → pass ──
echo "── Test 5: M0 review pass, zero blocking → checkpoint passes ──"
cat > "$ROUND_DIR/phase-reviews/M0-review.yaml" << 'RV3'
schema_version: "1.0.0"
module: M0
status: pass
blocking_findings: []
minor_findings: []
RV3

if cr-validate-module-checkpoint "$TEST_DIR/e2e-check" "$ROUND_DIR" > /tmp/mc5.out 2>&1; then
    pass "Checkpoint passes when M0 review is clean"
else
    fail "Checkpoint should pass with clean M0 review"
    cat /tmp/mc5.out
fi
echo ""

# ── Test 6: Stop gate calls checkpoint and returns JSON block ──
echo "── Test 6: Stop gate blocks with JSON when checkpoint fails ──"
# Set current_phase to freeze_full_paper_coverage and mark it complete.
# This ensures the "current phase incomplete" check passes, allowing
# the module checkpoint check to run.
yq -i '.current_phase = "freeze_full_paper_coverage"' "$ROUND_DIR/state.yaml" 2>/dev/null || true

# Remove M0 review to make checkpoint fail.
rm -f "$ROUND_DIR/phase-reviews/M0-review.yaml"

OUTPUT=$(cr-stop-gate "$TEST_DIR/e2e-check" 2>/dev/null || true)
if echo "$OUTPUT" | grep -q '"decision":"block"'; then
    if echo "$OUTPUT" | grep -q "M0 review is required"; then
        pass "Stop gate returns JSON block for missing M0 review"
    else
        fail "Stop gate JSON missing expected reason"
        echo "$OUTPUT"
    fi
else
    fail "Stop gate should return decision:block"
    echo "$OUTPUT"
fi
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
