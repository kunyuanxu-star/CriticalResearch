#!/usr/bin/env bash
# test-workflow-state-materializes-contracts.sh — Verify cr round start
# materializes required_outputs/depends_on from workflow stage_contracts into
# workflow-state.yaml.
set -euo pipefail

FAILS=0; PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'
pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."
export CR_TEST_MODE=1

TEST_DIR=$(mktemp -d /tmp/cr-contracts-XXXXXX)
trap "rm -rf $TEST_DIR" EXIT
cd "$TEST_DIR"

echo "══ Workflow State Materializes Contracts Test ══"
echo ""

cr workspace init > /dev/null 2>&1
cr project init ctest --domain systems > /dev/null 2>&1
cd ctest
cr document add ctest paper --type paper --path documents/paper.md > /dev/null 2>&1
echo "# Test Paper" > documents/paper.md

cr round start ctest --workflow paper --doc paper --mode triage --objective "materialization test" > /dev/null 2>&1

ROUND_DIR=$(ls -d rounds/round-* | head -1)
WF_STATE="$ROUND_DIR/workflow-state.yaml"

echo "── Checking materialized fields ──"

# 1. required_outputs materialized
RO=$(yq -r '.stages.contract.required_outputs | length' "$WF_STATE" 2>/dev/null || echo "0")
if [ "${RO:-0}" -ge 1 ]; then
    pass "contract stage has required_outputs ($RO items)"
else
    fail "contract stage missing required_outputs"
fi

# 2. required_inputs materialized
RI=$(yq -r '.stages.contract.required_inputs | length' "$WF_STATE" 2>/dev/null || echo "0")
if [ "${RI:-0}" -ge 1 ]; then
    pass "contract stage has required_inputs ($RI items)"
else
    fail "contract stage missing required_inputs"
fi

# 3. allowed_write_scopes materialized
AW=$(yq -r '.stages.contract.allowed_write_scopes | length' "$WF_STATE" 2>/dev/null || echo "0")
if [ "${AW:-0}" -ge 1 ]; then
    pass "contract stage has allowed_write_scopes ($AW items)"
else
    fail "contract stage missing allowed_write_scopes"
fi

# 4. depends_on: first stage has no deps
DO=$(yq -r '.stages.contract.depends_on | length' "$WF_STATE" 2>/dev/null || echo "0")
if [ "${DO:-0}" -eq 0 ]; then
    pass "contract stage depends_on is empty (first stage)"
else
    fail "contract stage depends_on should be empty (got $DO)"
fi

# 5. Second stage (paper_state) depends on contract
DO2=$(yq -r '.stages.paper_state.depends_on | length' "$WF_STATE" 2>/dev/null || echo "0")
if [ "${DO2:-0}" -ge 1 ]; then
    DEP_VAL=$(yq -r '.stages.paper_state.depends_on[0]' "$WF_STATE" 2>/dev/null || echo "")
    if [ "$DEP_VAL" = "contract" ]; then
        pass "paper_state depends_on contract"
    else
        fail "paper_state depends_on '$DEP_VAL' (expected contract)"
    fi
else
    fail "paper_state stage missing depends_on"
fi

# 6. forbidden_actions field exists (even if empty)
FA=$(yq -r '.stages.contract.forbidden_actions // "missing"' "$WF_STATE" 2>/dev/null || echo "missing")
if [ "$FA" != "missing" ]; then
    pass "contract stage has forbidden_actions field"
else
    fail "contract stage missing forbidden_actions field"
fi

# 7. completion_predicate field exists
if yq -e '.stages.contract | has("completion_predicate")' "$WF_STATE" > /dev/null 2>&1; then
    pass "contract stage has completion_predicate field"
else
    fail "contract stage missing completion_predicate field"
fi

echo ""
echo "══ Results: $PASSES passed, $FAILS failed ══"
[ "$FAILS" -eq 0 ] && exit 0 || exit 2
