# CriticalResearch

A domain-general, computer-science-specific critical research loop as a Claude Code skill with a **workflow-specific project engine**. It decomposes claims, grounds evidence in real external search, finds counterexamples, generates research gaps, produces document patches, distills reusable knowledge, and produces evidence-backed conclusions — looping indefinitely until all workflow stages are complete and validators pass.

Covers: OS, networking, security, databases, PL/compilers, architecture, AI infrastructure, distributed systems, software engineering, HCI/CSCW, and technical systems work.

## Installation

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (CLI or IDE extension)
- Git
- Bash (macOS / Linux)
- jq (brew/apt install jq)
- yq (brew/apt install yq)

### Quick Install

```bash
git clone https://github.com/Plucky923/CriticalResearch.git
cd CriticalResearch
bash install.sh

# Then initialize your research workspace:
cd ~/Research
cr workspace init
cr project init my-topic --domain systems
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
cr workspace init                  # Initialize a Research workspace
cr project init my-topic --domain systems  # Create a new research project
cr project status my-topic         # Show project status
cr project list                    # List all projects

# Document management
cr document add my-topic survey --type survey --path documents/survey.md
cr document add my-topic design --type design-doc --path documents/design-doc.md
cr document list my-topic          # List all documents in the project
cr document status my-topic survey # Show document status

# Unit management
cr unit add my-topic survey survey.taxonomy --title "Taxonomy"
cr unit list my-topic survey       # List units in a document
cr unit status my-topic survey survey.taxonomy

# Full-Round Execution (Claude Code)
/critical-cs-research <project> --workflow <id> --doc <id> [--unit <id>] [--mode <mode>] <objective>

# Round lifecycle (CLI)
cr round start my-topic --workflow survey --doc survey --unit survey.taxonomy --mode deep --objective "Research taxonomy"
cr round status my-topic           # Show round status
cr round close my-topic            # Validate and close the active round

# Stage management
cr stage status my-topic           # Show current stage and missing outputs
cr stage advance my-topic          # Validate current stage and advance to next
cr stage validate my-topic         # Validate current stage without advancing

# Validation
cr validate my-topic               # Run all project invariant checks
cr validate my-topic --round round-017  # Run validators for a specific round
```

## Workflow Types

| Workflow | Target Document | Use Case |
|----------|----------------|----------|
| **survey** | survey.md | Literature survey, taxonomy construction, systematic review |
| **design** | design-doc.md | System design, architecture document, interface specification |
| **paper** | paper.md | Academic paper — claims, evidence, evaluation, arguments |
| **proposal** | proposal.md | Research proposal, grant proposal, project plan |
| **experiment** | experiment-plan.md | Experiment design, methodology, validation plan |

All rounds run in **Deep mode only**: full evidence search, concurrent role-lenses, complete ledgers and detailed report output. No Triaging — every round can close.

Each workflow defines its own stage order in `workflows/<id>/workflow.yaml`. A round enters exactly one workflow, declares exactly one mutable document, and modifies one or more units inside that document.

`cr stage advance` validates and advances stages; it does not generate artifacts. The agent/user must create required outputs for each stage.

## Project Structure

```
├── SKILL.md              # Skill definition (Claude Code entry point)
├── README.md             # This file
├── engine/               # Engine: scripts, validators, schemas
│   ├── scripts/          # CLI tools (cr, cr-project, cr-document, cr-unit, cr-round, cr-stage, cr-validate)
│   ├── validators/       # Engine-level validators
│   └── schemas/          # JSON schemas for v2 artifacts
├── workflows/            # Per-workflow definitions
│   ├── survey/           # Survey workflow: workflow.yaml, prompts/, schemas/, validators/
│   ├── design/           # Design workflow
│   ├── paper/            # Paper workflow
│   ├── proposal/         # Proposal workflow
│   └── experiment/       # Experiment workflow
├── templates/            # Domain-neutral artifact templates
├── references/           # Domain profiles, evidence standards, role lenses
├── hooks/                # Stop/PreToolUse/PostToolUse hooks for enforcement
└── agents/               # Sub-agent instruction sets

projects/
├── <project-id>/
│   ├── project.yaml          # Project metadata + document registry
│   ├── documents/            # Target documents + registry.yaml
│   ├── units/                # Unit registries per document
│   ├── knowledge/            # Project-level persistent knowledge
│   └── rounds/               # Per-round artifacts (contracts, ledgers, patches, deltas)
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
