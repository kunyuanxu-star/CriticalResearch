#!/usr/bin/env bash
# test-module-review-gate.sh — Verify module review checkpoint blocks advance.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
TEST_DIR=$(mktemp -d /tmp/cr-mod-XXXXXX)
cd "$TEST_DIR"

echo "══ Module Review Gate Tests ══"
echo "Test dir: $TEST_DIR"
echo ""

cr workspace init > /dev/null 2>&1
cr start e2e-mod > /dev/null 2>&1
jq '.active_round = null' e2e-mod/state/project-state.json > e2e-mod/state/project-state.json.tmp && \
    mv e2e-mod/state/project-state.json.tmp e2e-mod/state/project-state.json

echo "# test paper" > e2e-mod/writing/paper-draft.md
echo "schema_version: \"1.0.0\"" > e2e-mod/state/claim-ledger.yaml

cr-start-paper-round e2e-mod "test module review" > /dev/null 2>&1
ROUND_DIR="e2e-mod/rounds/round-002"

# Create minimal artifacts for M0 phases so cr-review-module can generate pass.
for f in paper-state.yaml loaded-knowledge.yaml round-objective.yaml full-paper-coverage-plan.yaml; do
    echo "schema_version: \"1.0.0\"" > "$ROUND_DIR/$f"
done

# Helper: check if a phase is blocked.
is_blocked() {
    local phase="$1"
    local status
    status=$(yq -r ".phases.\"$phase\".status // \"\"" "$ROUND_DIR/state.yaml" 2>/dev/null || echo "")
    [ "$status" = "blocked" ]
}

# ── Test 1: M0 last phase complete without review → next module blocked ──
echo "── Test 1: M0 ends at phase 4, no M0-review → M1 blocked ──"
# Mark phases 1-4 complete directly (bypass validator for test speed).
for p in snapshot_paper_state load_project_knowledge define_round_objective freeze_full_paper_coverage; do
    yq -i ".phases.\"$p\".status = \"complete\"" "$ROUND_DIR/state.yaml" 2>/dev/null || true
    yq -i ".phases.\"$p\".completed_at = \"2026-01-01T00:00:00Z\"" "$ROUND_DIR/state.yaml" 2>/dev/null || true
done
yq -i ".current_phase = \"freeze_full_paper_coverage\"" "$ROUND_DIR/state.yaml" 2>/dev/null || true

# Call cr-complete-phase on already-complete phase 4 — review missing → exit 0 without unblock.
cr-complete-phase "$TEST_DIR/e2e-mod" "$ROUND_DIR" freeze_full_paper_coverage > /dev/null 2>&1 || true

if is_blocked "plan_research_questions"; then
    pass "M1 first phase (plan_research_questions) is blocked without M0-review"
else
    fail "M1 first phase is NOT blocked"
fi
echo ""

# ── Test 2: Generate M0-review status=pass → M1 unblocks ──
echo "── Test 2: M0-review.yaml status=pass → M1 unblocks ──"
cr-review-module "$TEST_DIR/e2e-mod" "$ROUND_DIR" M0 > /dev/null 2>&1 || true

# Re-run cr-complete-phase on already-complete phase 4 — review passes → unblock.
cr-complete-phase "$TEST_DIR/e2e-mod" "$ROUND_DIR" freeze_full_paper_coverage > /dev/null 2>&1 || true

if ! is_blocked "plan_research_questions"; then
    pass "M1 first phase is unblocked after M0-review pass"
else
    fail "M1 first phase is still blocked after M0-review"
fi
echo ""

# ── Test 3: M0-review status=block (with blocking_findings) → M1 blocked ──
echo "── Test 3: M0-review with blocking_findings → M1 blocked ──"
# Reset: block plan_research_questions again.
yq -i ".phases.plan_research_questions.status = \"blocked\"" "$ROUND_DIR/state.yaml" 2>/dev/null || true
# Corrupt M0-review with blocking findings.
cat > "$ROUND_DIR/phase-reviews/M0-review.yaml" << 'BAD'
schema_version: "1.0.0"
module: M0
status: pass
blocking_findings:
  - finding_id: F001
    description: "Test blocking finding"
BAD

# Re-run complete-phase for M0 last phase.
cr-complete-phase "$TEST_DIR/e2e-mod" "$ROUND_DIR" freeze_full_paper_coverage > /dev/null 2>&1 || true

if is_blocked "plan_research_questions"; then
    pass "M1 blocked when M0-review has blocking_findings"
else
    fail "M1 NOT blocked despite blocking_findings"
fi
echo ""

# ── Cleanup ──
rm -rf "$TEST_DIR"

echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
