# Plugin Cleanup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Clean up the agents plugin ecosystem — remove Python rules from claude-9, eliminate duplicate agents across plugins, and update manifests.

**Architecture:** Three independent workstreams: (1) strip language-specific rules from claude-9 to make it universal, (2) remove exact-duplicate agents that exist in multiple plugins, (3) consolidate debugging/incident-response overlap. Each workstream gets its own commit.

**Tech Stack:** Markdown, JSON, git

---

## Key Findings (from analysis)

### Finding 1: Python rules in claude-9

claude-9 ships `rules/python.md` as a managed file (installed to `~/.claude/rules/python.md` via the setup skill). This is redundant — the same file already exists at the workspace level (`~/projects/.claude/rules/python.md`). Python rules should live at the project/workspace level, not inside a universal plugin.

**Affected files:**
- `plugins/claude-9/rules/python.md` — delete
- `plugins/claude-9/skills/setup/SKILL.md:39-46` — remove `rules/python.md` from managed file list
- `plugins/claude-9/skills/setup/SKILL.md:65-73` — remove `@rules/python.md` from CLAUDE.md marker section
- `plugins/claude-9/skills/setup/SKILL.md:97-99` — remove from manifest `files` array
- `plugins/claude-9/agents/execution/backend-engineer.md:25` — remove "Use type hints on all function signatures" (Python-specific)
- `plugins/claude-9/agents/execution/solution-architect.md:97` — remove "Type hints on all function signatures" from quality checklist
- `plugins/claude-9/.claude-plugin/plugin.json` — bump version (minor: `1.1.0` → `1.2.0`)
- `~/.claude/CLAUDE.md` — the `@rules/python.md` line was already removed by the user

### Finding 2: Exact duplicate agents

Two agents exist as identical copies across plugins (same description text):

| Agent | Plugin A (keep) | Plugin B (remove) | Reason |
|-------|----------------|-------------------|--------|
| `devops-troubleshooter` | `incident-response` | `cicd-automation` | incident-response is the natural home for troubleshooting |
| `kubernetes-architect` | `cloud-infrastructure` | `kubernetes-operations` | cloud-infrastructure already has cloud-architect, terraform-specialist, etc. — better grouping |

**Note:** `kubernetes-operations` has valuable skills (gitops-workflow, k8s-security-policies, helm-chart-scaffolding, k8s-manifest-generator) that should be preserved. Only the duplicate agent needs removal.

### Finding 3: Debugging vs incident-response overlap

Two agents have the same name but **different descriptions and scope**:

| Agent | `debugging` plugin (general dev) | `incident-response` plugin (production) |
|-------|----------------------------------|----------------------------------------|
| `debugger` | "Debugging specialist for errors, test failures, and unexpected behavior" | "Performs deep root cause analysis through code path tracing, git bisect automation, dependency analysis" |
| `error-detective` | "Search logs and codebases for error patterns, stack traces, and anomalies" | "Analyzes error traces, logs, and observability data to identify error signatures, reproduction steps, user impact" |

These serve genuinely different contexts (dev vs production). The `debugging` plugin versions are what's registered in the Task tool (they appear in the subagent list). The `incident-response` versions are production-focused and complement the incident-responder, test-automator agents in that plugin.

**Decision:** Keep both but rename the incident-response variants to avoid name collision. The `debugging` plugin agents are the "default" debugger/error-detective. The incident-response ones become `incident-debugger` and `incident-error-detective`.

### Notes (from todos.md)

- Update author to "Christopher Allen" when modifying plugin manifests
- Think carefully about semver: major/minor/patch
- team-implementer (agent-teams) is **not redundant** — it's a coordinator, not a specialist. No changes needed.

---

## Task 1: Remove Python rules from claude-9

