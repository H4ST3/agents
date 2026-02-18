---
name: setup
description: Install or update claude-9 managed files to ~/.claude/. Run after first install and after plugin updates.
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Setup: Install or Update claude-9 Managed Files

Install the claude-9 plugin's managed files as symlinks into `~/.claude/` and configure `CLAUDE.md` imports. Run this after first install and after every plugin update.

## Step 1: Determine Plugin Root

The plugin root is 3 directory levels up from this SKILL.md file:

```
plugins/claude-9/skills/setup/SKILL.md   <- this file
plugins/claude-9/                         <- plugin root
```

Resolve the plugin root path. All source files are read relative to it. Confirm `SOUL.md` exists at the plugin root before continuing.

## Step 2: Read Existing Manifest

Read `~/.claude/.soul-manifest.json` if it exists.

- **If it exists**: This is an **upgrade**. Note the `version` field for the report.
- **If it does not exist**: This is a **fresh install**.

## Step 3: Read Plugin Version

Read `<plugin-root>/.claude-plugin/plugin.json` and extract the `version` field (currently `"1.2.0"`). This version is used in the marker section and the manifest.

## Step 4: Managed File List

These files are symlinked from the plugin root to `~/.claude/`:

```
SOUL.md
rules/security.md
rules/workflow.md
rules/agent-conventions.md
rules/notion-safety.md
standards/parallel-execution.md
standards/task-priorities.md
```

## Step 5: Create Symlinks

For each file in the managed file list:

1. Create parent directories (`~/.claude/rules/`, `~/.claude/standards/`) if they do not exist.
2. Resolve the absolute source path: `<plugin-root>/<file>`.
3. Check the destination at `~/.claude/<file>`:
   - Does not exist → create symlink → status: **created**
   - Symlink pointing to correct source → status: **unchanged**
   - Symlink pointing elsewhere → replace → status: **updated**
   - Regular file → back up to `~/.claude/.soul-backups/<file>` → replace with symlink → status: **migrated**
4. Create symlink: `ln -sf <source> <destination>`

## Step 5a: Cleanup Stale Files

If the previous manifest exists (from Step 2), compare its `files` list to the current managed file list (Step 4). For files in the old list but NOT in the new list:

- Symlink pointing to plugin root → remove it
- Regular file → leave alone (user-created)
- Report removed files in summary

## Step 6: Manage CLAUDE.md Marker Section

Generate the marker section from the managed file list and plugin version:

```markdown
<!-- SOUL:BEGIN v1.2.0 -->
@SOUL.md
@standards/parallel-execution.md
@standards/task-priorities.md
<!-- SOUL:END -->
```

Rules in `~/.claude/rules/` auto-load — no `@` imports needed. The version in `<!-- SOUL:BEGIN -->` must match the plugin version from step 3.

Handle three scenarios:

### No `~/.claude/CLAUDE.md` exists
Create the file with just the marker section as its content.

### CLAUDE.md exists but contains no `<!-- SOUL:BEGIN` marker
Prepend the marker section at the very top, followed by a blank line, then the entire existing content. Do not modify any existing content.

### CLAUDE.md exists and contains markers
Replace everything from the `<!-- SOUL:BEGIN` line through the `<!-- SOUL:END -->` line (inclusive) with the new marker section. Preserve all content before and after the markers exactly as-is.

## Step 7: Write Manifest

Write `~/.claude/.soul-manifest.json` with the following content:

```json
{
  "version": "<plugin version>",
  "install_type": "symlink",
  "installed_at": "<ISO 8601 timestamp>",
  "plugin_root": "<absolute path to plugin root>",
  "files": [
    "SOUL.md",
    "rules/security.md",
    "rules/workflow.md",
    "rules/agent-conventions.md",
    "rules/notion-safety.md",
    "standards/parallel-execution.md",
    "standards/task-priorities.md"
  ]
}
```

Use the current UTC time for `installed_at` in ISO 8601 format (e.g., `2025-01-15T14:30:00Z`).

## Step 8: Check for Duplicate Hooks

Read `~/.claude/settings.json` if it exists. Scan for any `hooks` entries that reference these script names:

- `guard-destructive-git`
- `validate-git-c`
- `guard-sensitive-files`
- `pre-push-review`

If any are found, warn the user: these hooks are now provided by the claude-9 plugin and the duplicate entries in `settings.json` should be removed to avoid double-execution.

## Step 9: Report

Output a summary with:

1. **Install type**: Whether this was a fresh install or an upgrade (and from which version to which version).
2. **Managed files table**: A table showing each file and its status (created / updated / unchanged / migrated).
3. **Stale files**: Any files removed during cleanup (Step 5a).
4. **CLAUDE.md status**: Whether it was created, updated (markers replaced or prepended), or already correct.
5. **Warnings**: Any duplicate hook warnings from step 8.
6. **Next step**: Instruct the user to restart Claude Code for changes to take effect.
