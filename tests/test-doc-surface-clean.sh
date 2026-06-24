#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

passes=0
fails=0
pass() { echo "PASS $1"; passes=$((passes + 1)); }
fail() { echo "FAIL $1"; fails=$((fails + 1)); }

TARGETS=(
    README.md
    SKILL.md
    CLAUDE.md
    commands
    .claude/commands
    templates
    references
    install.sh
    schemas
)

VERSION_PATTERN="v""3|V""3|3\\.0\\.0|engine/""v""3|test-""v""3|CriticalResearch ""v""3|criticalresearch ""v""3"
OLD_MODEL_PATTERN='\bround\b|\bstage\b|workflow-state|stage-state|round close|cr round|cr stage|cr document|cr unit|document registry|unit registry|knowledge-delta|paper_patch|experiment_obligation|paper-draft|claim ledger|evidence ledger|critique ledger|final report|Research Trace|rounds/'

if rg -n --hidden "$VERSION_PATTERN" "${TARGETS[@]}" -g '!*.pyc' -g '!__pycache__/**' >/tmp/cr-doc-version-surface.out; then
    cat /tmp/cr-doc-version-surface.out
    fail "public docs hide internal version label"
else
    pass "public docs hide internal version label"
fi

if rg -n --hidden "$OLD_MODEL_PATTERN" "${TARGETS[@]}" -g '!*.pyc' -g '!__pycache__/**' >/tmp/cr-doc-old-model-surface.out; then
    cat /tmp/cr-doc-old-model-surface.out
    fail "public docs avoid removed process model"
else
    pass "public docs avoid removed process model"
fi

echo "RESULT $passes passed, $fails failed"
[ "$fails" -eq 0 ]