**Files:**
- Delete: `plugins/claude-9/rules/python.md`
- Modify: `plugins/claude-9/skills/setup/SKILL.md`
- Modify: `plugins/claude-9/agents/execution/backend-engineer.md`
- Modify: `plugins/claude-9/agents/execution/solution-architect.md`
- Modify: `plugins/claude-9/.claude-plugin/plugin.json`

### Step 1: Delete the Python rules file

Delete `plugins/claude-9/rules/python.md`.

Check if the `plugins/claude-9/rules/` directory has any other files. If empty after deletion, delete the directory too.

### Step 2: Update the setup skill managed file list

In `plugins/claude-9/skills/setup/SKILL.md`, remove `rules/python.md` from three locations:

**Location A — Step 4 managed file list (around line 39-46):**

Remove the line `rules/python.md` from the file list block. The block should become:
```
soul.md
rules/security.md
rules/workflow.md
rules/agent-conventions.md
standards/parallel-execution.md
standards/task-priorities.md
```

**Location B — Step 6 CLAUDE.md marker section (around line 65-73):**

Remove `@rules/python.md` from the marker block. The block should become:
```markdown
<!-- SOUL:BEGIN v1.0.0 -->
@soul.md
@rules/security.md
@rules/workflow.md
@rules/agent-conventions.md
@standards/parallel-execution.md
@standards/task-priorities.md
<!-- SOUL:END -->
```

**Location C — Step 7 manifest files array (around line 97-99):**

Remove `"rules/python.md",` from the JSON array. The array should become:
```json
"files": [
    "soul.md",
    "rules/security.md",
    "rules/workflow.md",
    "rules/agent-conventions.md",
    "standards/parallel-execution.md",
    "standards/task-priorities.md"
]
```

### Step 3: Remove Python-specific guidance from backend-engineer

In `plugins/claude-9/agents/execution/backend-engineer.md`, line 25:

Remove the line:
```
- Use type hints on all function signatures
```

This is Python-specific. The agent should follow whatever conventions the project uses (which it already says: "Match the project's framework conventions").

### Step 4: Remove Python-specific guidance from solution-architect

In `plugins/claude-9/agents/execution/solution-architect.md`, line 97:

In the quality checklist, change:
```
- [ ] Type hints on all function signatures
```
To:
```
- [ ] Follows language-specific conventions (type annotations, naming, etc.)
```

This makes it language-agnostic while still checking for convention adherence.

### Step 5: Bump claude-9 version

In `plugins/claude-9/.claude-plugin/plugin.json`, change:
```json
"version": "1.1.0"
```
To:
```json
"version": "1.2.0"
```

This is a minor version bump — removing a managed file is a feature-level change (not a patch).

### Step 6: Verify and commit

Run: `git diff --stat` to review all changes.

Verify:
- `rules/python.md` is deleted
- No remaining references to `python.md` in the claude-9 plugin: `grep -r "python" plugins/claude-9/`
- Setup skill still has 6 managed files (was 7)
- CLAUDE.md marker section has 6 `@` references (was 7)
- Manifest JSON has 6 files (was 7)

Commit:
```bash
git add plugins/claude-9/
git commit -m "refactor(claude-9): remove Python rules to make plugin language-agnostic

Python standards belong at the project/workspace level, not inside a
universal plugin. Projects using Python inherit rules from their own
CLAUDE.md or the workspace .claude/rules/python.md."
```

---

## Task 2: Remove exact duplicate agents

**Files:**
- Delete: `plugins/cicd-automation/agents/devops-troubleshooter.md`
- Delete: `plugins/kubernetes-operations/agents/kubernetes-architect.md`
- Modify: `plugins/cicd-automation/.claude-plugin/plugin.json`
- Modify: `plugins/kubernetes-operations/.claude-plugin/plugin.json`

### Step 1: Remove duplicate devops-troubleshooter from cicd-automation

Delete `plugins/cicd-automation/agents/devops-troubleshooter.md`.

The canonical version remains at `plugins/incident-response/agents/devops-troubleshooter.md` (identical description).

