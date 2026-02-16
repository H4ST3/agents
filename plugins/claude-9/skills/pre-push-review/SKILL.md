---
name: pre-push-review
description: Concise summary of changes about to be pushed. Analyzes commits and diffs to flag risks before pushing.
user-invocable: true
allowed-tools: Bash, Read
---

# Pre-Push Review

Analyze the current branch and produce a structured review summary of all commits that would be pushed to the remote.

## Steps

1. **Identify the branch and upstream:**
   ```bash
   git rev-parse --abbrev-ref HEAD
   git rev-parse --abbrev-ref @{upstream} 2>/dev/null || echo "no upstream"
   ```

2. **Fetch latest remote state:**
   ```bash
   git fetch --quiet
   ```

3. **Determine the comparison base:**
   - If upstream exists, use it
   - Otherwise use `origin/main` or `origin/master`

4. **Count commits ahead:**
   ```bash
   git rev-list --count <base>..HEAD
   ```

5. **Gather commit log:**
   ```bash
   git log --oneline --no-decorate <base>..HEAD
   ```

6. **Gather diff statistics:**
   ```bash
   git diff --stat <base>..HEAD
   git diff --numstat <base>..HEAD
   ```
   Categorize files as Source, Tests, or Config and tally additions/deletions per category.

7. **Scan for risk patterns** in added lines (`git diff <base>..HEAD | grep '^\+'`):
   - **Large diffs**: Files with >500 lines added
   - **Sensitive patterns**: API_KEY, SECRET, PASSWORD, PRIVATE_KEY, connection strings with credentials
   - **Debug leftovers**: `print()`, `console.log`, `breakpoint()`, `debugger`, `pdb.set_trace`
   - **TODO/FIXME/HACK**: New comments added
   - **Missing tests**: New source files without corresponding test files

8. **Output the structured summary:**

```
Pre-Push Review: <branch> → <upstream>

Commits (<N> ahead):
  <hash> <message>
  ...

Changes: <N> files | <summary line>
  Source: <N> files (+X/-Y) | Tests: <N> files (+X/-Y) | Config: <N> files (+X/-Y)

Risk Flags: <None found | list of flags>

Verdict: CLEAN | REVIEW RECOMMENDED | CAUTION
```

Verdict rules:
- **CLEAN**: No risk flags
- **REVIEW RECOMMENDED**: Non-critical flags (debug leftovers, TODOs, missing tests, large diffs)
- **CAUTION**: Sensitive patterns detected (secrets, credentials)
