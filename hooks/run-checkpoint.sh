#!/usr/bin/env bash
# Checkpoint runner — called explicitly by the agent at each workflow stage.
# Usage: run-checkpoint.sh <pass1|pass2|rebuttal|convergence|all>
set -euo pipefail

STAGE="${1:-all}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

case "$STAGE" in
    pass1|a|b|A|B)
        exec "$SCRIPT_DIR/check-pass1.sh"
        ;;
    pass2|c|C)
        exec "$SCRIPT_DIR/check-pass2.sh"
        ;;
    rebuttal|d|D)
        exec "$SCRIPT_DIR/check-rebuttal.sh"
        ;;
    convergence|final|gate)
        exec "$SCRIPT_DIR/check-convergence.sh"
        ;;
    all)
        exec "$SCRIPT_DIR/check-all.sh"
        ;;
    *)
        echo "Usage: run-checkpoint.sh <pass1|pass2|rebuttal|convergence|all>"
        echo ""
        echo "  pass1        Checkpoints A+B (Problem Framing + Claim Decomposition)"
        echo "  pass2        Checkpoint C   (Evidence + Critique + Gap Backlog)"
        echo "  rebuttal     Checkpoint D   (Rebuttal Phase)"
        echo "  convergence  User Satisfaction Gate (Internal quality bar + Logic + Story)"
        echo "  all          Run all applicable checks based on existing files"
        exit 1
        ;;
esac