Verify cicd-automation still has its unique agent: `plugins/cicd-automation/agents/deployment-engineer.md`.

### Step 2: Remove duplicate kubernetes-architect from kubernetes-operations

Delete `plugins/kubernetes-operations/agents/kubernetes-architect.md`.

The canonical version remains at `plugins/cloud-infrastructure/agents/kubernetes-architect.md` (identical description).

Verify kubernetes-operations still has its skills (gitops-workflow, helm-chart-scaffolding, k8s-manifest-generator, k8s-security-policies) — these are unique and must remain.

### Step 3: Update cicd-automation manifest

In `plugins/cicd-automation/.claude-plugin/plugin.json`:

- Bump version `1.3.0` → `1.3.1` (patch — removing duplicate, no functionality change since canonical agent still exists)
- Update author name to "Christopher Allen" (already correct — `"Christopher Allen"`)

Verify author is already "Christopher Allen" — if so, no change needed.

### Step 4: Update kubernetes-operations manifest

In `plugins/kubernetes-operations/.claude-plugin/plugin.json`:

- Bump version `1.2.1` → `1.2.2` (patch)
- Update author to `"Christopher Allen"` (currently "Seth Hobson" — update per todos.md note)

Change:
```json
"author": {
    "name": "Seth Hobson",
    "email": "seth@major7apps.com"
}
```
To:
```json
"author": {
    "name": "Christopher Allen",
    "email": "chris.allen94@gmail.com"
}
```

### Step 5: Verify and commit

Run: `git diff --stat` to review all changes.

Verify:
- Only one `devops-troubleshooter.md` exists (in incident-response): `find plugins -name "devops-troubleshooter.md"`
- Only one `kubernetes-architect.md` exists (in cloud-infrastructure): `find plugins -name "kubernetes-architect.md"`
- kubernetes-operations skills directory is intact

Commit:
```bash
git add plugins/cicd-automation/ plugins/kubernetes-operations/
git commit -m "refactor(plugins): remove duplicate agents across plugins

devops-troubleshooter: keep in incident-response, remove from cicd-automation
kubernetes-architect: keep in cloud-infrastructure, remove from kubernetes-operations

Both copies had identical descriptions. Canonical versions remain in their
natural domain plugins."
```

---

## Task 3: Rename incident-response debug agents to avoid name collision

**Files:**
- Modify: `plugins/incident-response/agents/debugger.md` (rename to `incident-debugger.md`)
- Modify: `plugins/incident-response/agents/error-detective.md` (rename to `incident-error-detective.md`)
- Modify: `plugins/incident-response/.claude-plugin/plugin.json`

### Step 1: Rename debugger to incident-debugger

Rename file: `plugins/incident-response/agents/debugger.md` → `plugins/incident-response/agents/incident-debugger.md`

Inside the file, update the frontmatter `name:` field:
```yaml
name: incident-debugger
```

Keep the description and content unchanged — the production-focused scope is already clearly differentiated.

### Step 2: Rename error-detective to incident-error-detective

Rename file: `plugins/incident-response/agents/error-detective.md` → `plugins/incident-response/agents/incident-error-detective.md`

Inside the file, update the frontmatter `name:` field:
```yaml
name: incident-error-detective
```

Keep the description and content unchanged.

### Step 3: Update incident-response manifest

In `plugins/incident-response/.claude-plugin/plugin.json`:

- Bump version `1.4.0` → `1.5.0` (minor — agent names changed, which affects how users reference them)
- Update author to "Christopher Allen" (currently "Chris Allen" — normalize)

Change:
```json
"version": "1.4.0",
...
"author": {
    "name": "Chris Allen",
```
To:
```json
"version": "1.5.0",
...
"author": {
    "name": "Christopher Allen",
```

### Step 4: Verify and commit

Run: `git diff --stat` to review all changes.

