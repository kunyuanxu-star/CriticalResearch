#!/usr/bin/env bash
# test-release-gate.sh — Final release gate. Only passes when ALL invariants hold.
# This test orchestrates other test suites. If any invariant test fails, the gate fails.
set -euo pipefail

FAILS=0
PASSES=0
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; PASSES=$((PASSES + 1)); }
fail() { echo -e "  ${RED}[FAIL]${NC} $1"; FAILS=$((FAILS + 1)); }
warn() { echo -e "  ${YELLOW}[WARN]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$SCRIPT_DIR/../scripts:$PATH"
export CR_SKILL_HOME="$SCRIPT_DIR/.."

echo "══ CriticalResearch Release Gate ══"
echo ""
echo "Inv0: /critical-cs-research has UserPromptExpansion gate"
echo "Inv1: phase can only advance via cr step advance"
echo "Inv2: phase complete requires scoped run-log proof"
echo "Inv3: M0-M7 review checkpoint blocks next module"
echo "Inv4: Stop hook blocks incomplete / tampered round"
echo "Inv5: close_round is the 37th formal phase"
echo ""

# Helper: run a test suite and report.
run_suite() {
    local name="$1"
    local file="$2"
    local safe_name
    safe_name=$(echo "$name" | tr ' ' '_')
    echo "── $name ──"
    if bash "$file" > "/tmp/cr-gate-$safe_name.out" 2>&1; then
        pass "$name"
        return 0
    else
        fail "$name"
        tail -20 "/tmp/cr-gate-$safe_name.out" | sed 's/^/    /'
        return 1
    fi
}

# Contract tests.
run_suite "Hook contract"           "$SCRIPT_DIR/test-hook-contract.sh"
run_suite "Slash command contract"  "$SCRIPT_DIR/test-slash-command-contract.sh"
run_suite "UserPromptExpansion hook" "$SCRIPT_DIR/test-user-prompt-expansion-hook.sh"
run_suite "ConfigChange blocks removal" "$SCRIPT_DIR/test-config-change-blocks-hook-removal.sh"
echo ""

# Proof tests.
run_suite "Phase-run-log required IO" "$SCRIPT_DIR/test-phase-run-log-required-io.sh"
run_suite "Scoped run-log IO"         "$SCRIPT_DIR/test-scoped-run-log-io.sh"
run_suite "No bare hash key"          "$SCRIPT_DIR/test-no-bare-hash-key.sh"
run_suite "Directory hash proof"      "$SCRIPT_DIR/test-directory-hash-proof.sh"
run_suite "State tamper rejected"     "$SCRIPT_DIR/test-state-tamper-rejected.sh"
run_suite "Stop gate run-log mismatch" "$SCRIPT_DIR/test-stop-gate-run-log-mismatch.sh"
echo ""

# Workflow tests.
run_suite "37-phase state-machine happy path" "$SCRIPT_DIR/test-37-phase-state-machine-happy-path.sh"
run_suite "Module checkpoint"     "$SCRIPT_DIR/test-module-checkpoint.sh"
run_suite "Module review gate"    "$SCRIPT_DIR/test-module-review-gate.sh"
run_suite "Close-round protocol"  "$SCRIPT_DIR/test-close-round-protocol.sh"
run_suite "Full round enforcement" "$SCRIPT_DIR/test-full-round-enforcement.sh"
run_suite "Structural vs semantic review" "$SCRIPT_DIR/test-review-structural-vs-semantic.sh"
echo ""

# Summary.
echo "═══════════════════════════════════════════════════════"
if [ "$FAILS" -eq 0 ]; then
    echo -e "${GREEN}RELEASE GATE PASSED${NC}: $PASSES/$PASSES invariant tests passed."
    echo "Workflow is stable and ready for real use."
    exit 0
else
    echo -e "${RED}RELEASE GATE FAILED${NC}: $FAILS of $((PASSES + FAILS)) invariant tests failed."
    echo "Do not use this workflow for real rounds until all tests pass."
    exit 2
fi
