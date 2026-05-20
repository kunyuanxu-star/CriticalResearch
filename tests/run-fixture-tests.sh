#!/usr/bin/env bash
# Fixture-based regression tests for CriticalResearch validators.
# Run with: bash tests/run-fixture-tests.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/scripts/cr-common.sh"

PASSES=0
FAILURES=0

run_test() {
    local name="$1"
    shift
    echo -n "  $name ... "
    if "$@" >/dev/null 2>&1; then
        echo "PASS"
        PASSES=$((PASSES + 1))
    else
        echo "FAIL"
        FAILURES=$((FAILURES + 1))
    fi
}

echo "══ Fixture Regression Tests ══"
echo ""

# Schema validation tests.
echo "── Schema Validation ──"

run_test "Valid round.yaml" \
    cr_validate_schema "$SCRIPT_DIR/fixtures/valid-round.yaml" "$PROJECT_ROOT/schemas/round.schema.json" yaml

run_test "Valid paper patch" \
    cr_validate_schema "$SCRIPT_DIR/fixtures/valid-patch.yaml" "$PROJECT_ROOT/schemas/paper_patch.schema.json" yaml

# Invalid data rejection tests.
echo ""
echo "── Invalid Data Rejection ──"

TMP=$(mktemp)
echo '{"round_id":"not_a_number","project_id":"test","status":"open","started_at":"2026-01-01T00:00:00Z","required_outputs":["report"],"schema_version":"1.0.0"}' > "$TMP"
run_test "Rejects string round_id" \
    bash -c "source '$PROJECT_ROOT/scripts/cr-common.sh' && ! cr_validate_schema '$TMP' '$PROJECT_ROOT/schemas/round.schema.json'"
rm -f "$TMP"

TMP2=$(mktemp)
echo '{"patch_id":"PP-001","linked_critique":"CRT-001","linked_round":"round-001","severity":"high","patch_type":["weaken_claim"],"affected_anchors":["abstract"],"proposed_change":{"before":"x","after":"y","rationale":"z"},"lifecycle_status":"proposed"}' > "$TMP2"
run_test "Rejects patch without knowledge_implication" \
    bash -c "source '$PROJECT_ROOT/scripts/cr-common.sh' && ! cr_validate_schema '$TMP2' '$PROJECT_ROOT/schemas/paper_patch.schema.json'"
rm -f "$TMP2"

echo ""
echo "══ Results: $PASSES passed, $FAILURES failed ══"
[ "$FAILURES" -eq 0 ] && exit 0 || exit 1
