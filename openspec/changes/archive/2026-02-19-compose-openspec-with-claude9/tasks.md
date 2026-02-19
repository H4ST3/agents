## 1. Prefix Normalization

- [x] 1.1 Replace all `/opsx:` references with `/openspec:` in `commands/explore.md` (3 references)
- [x] 1.2 Replace all `/opsx:` references with `/openspec:` in `commands/new.md` (3 references)
- [x] 1.3 Replace all `/opsx:` references with `/openspec:` in `commands/ff.md` (2 references)
- [x] 1.4 Replace all `/opsx:` references with `/openspec:` in `commands/continue.md` (3 references)
- [x] 1.5 Replace all `/opsx:` references with `/openspec:` in `commands/apply.md` (3 references)
- [x] 1.6 Replace all `/opsx:` references with `/openspec:` in `commands/verify.md` (1 reference)
- [x] 1.7 Replace all `/opsx:` references with `/openspec:` in `commands/archive.md` (4 references)
- [x] 1.8 Replace all `/opsx:` references with `/openspec:` in `commands/bulk-archive.md` (1 reference)
- [x] 1.9 Replace all `/opsx:` references with `/openspec:` in `commands/sync.md` (1 reference)
- [x] 1.10 Replace all `/opsx:` references with `/openspec:` in `commands/onboard.md` (19 references)

## 2. CLI Detection

- [x] 2.1 Add Step 0 CLI detection block to `commands/new.md` — replace text-only prerequisite with runtime `which openspec` check
- [x] 2.2 Add Step 0 CLI detection block to `commands/ff.md`
- [x] 2.3 Add Step 0 CLI detection block to `commands/continue.md`
- [x] 2.4 Add Step 0 CLI detection block to `commands/apply.md`
- [x] 2.5 Add Step 0 CLI detection block to `commands/verify.md`
- [x] 2.6 Add Step 0 CLI detection block to `commands/archive.md`
- [x] 2.7 Add Step 0 CLI detection block to `commands/bulk-archive.md`
- [x] 2.8 Add Step 0 CLI detection block to `commands/sync.md`
- [x] 2.9 Update `commands/explore.md` CLI detection — required for OpenSpec-scoped mode only, not broad exploration
- [x] 2.10 Update `commands/onboard.md` CLI detection — already has runtime check, normalize to match new pattern

## 3. Description Cleanup

- [x] 3.1 Remove "(OPSX)" from `commands/new.md` frontmatter description
- [x] 3.2 Remove "(Experimental)" from `commands/continue.md` frontmatter description
- [x] 3.3 Remove "(Experimental)" from `commands/apply.md` frontmatter description if present

## 4. Explore Command Rewrite

- [x] 4.1 Add AskUserQuestion routing at the top of `commands/explore.md` with three options: OpenSpec-scoped, Broad exploration, Brainstorming first
- [x] 4.2 Restructure explore.md: move existing stance/behavior content under the OpenSpec-scoped branch
- [x] 4.3 Add broad exploration branch: provide OpenSpec context if available, then hand off without "never write code" guardrail
- [x] 4.4 Add brainstorming branch: invoke `superpowers:brainstorming` skill, then offer transition to scoped or broad exploration
- [x] 4.5 Ensure topic argument is passed through to whichever exploration mode is selected

## 5. Onboard Smart Init

- [x] 5.1 Replace `openspec init` instruction in `commands/onboard.md` preflight with smart init flow
- [x] 5.2 Add `openspec/` directory existence check before init
- [x] 5.3 Add AskUserQuestion for other AI tool setup (Cursor, Windsurf, etc.) when init is needed
- [x] 5.4 Use `openspec init --tools none` as default when plugin is active, `--tools <selected>` if user picks other tools

## 6. Preference Rule and Hook

- [x] 6.1 Create `rules/openspec-preference.md` rule file expressing preference for OpenSpec workflow over EnterPlanMode
- [x] 6.2 Create PreToolUse hook for EnterPlanMode soft gate (pending feasibility confirmation from research task)
- [x] 6.3 Register hook in plugin.json if hook approach is feasible
- [x] 6.4 If hook is not feasible, strengthen the rule file to compensate

## 7. Plugin Manifest

- [x] 7.1 Bump version in `.claude-plugin/plugin.json` from 1.1.0 to 1.2.0
- [x] 7.2 Add hooks reference to plugin.json if hook is added in task 6.2
