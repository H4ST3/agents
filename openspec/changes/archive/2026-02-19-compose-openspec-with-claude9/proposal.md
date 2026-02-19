## Why

The openspec plugin commands operate as self-contained workflows that bypass optimizations provided by the claude-9 harness and superpowers plugin. `/openspec:explore` does its own inline codebase investigation instead of delegating to Explore subagents or the brainstorming skill. `/openspec:onboard` instructs users to run `openspec init` which generates 20 duplicate `.claude/` files (10 commands + 10 skills) that conflict with the plugin's own commands. All 10 command files reference the upstream `/opsx:*` prefix internally while the plugin surfaces commands as `/openspec:*`, creating user confusion. The plugin needs to compose with the existing agent harness rather than replace it.

## What Changes

- **`explore.md` rewrite**: Add AskUserQuestion routing to let users choose OpenSpec-scoped exploration, broad exploration, or brainstorming-first. Route to appropriate tools/skills instead of doing everything inline.
- **`onboard.md` smart init**: Replace bare `openspec init` with `openspec init --tools none` when plugin provides Claude commands. Ask user if they need other AI tool integrations (Cursor, Windsurf, etc.) and run `openspec init --tools <selected>` accordingly.
- **Prefix normalization**: Replace all 40 `/opsx:*` references across 10 command files with `/openspec:*`.
- **CLI detection**: Add runtime `which openspec` check to all commands that invoke the CLI, replacing text-only prerequisite notes. Stop with install instructions if missing.
- **Description cleanup**: Remove "(OPSX)" from `new.md` and "(Experimental)" from `continue.md` descriptions.
- **Version bump**: `plugin.json` from 1.1.0 to 1.2.0.
- **Add preference rule**: New `rules/openspec-preference.md` expressing that OpenSpec workflow should be preferred over native `EnterPlanMode` for multi-step changes.
- **Add EnterPlanMode hook**: PreToolUse hook that soft-gates `EnterPlanMode` with a user confirmation when OpenSpec is available.

## Capabilities

### New Capabilities
- `openspec-planmode-preference`: Rule and hook that express preference for OpenSpec workflow over native EnterPlanMode, with soft user confirmation gate.

### Modified Capabilities
- (none -- no existing specs to modify)

## Impact

- **Files modified**: All 10 command files in `plugins/openspec/commands/`, plus `plugin.json`
- **Files added**: `rules/openspec-preference.md`, hook script for EnterPlanMode gate
- **User-facing**: Command behavior changes for `explore` (now asks routing question) and `onboard` (no longer generates duplicate `.claude/` files). All other commands get normalized prefix references and CLI detection but otherwise identical behavior.
- **Backward compatibility**: All command names unchanged. No breaking changes. Users who previously typed `/openspec:explore` still get explore mode, just with a routing step first.
