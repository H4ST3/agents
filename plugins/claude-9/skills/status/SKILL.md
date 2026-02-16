---
name: status
description: Check claude-9 installation health — version, managed files, CLAUDE.md integration, hook status.
user-invocable: true
allowed-tools: Read, Bash, Glob, Grep
---

# Status: Check claude-9 Installation Health

Verify the claude-9 plugin installation is intact and up to date. Reports on version state, managed files, CLAUDE.md integration, and hook configuration.

## Step 1: Read Manifest

Read `~/.claude/.soul-manifest.json`.

- **If it does not exist**: Report "claude-9 is NOT installed" and suggest running `/claude-9:setup`. Stop here — no further checks are possible.
- **If it exists**: Extract `version`, `installed_at`, and the `files` array. Continue to the remaining steps.

## Step 2: Read Plugin Version

Determine the plugin root — it is 3 directory levels up from this SKILL.md file:

```
plugins/claude-9/skills/status/SKILL.md   <- this file
plugins/claude-9/                          <- plugin root
```

Read `<plugin-root>/.claude-plugin/plugin.json` and extract the `version` field.

Compare installed version (from manifest) vs plugin version:

- **If they match**: Status is "Up to date".
- **If they differ**: Flag as "Version drift" and recommend running `/claude-9:setup` to update.

## Step 3: Verify Managed Files Exist

For each file in the manifest's `files` array, check whether `~/.claude/<file>` exists on disk.

Track the status of each file: **Present** or **MISSING**.

## Step 4: Check CLAUDE.md Marker Section

Read `~/.claude/CLAUDE.md`.

1. Check if the file contains a `<!-- SOUL:BEGIN` marker line.
2. **If the marker is missing**: Flag as "marker section not found — run /claude-9:setup".
3. **If the marker is present**: Read the content between `<!-- SOUL:BEGIN` and `<!-- SOUL:END -->` (inclusive). Verify that every file from the manifest's `files` array appears as an `@<file>` import within the marker block. Report any missing imports.

## Step 5: Check for Duplicate Hooks in settings.json

Read `~/.claude/settings.json` if it exists.

Scan for any `hooks` entries that reference these script names:

- `guard-destructive-git`
- `validate-git-c`
- `guard-sensitive-files`
- `pre-push-review`

If any are found, warn the user that these hooks are now provided by the claude-9 plugin and the duplicate entries in `settings.json` should be removed to avoid double-execution.

If `settings.json` does not exist, or no duplicates are found, report clean.

## Step 6: Output Status Report

Format the results as a clear status report:

```
## claude-9 Status

**Installed version**: <manifest version>
**Plugin version**: <plugin.json version>
**Installed at**: <manifest installed_at>
**Status**: Up to date (or Version drift — run /claude-9:setup to update)

### Managed Files

| File | Status |
|------|--------|
| soul.md | Present |
| rules/python.md | Present |
| rules/security.md | MISSING |
| ... | ... |

### CLAUDE.md Integration

Marker section present with all @imports
(or issues found — describe what is missing or broken)

### Hook Status

Plugin hooks active, no duplicates in settings.json
(or duplicate hooks found — list them and recommend removal)
```

Use checkmark and warning indicators to make the report scannable. If any section has issues, include a clear recommendation for how to fix it (typically: run `/claude-9:setup`).