Verify:
- `debugging` plugin still has `debugger.md` and `error-detective.md` (unchanged)
- `incident-response` plugin now has `incident-debugger.md` and `incident-error-detective.md`
- No duplicate agent names across the entire repo: `grep -rh "^name:" plugins/*/agents/**/*.md | sort | uniq -d` should return empty
- incident-response still has 5 agents: incident-debugger, incident-error-detective, devops-troubleshooter, incident-responder, test-automator

Commit:
```bash
git add plugins/incident-response/
git commit -m "refactor(incident-response): rename debug agents to avoid collision

debugger → incident-debugger
error-detective → incident-error-detective

The debugging plugin provides general-purpose dev debugging agents.
The incident-response variants focus on production incidents with
root cause analysis, git bisect, and observability data."
```

---

## Task 4: Update todos.md and final cleanup

**Files:**
- Modify: `todos.md`

### Step 1: Mark completed items

Update `todos.md` to reflect completed work:

```markdown
# Todo items
[x] remove python rules from claude-9. This should be handled at the project level if python is used. Claude-9 needs to be more universal and not waste context on details.
[x] evaluate plugins agents for overlap and identify quality gaps.
[x] evaluate agent-teams:team-implementer compared to available specialized agents

Notes:
- don't forget to update plugin manifests when making changes and think carefully if it is a major minor or patch change.
- when updating plugins also update author to Christopher Allen as appropriate.

## Findings
- team-implementer is NOT redundant — it coordinates parallel work across backend/frontend with file ownership boundaries
- Removed 2 exact duplicate agents (devops-troubleshooter, kubernetes-architect)
- Renamed 2 incident-response agents to avoid name collision with debugging plugin
- Python rules removed from claude-9 (now language-agnostic)
```

### Step 2: Verify full repo state

Run: `git status` to see all changes.
Run: `git diff --stat HEAD` to see summary.

Verify no unintended changes outside the target plugins.

### Step 3: Final commit

```bash
git add todos.md
git commit -m "chore: update todos with completed plugin cleanup findings"
```

---

## Summary of Changes

| Change | Plugin | Version Bump | Commit |
|--------|--------|-------------|--------|
| Delete `rules/python.md`, update setup skill, remove Python refs from agents | claude-9 | 1.1.0 → 1.2.0 | 1 |
| Delete duplicate `devops-troubleshooter.md` | cicd-automation | 1.3.0 → 1.3.1 | 2 |
| Delete duplicate `kubernetes-architect.md`, update author | kubernetes-operations | 1.2.1 → 1.2.2 | 2 |
| Rename `debugger` → `incident-debugger`, `error-detective` → `incident-error-detective`, update author | incident-response | 1.4.0 → 1.5.0 | 3 |
| Mark todos complete | (root) | — | 4 |

## Risks & Open Questions

1. **cloud-infrastructure author**: Currently "Seth Hobson" — should this also be updated to "Christopher Allen"? The todos note says "as appropriate" — this plugin wasn't otherwise modified in this plan. Recommend leaving it for now and updating if the plugin is touched for other reasons.

2. **Installed plugin sync**: After these changes land in `main`, the installed plugins at `~/.claude/plugins/marketplaces/claude-code-workflows/` need to sync. Verify the auto-sync picks up the changes, or manually re-install.

3. **`~/.claude/rules/python.md` cleanup**: After removing from claude-9's managed files, the file at `~/.claude/rules/python.md` will become orphaned (no longer managed by the setup skill). It should either be manually deleted or left in place if the user wants it there independent of claude-9. The user's CLAUDE.md already removed the `@rules/python.md` reference.

4. **Setup skill re-run**: Users who previously ran `/claude-9:setup` will have `rules/python.md` listed in their `~/.claude/.soul-manifest.json`. The manifest won't auto-clean — next `/claude-9:setup` run will update the manifest but won't delete the orphaned file. Consider adding cleanup logic to the setup skill in a future iteration.
