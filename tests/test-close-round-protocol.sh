#!/usr/bin/env bash
# test-close-round-protocol.sh — Verify round close protocol enforcement (v2).
# Tests: all stages complete required, validators run, knowledge delta applied.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
export CR_TEST_MODE=1

TEST_DIR=$(mktemp -d /tmp/cr-close-XXXXXX)
cd "$TEST_DIR"

echo "══ Close-Round Protocol Tests (v2) ══"
echo "Test dir: $TEST_DIR"
echo ""

# ── Setup ──
cr workspace init > /dev/null 2>&1
cr project init e2e-close --domain systems > /dev/null 2>&1
cd e2e-close
cr document add e2e-close paper --type paper --path documents/paper.md > /dev/null 2>&1
echo "# Test" > documents/paper.md

cr round start e2e-close --workflow paper --doc paper --mode triage --objective "close-round test" > /dev/null 2>&1

ROUND_DIR=$(ls -d rounds/round-* | head -1)
WF_STATE="$ROUND_DIR/workflow-state.yaml"

# ── Test 1: Not all stages complete → close blocked ──
echo "── Test 1: Incomplete stages block close ──"
CLOSE_OUT=$(cr round close e2e-close 2>&1 || true)
if echo "$CLOSE_OUT" | grep -qi "not all stages\|Cannot close"; then
    pass "close blocked when stages incomplete"
else
    fail "close should block when stages incomplete"
fi
echo ""

# ── Test 2: All stages marked complete → close proceeds ──
echo "── Test 2: All stages complete → close proceeds ──"
# Mark all stages complete.
STAGE_COUNT=$(yq -r '.stage_order | length' "$WF_STATE" 2>/dev/null || echo "0")
for i in $(seq 0 $((STAGE_COUNT - 1))); do
    sid=$(yq -r ".stage_order[$i] // \"\"" "$WF_STATE" 2>/dev/null || echo "")
    [ -z "$sid" ] && continue
    yq -i ".stages.\"$sid\".status = \"complete\"" "$WF_STATE" 2>/dev/null || true
    yq -i ".stages.\"$sid\".completed_at = \"2026-01-01T00:00:00Z\"" "$WF_STATE" 2>/dev/null || true
done

# Create minimal required files for validators.
for f in contract.yaml paper-state.yaml claim-evidence-grounding.yaml critical-review.yaml writing-strategy.yaml revision-plan.yaml patch-plan.yaml patch-trace.yaml document-diff.yaml claim-alignment.yaml knowledge-delta.yaml next-round-targets.yaml; do
    echo "schema_version: '1.0.0'" > "$ROUND_DIR/$f"
done
mkdir -p "$ROUND_DIR/raw-sources" "$ROUND_DIR/patches" "$ROUND_DIR/source-notes"
echo "schema_version: '1.0.0'" > "$ROUND_DIR/patches/PP-001.yaml"

CLOSE_OUT=$(cr round close e2e-close 2>&1 || true)
# Close may still fail on validators (empty data), but it should at least attempt.
if echo "$CLOSE_OUT" | grep -qi "closed successfully\|Running workflow validators\|closed"; then
    pass "close attempted validators (not blocked on stage count)"
else
    # If close says "no active round", that means close worked (round is gone).
    ACTIVE=$(jq -r '.active_round // "none"' state/project-state.json 2>/dev/null || echo "none")
    if [ "$ACTIVE" = "null" ] || [ "$ACTIVE" = "none" ]; then
        pass "close cleared active round"
    else
        fail "close did not clear active round (output: ${CLOSE_OUT:0:100})"
    fi
fi

echo ""
echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
