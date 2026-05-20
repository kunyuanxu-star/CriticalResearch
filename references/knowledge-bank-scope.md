# Knowledge Bank Scope Analysis

Options for knowledge bank scope and their tradeoffs.

## Option A: Per-Workspace (Default)

Knowledge lives under `Research/_cr/knowledge/` within the workspace directory.

**Advantages**: Portable with workspace (git-trackable), no configuration needed, natural scope boundary matches the research projects being worked on.

**Disadvantages**: No sharing across workspaces on different machines. Researcher with multiple workspaces must manually sync or duplicate cards.

**Configuration**: None required. Works out of the box.

## Option B: Global (User-Level)

Knowledge lives under `~/.config/critical-research/knowledge/` or similar XDG path.

**Advantages**: All workspaces share one knowledge base. Rules learned in one workspace immediately available in others. Single source of truth for thinking rules.

**Disadvantages**: Cross-contamination risk between unrelated research domains. Harder to audit which projects contributed which rules. Configuration required.

**Configuration**: Set `CR_KNOWLEDGE_HOME` environment variable.

## Option C: Configurable (Hybrid)

Per-workspace by default, with optional `CR_KNOWLEDGE_HOME` override for global sharing. The `cr-load-thinking-rules` and `cr-load-literature-context` scripts check both locations and merge results.

**Advantages**: Flexibility. Start simple (per-workspace), scale to global when ready. No forced migration.

**Disadvantages**: Slightly more complex loading logic. Must define merge semantics (global overrides workspace? workspace extends global?).

## Recommendation

**Option C** (configurable hybrid) with these merge rules:
1. Workspace-local `_cr/knowledge/` is always loaded first
2. If `CR_KNOWLEDGE_HOME` is set, global cards are loaded as supplement
3. Workspace cards take precedence over global cards with the same ID
4. `cr-promote-knowledge` operates on the workspace-local set
5. Users can manually copy validated/canonical cards to global for cross-workspace sharing

This preserves the draft's per-workspace default while allowing the user to opt into cross-workspace sharing when they have multiple active research workspaces.
