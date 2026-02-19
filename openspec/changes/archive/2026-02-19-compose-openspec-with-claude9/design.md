## Context

The openspec plugin (`plugins/openspec/`) is installed at user scope via the claude-code-workflows marketplace. It provides 10 commands for spec-driven development. The claude-9 plugin provides the universal agent harness (hooks, rules, skills, agents). The superpowers plugin provides behavioral skills (brainstorming, verification, exploration). Currently, openspec commands operate as self-contained workflows that bypass claude-9 and superpowers optimizations.

The plugin consists entirely of markdown command files — no executable code. Changes are prompt engineering, not software engineering. The "code" is natural language instructions that guide Claude's behavior.

## Goals / Non-Goals

**Goals:**
- Make openspec commands compose with the claude-9 harness rather than replace it
- Ensure `/openspec:explore` routes to the appropriate exploration tool based on user intent
- Prevent `openspec init` from generating duplicate `.claude/` files when the plugin is active
- Normalize all internal prefix references to `/openspec:*`
- Add runtime CLI detection to all CLI-dependent commands
- Add a soft gate on `EnterPlanMode` to prefer OpenSpec workflow
- Clean up inconsistent description metadata

**Non-Goals:**
- Rewriting `apply.md` to use implementation-workflow or TDD skills (already composes correctly at agent level)
- Rewriting `verify.md` to invoke superpowers:verification-before-completion (OpenSpec coherence checking is a different concern)
- Changing the upstream OpenSpec CLI behavior
- Modifying claude-9 or superpowers plugins (this change is scoped to the openspec plugin)

## Decisions

### Decision 1: Explore routing via AskUserQuestion

**Choice**: Add an AskUserQuestion step at the top of explore.md with three options.

**Rationale**: The user explicitly requested this approach during discussion. The three modes serve genuinely different purposes:
- OpenSpec-scoped: confined thinking within the change management context (current behavior)
- Broad exploration: general codebase investigation that should use optimized Explore subagents
- Brainstorming first: creative/divergent thinking before narrowing to exploration

**Alternative considered**: Auto-detect scope from the topic argument. Rejected because assumptions about intent are unreliable — the user should choose.

**Implementation**: The AskUserQuestion presents three options. Based on selection:
- **OpenSpec-scoped**: Continue with existing explore.md behavior (with prefix normalization)
- **Broad**: State that OpenSpec context is available if relevant, then hand off to the user's normal exploration flow (do not constrain with "never write code" guardrail)
- **Brainstorming**: Invoke `superpowers:brainstorming` skill via the Skill tool, then after completion offer transition to OpenSpec-scoped or broad exploration

### Decision 2: Onboard init flow

**Choice**: Replace bare `openspec init` with conditional `openspec init --tools none` + optional multi-tool selection.

**Rationale**: `openspec init --tools claude` generates 20 `.claude/` files (10 commands + 10 skills) that duplicate and conflict with the plugin's own commands. Since the onboard command is running as a plugin command, the plugin is definitionally active — the `.claude/` files are unnecessary. The `--tools` flag composes cleanly: `--tools cursor,windsurf` generates only those tool files without touching `.claude/`.

**Implementation**: In onboard.md's preflight section:
1. Check `which openspec` — stop if missing
2. Check `openspec/` directory — skip init if exists
3. Since we're running inside the plugin, default to `--tools none`
4. AskUserQuestion: "Do you also use other AI tools that need OpenSpec setup?" with options for common tools
5. Run `openspec init --tools none` or `openspec init --tools <selected>` accordingly

### Decision 3: Standard CLI detection pattern

**Choice**: Add a bash check block at the start of every command that calls CLI commands.

**Rationale**: Currently only `onboard.md` has a runtime check. The other 9 commands have text-only prerequisite notes that the LLM may skip. A consistent pattern ensures all commands fail gracefully.

**Pattern**:
```
**Step 0: Verify CLI**
Run: `which openspec >/dev/null 2>&1 || echo "NOT_INSTALLED"`
If NOT_INSTALLED, tell the user: "OpenSpec CLI is not installed. Install with: `npm install -g @fission-ai/openspec@latest`" and stop.
```

**Exception**: `explore.md` in broad exploration mode does not need the CLI since it delegates elsewhere.

### Decision 4: EnterPlanMode soft gate

**Choice**: Implement as a PreToolUse hook + a lightweight rule file.

**Rationale**: A hook provides mechanical enforcement while the rule provides contextual guidance. The hook should be a soft gate (ask user to confirm) not a hard block, because EnterPlanMode is sometimes appropriate (e.g., trivial changes, non-OpenSpec projects). The message should be: "The OpenSpec workflow (/openspec:ff or /openspec:new) is generally superior to native plan mode but may not be right in this instance. Would you like to proceed with EnterPlanMode or use OpenSpec instead?"

**Implementation**:
- Hook: PreToolUse hook on `EnterPlanMode` tool. The hook script checks if the openspec plugin is active (simple: it's running as part of the plugin, so it always is). Outputs a message asking the user to confirm. Exit code determines whether to proceed or block.
- Rule: `rules/openspec-preference.md` — a short rule file stating the preference for OpenSpec workflow over EnterPlanMode for multi-step changes.

**Open question**: Whether PreToolUse hooks can output user-facing messages and soft-gate (needs confirmation from parallel research task).

### Decision 5: Prefix normalization approach

**Choice**: Global find-and-replace of `/opsx:` with `/openspec:` across all 10 command files.

**Rationale**: Straightforward mechanical change. 40 references total. The README already uses `/openspec:*` correctly. No semantic changes needed.

### Decision 6: Version bump

**Choice**: Bump from 1.1.0 to 1.2.0 (minor version).

**Rationale**: This adds new behavior (explore routing, onboard flow, CLI detection, hook) without breaking existing command interfaces. All command names remain the same. Minor version is appropriate per semver.

## Risks / Trade-offs

- **Explore routing adds friction**: Every `/openspec:explore` invocation now requires an extra question. Mitigated by making the question a quick 3-option selector, not open-ended. Users who always want one mode can type it directly.
- **Hook feasibility unknown**: The EnterPlanMode hook depends on PreToolUse hook capabilities that are being researched in parallel. If hooks can't soft-gate, fall back to rule-only approach.
- **Broad exploration loses OpenSpec guardrails**: When user selects broad mode, the "never write code" guardrail doesn't apply. This is intentional — but means the user could accidentally write code when they intended to just explore. Mitigated by the explicit routing question making intent clear.
- **CLI detection adds boilerplate**: Every command gets a Step 0. But this is prompt text, not code — the maintenance burden is low and the user experience improvement (clear error on missing CLI) is significant.

## Open Questions

- Can PreToolUse hooks soft-gate tool calls with user-facing messages? (Being researched in parallel task)
- Should the hook be in the openspec plugin or in claude-9? (Preference: openspec plugin, since it's openspec-specific behavior)
