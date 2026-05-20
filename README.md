# CriticalResearch

A domain-general, computer-science-specific critical research loop as a Claude Code skill. It decomposes claims, grounds evidence, finds counterexamples, generates research gaps, and produces evidence-backed conclusions — looping indefinitely until you are convinced.

Covers: OS, networking, security, databases, PL/compilers, architecture, AI infrastructure, distributed systems, software engineering, HCI/CSCW, and technical systems work.

## Installation

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (CLI or IDE extension)
- Git
- Bash (macOS / Linux)

### Quick Install

```bash
git clone https://github.com/Plucky923/CriticalResearch.git
cd CriticalResearch
bash install.sh

# Then initialize your research workspace:
cd ~/Research
cr workspace init
cr start my-topic
cr round my-topic --mode paper
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

Start a conversation with Claude Code and the skill activates automatically when you ask about CS research tasks. Examples:

- "Validate this idea for a new caching algorithm"
- "Review my system design for a distributed key-value store"
- "Critique the related work section of my paper on fuzzing"

### CLI (standalone)

```bash
cr workspace init                # Initialize a Research workspace
cr start framevm                 # Create a new research project (use lowercase, hyphens)
cr continue                      # Output next-round task prompt
cr round framevm --mode paper    # Open a new paper-mode round
cr close-round framevm           # Validate and close the active round
cr validate framevm              # Run project invariant checks
cr status                        # Show workspace status
```

## Workflow Modes

| Mode | Use Case | Depth |
|---|---|---|
| **Lightweight** | Quick validation, idea screening (≤3 claims) | Internal knowledge only |
| **Standard** | Regular research, design review (4-10 claims) | 1 search pass |
| **Deep** | Journal-grade review, full rebuttal (>10 claims) | Deep search + concurrent role-lenses |

The only exit condition is user satisfaction — the loop continues until you say you're convinced.

## Project Structure

```
├── SKILL.md              # Skill definition (Claude Code entry point)
├── scripts/              # CLI tools (cr, validators, guards)
├── hooks/                # Checkpoint hooks for workflow quality enforcement
├── templates/            # Research artifact templates (ledgers, reports, dossiers)
├── schemas/              # JSON schemas for project/round state validation
├── references/           # Domain profiles, evidence standards, role lenses
└── agents/               # Sub-agent instruction sets
```
