#!/usr/bin/env bash
# test-no-legacy-paper-mode.sh — Verify NO legacy paper-centric terms or files exist.
# CRITICAL verification gate for CriticalResearch v2.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_HOME="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS=0
FAIL=0

check_term() {
    local label="$1" pattern="$2" file="$3"
    if grep -qi "$pattern" "$file" 2>/dev/null; then
        echo "  FAIL: $label found in $file"
        FAIL=$((FAIL + 1))
    else
        echo "  PASS: $label absent from $file"
        PASS=$((PASS + 1))
    fi
}

check_no_file() {
    local file="$1" reason="$2"
    if [ -e "$SKILL_HOME/$file" ]; then
        echo "  FAIL: $file still exists — $reason"
        FAIL=$((FAIL + 1))
    else
        echo "  PASS: $file removed — $reason"
        PASS=$((PASS + 1))
    fi
}

echo "=== test-no-legacy-paper-mode.sh ==="
echo "Verifying legacy paper-centric terms and files are removed."
echo ""

# ── SKILL.md checks ──
echo "── SKILL.md ──"
check_term "full-paper transaction system" "full-paper transaction system" "$SKILL_HOME/SKILL.md"
check_term "8-stage paper round" "8-stage paper round" "$SKILL_HOME/SKILL.md"
check_term "weighting lens, not a scope limiter" "weighting lens, not a scope limiter" "$SKILL_HOME/SKILL.md"
check_term "Every round must improve the paper" "every round must improve the paper" "$SKILL_HOME/SKILL.md"
check_term "objective_may_limit_scope" "objective_may_limit_scope" "$SKILL_HOME/SKILL.md"
check_term "Paper mode is the primary workflow" "paper mode is the primary workflow" "$SKILL_HOME/SKILL.md"

# ── Slash command checks ──
echo "── Slash Command ──"
SLASH_CMD="$SKILL_HOME/commands/critical-cs-research.md"
check_term "8-stage paper research round" "8-stage paper research round" "$SLASH_CMD"
check_term "must execute all 8 stages" "must execute all 8 stages" "$SLASH_CMD"
check_term "full_paper_required" "full_paper_required" "$SLASH_CMD"

# ── README checks ──
echo "── README ──"
check_term "mandatory full-paper" "mandatory full-paper" "$SKILL_HOME/README.md"
check_term "Paper mode is the primary workflow" "paper mode is the primary workflow" "$SKILL_HOME/README.md"
check_term "enforced 8-stage state machine" "enforced 8-stage state machine" "$SKILL_HOME/README.md"
check_term "37-phase" "37-phase" "$SKILL_HOME/README.md"

# ── File existence checks ──
echo "── Deleted Files ──"
check_no_file "scripts/cr-start-paper-round" "legacy paper alias"
check_no_file "workflow/stage-manifest.yaml" "old 8-stage manifest"
check_no_file "workflow/universal-paper-round.md" "paper-centered round guide"
check_no_file "templates/round-state.yaml" "8-stage state template"
check_no_file "schemas/paper-state.schema.json" "paper-specific state schema"
check_no_file "schemas/paper_patch.schema.json" "universal paper patch schema"
check_no_file "schemas/round-state.schema.json" "old round state schema"
check_no_file "scripts/cr-start-round" "legacy round start"
check_no_file "scripts/cr-new-round" "legacy new round"
check_no_file "scripts/cr-generate-paper-patches" "legacy paper patch generator"
check_no_file "scripts/cr-apply-paper-patch" "legacy paper patch applier"
check_no_file "scripts/cr-migrate-to-paper-mode" "legacy migration tool"

# ── Workflow files exist ──
echo "── New Structure ──"
for wf in survey design paper proposal experiment; do
    if [ -f "$SKILL_HOME/workflows/$wf/workflow.yaml" ]; then
        echo "  PASS: workflows/$wf/workflow.yaml exists"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: workflows/$wf/workflow.yaml missing"
        FAIL=$((FAIL + 1))
    fi
done

# Check engine/ structure exists
for d in engine/validators engine/core; do
    if [ -d "$SKILL_HOME/$d" ]; then
        echo "  PASS: $d exists"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $d missing"
        FAIL=$((FAIL + 1))
    fi
done

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
exit 0
