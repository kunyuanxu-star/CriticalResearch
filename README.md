# CriticalResearch

A domain-general, computer-science-specific critical research loop as a Claude Code skill. It decomposes claims, grounds evidence, finds counterexamples, generates research gaps, and produces evidence-backed conclusions — looping indefinitely until you are convinced.

Covers: OS, networking, security, databases, PL/compilers, architecture, AI infrastructure, distributed systems, software engineering, HCI/CSCW, and technical systems work.

## Installation

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (CLI or IDE extension)
- Git
- Bash (macOS / Linux)

### Install as a Claude Code skill

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/CriticalResearch.git ~/.claude/skills/critical-cs-research
```

Or via the Claude Code plugin registry (if published):

```
/plugin install critical-cs-research
```

### Install the CLI tools (optional)

The `cr` CLI provides deterministic state management for research projects outside of Claude Code conversations.

```bash
# Add to your PATH in ~/.zshrc or ~/.bashrc
export PATH="$HOME/.claude/skills/critical-cs-research/scripts:$PATH"
```

Then reload your shell:

```bash
source ~/.zshrc
```

## Usage

### Within Claude Code

Start a conversation with Claude Code and the skill activates automatically when you ask about CS research tasks. Examples:

- "Validate this idea for a new caching algorithm"
- "Review my system design for a distributed key-value store"
- "Critique the related work section of my paper on fuzzing"

### CLI (standalone)

```bash
cr start "my research topic"    # Create a new research project
cr continue                      # Output next-round task prompt
cr round <project>               # Open a new round
cr close-round <project>         # Validate and close the active round
cr validate <project>            # Run project invariant checks
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
