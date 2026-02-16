---
name: setup
description: Install or update claude-9 managed files to ~/.claude/. Run after first install and after plugin updates.
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Setup: Install or Update claude-9 Managed Files

Install the claude-9 plugin's managed files into `~/.claude/` and configure `CLAUDE.md` imports. Run this after first install and after every plugin update.

## Step 1: Determine Plugin Root

The plugin root is 3 directory levels up from this SKILL.md file:

```
plugins/claude-9/skills/setup/SKILL.md   <- this file
plugins/claude-9/                         <- plugin root
```

Resolve the plugin root path. All source files are read relative to it. Confirm `soul.md` exists at the plugin root before continuing.

## Step 2: Read Existing Manifest

Read `~/.claude/.soul-manifest.json` if it exists.

- **If it exists**: This is an **upgrade**. Note the `version` field for the report.
- **If it does not exist**: This is a **fresh install**.

## Step 3: Read Plugin Version

Read `<plugin-root>/.claude-plugin/plugin.json` and extract the `version` field (currently `"1.0.0"`). This version is used in the marker section and the manifest.

## Step 4: Managed File List

These files are copied from the plugin root to `~/.claude/`:

```
soul.md
rules/python.md
rules/security.md
rules/workflow.md
rules/agent-conventions.md
standards/parallel-execution.md
standards/task-priorities.md
```

## Step 5: Copy Managed Files

For each file in the managed file list:

1. Create parent directories (`~/.claude/rules/`, `~/.claude/standards/`) if they do not exist.
2. Read the source file at `<plugin-root>/<file>`.
3. Read the destination file at `~/.claude/<file>` (if it exists).
4. If the destination does not exist or its content differs from the source, write the source content to the destination.
5. Track each file's status: **created** (destination did not exist), **updated** (destination existed but content differed), or **unchanged** (content was identical).

If any file copy fails, report the failure and do not proceed to writing the manifest (Step 7).

## Step 6: Manage CLAUDE.md Marker Section

Generate the marker section from the managed file list and plugin version:

```markdown
<!-- SOUL:BEGIN v1.0.0 -->
@soul.md
@rules/python.md
@rules/security.md
@rules/workflow.md
@rules/agent-conventions.md
@standards/parallel-execution.md
@standards/task-priorities.md
<!-- SOUL:END -->
```

The version in `<!-- SOUL:BEGIN v1.0.0 -->` must match the plugin version from step 3.

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
  "installed_at": "<ISO 8601 timestamp>",
  "files": [
    "soul.md",
    "rules/python.md",
    "rules/security.md",
    "rules/workflow.md",
    "rules/agent-conventions.md",
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
2. **Managed files table**: A table showing each file and its status (created / updated / unchanged).
3. **CLAUDE.md status**: Whether it was created, updated (markers replaced or prepended), or already correct.
4. **Warnings**: Any duplicate hook warnings from step 8.
5. **Next step**: Instruct the user to restart Claude Code for changes to take effect.
