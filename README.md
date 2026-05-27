# CriticalResearch

A domain-general, computer-science-specific critical research loop as a Claude Code skill with an **enforced 8-stage state machine**. It decomposes claims, grounds evidence in real external search, finds counterexamples, generates research gaps, produces paper patches with experiment obligations, distills reusable knowledge, and produces evidence-backed conclusions — looping indefinitely until all stages are complete and validators pass.

Covers: OS, networking, security, databases, PL/compilers, architecture, AI infrastructure, distributed systems, software engineering, HCI/CSCW, and technical systems work.

## Installation

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (CLI or IDE extension)
- Git
- Bash (macOS / Linux)
- jq (brew/apt install jq)
- yq (brew/apt install yq) — required for paper mode

### Quick Install

```bash
git clone https://github.com/Plucky923/CriticalResearch.git
cd CriticalResearch
bash install.sh

# Then initialize your research workspace:
cd ~/Research
cr workspace init
cr start my-topic
```

The installer:
- Copies the skill to `~/.claude/skills/critical-cs-research/`
- Checks dependencies (jq, yq, git, bash)
- Adds `cr` CLI to your PATH
- Exports `CR_SKILL_HOME` for hook path resolution

### Manual Install

```bash
git clone https://github.com/Plucky923/CriticalResearch.git ~/.claude/skills/critical-cs-research
export PATH="$HOME/.claude/skills/critical-cs-research/scripts:$PATH"
```

## Usage

### Within Claude Code

Start a conversation with Claude Code and the skill activates automatically when you ask about CS research tasks. The Stop hook prevents the session from ending until the current stage's required outputs are complete. Examples:

- "Validate this idea for a new caching algorithm"
- "Review my system design for a distributed key-value store"
- "Critique the related work section of my paper on fuzzing"

### CLI (standalone)

```bash
# Project lifecycle
cr workspace init                # Initialize a Research workspace
cr start my-topic                # Create a new research project
cr continue                      # Show next-round task prompt
cr status                        # Show workspace and project status

# Full-Round Execution (Claude Code)
/critical-cs-research <objective>  # Start mandatory full-paper 8-stage transaction
                                   # The objective is a weighting lens, not a scope limiter.
                                   # Cannot stop until round closes or hard blocker recorded.

# Round lifecycle (CLI)
cr round my-topic --mode paper   # Open a new paper-mode round (8-stage strict state machine)
cr step my-topic status          # Show current stage and missing outputs
cr step my-topic advance         # Validate current stage and advance to next
cr step my-topic validate        # Validate current stage without advancing
cr close-round my-topic          # Validate and close the active round
cr validate my-topic             # Run all project invariant checks

# Automated stage runner (validates and advances, does not generate artifacts)
cr run-round my-topic            # Advance through all 8 stages (validates only)
```

## Workflow Modes

| Mode | Use Case | Claims | Evidence | Can Close Round? |
|---|---|---|---|---|
| **Triage** | Quick screening, idea feasibility | ≤3 | Internal knowledge only | No — triage only |
| **Standard** | Regular research, design review | 4–10 | 1 search pass required | Yes |
| **Deep** | Journal-grade review, full rebuttal | >10 | Deep search + concurrent | Yes |
| **Paper** | Full paper round: 8-stage strict state machine | Any | Deep search + raw sources + evidence ledger + weakening evidence | Yes — requires all stages complete |

**Paper mode** is the only executable paper workflow. It uses an 8-stage strict state machine:

S1 Round Contract → S2 Evidence Grounding → S3 Critical Review → S4 Revision Strategy → S5 Writing Strategy → S6 Paper Patch → S7 Knowledge Consolidation → S8 Round Closure

A paper round is a controlled paper transaction: round contract → evidence grounding → critical review → revision strategy → writing strategy → paper patch → knowledge consolidation → round closure.

Paper mode enforces: ≥5 search queries across 5 mandatory query classes, ≥5 raw source snapshots with sha256 hashes, ≥5 normalized evidence items, ≥2 S/A-level evidence, ≥1 weakening or contradicting evidence, no skipped stages, no pending human decisions, and full transaction-chain integrity.

`cr run-round` validates and advances stages; it does not generate artifacts. The agent/user must create required outputs for each stage.

## Project Structure

```
├── SKILL.md              # Skill definition (Claude Code entry point — thin)
├── scripts/              # CLI tools (cr, step, research, validators, guards)
├── hooks/                # Stop/PreToolUse/PostToolUse hooks for enforcement
├── templates/            # Domain-neutral artifact templates
├── schemas/              # JSON schemas for all artifacts + artifact registry
├── references/           # Domain profiles, evidence standards, role lenses
├── workflow/             # Universal paper round execution guide
└── agents/               # Sub-agent instruction sets
```

## Multi-Project Parallelism

CriticalResearch supports multiple research projects in one workspace. Each session is bound to a single project via session scope, enforced by hooks:

```
cr scope open --project my-topic     # Bind this session to my-topic
cr scope status                      # Show current scope
cr scope close                       # Release scope
```

Hooks prevent writes to other projects, workspace root artifacts, `_cr` metadata, and protected state files. Git mutation commands (commit, reset, clean, stash, push) are blocked unless run through scoped cr commands.

**For multi-session parallel work**, each terminal/Claude session needs a stable session ID. Claude Code provides `CLAUDE_SESSION_ID` automatically. If running outside Claude Code or in a bare terminal:

```bash
export CR_SESSION_ID=session-1
cr scope open --project project-a
```

Without a stable session ID, different terminals will share the `_cr/sessions/current` pointer and may resolve to the wrong scope.
