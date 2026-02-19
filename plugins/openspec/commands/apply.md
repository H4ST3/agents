---
description: "Implement tasks from an OpenSpec change"
argument-hint: "[change-name]"
---

Implement tasks from an OpenSpec change.

**Step 0: Verify CLI**

Run: `which openspec >/dev/null 2>&1 || echo "NOT_INSTALLED"`

If NOT_INSTALLED, tell the user: "OpenSpec CLI is not installed. Install with: `npm install -g @fission-ai/openspec@latest`" and stop.

**Input**: Optionally specify a change name (e.g., `/openspec:apply add-auth`). If omitted, check if it can be inferred from conversation context. If vague or ambiguous you MUST prompt for available changes.

**Steps**

1. **Select the change**

   If a name is provided, use it. Otherwise:
   - Infer from conversation context if the user mentioned a change
   - Auto-select if only one active change exists
   - If ambiguous, run `openspec list --json` to get available changes and use the **AskUserQuestion tool** to let the user select

   Always announce: "Using change: <name>" and how to override (e.g., `/openspec:apply <other>`).

2. **Check status to understand the schema**
   ```bash
   openspec status --change "<name>" --json
   ```
   Parse the JSON to understand:
   - `schemaName`: The workflow being used (e.g., "spec-driven")
   - Which artifact contains the tasks (typically "tasks" for spec-driven, check status for others)

3. **Get apply instructions**

   ```bash
   openspec instructions apply --change "<name>" --json
   ```

   This returns:
   - Context file paths (varies by schema)
   - Progress (total, complete, remaining)
   - Task list with status
   - Dynamic instruction based on current state

   **Handle states:**
   - If `state: "blocked"` (missing artifacts): show message, suggest using `/openspec:continue`
   - If `state: "all_done"`: congratulate, suggest archive
   - Otherwise: proceed to implementation

4. **Read context files**

   Read the files listed in `contextFiles` from the apply instructions output.
   The files depend on the schema being used:
   - **spec-driven**: proposal, specs, design, tasks
   - Other schemas: follow the contextFiles from CLI output

5. **Show current progress**

   Display:
   - Schema being used
   - Progress: "N/M tasks complete"
   - Remaining tasks overview
   - Dynamic instruction from CLI

6. **Classify tasks before starting**

   Before the implementation loop, assess pending tasks:
   - **Independence**: Which tasks touch different files/modules with no shared state?
   - **Complexity**: Simple (single-file, clear change) vs. complex (multi-file, architectural)
   - **Dependencies**: Which tasks must complete before others can start?

   Independent tasks can be dispatched to subagents in parallel. Dependent or overlapping tasks must run sequentially. Briefly announce the execution approach.

7. **Implement tasks (loop until done or blocked)**

   **Do NOT implement tasks inline.** Delegate each task to a focused subagent via the Task tool.

   For each pending task (or parallel batch of independent tasks):
   - Show which task(s) are being worked on
   - Dispatch to subagent:
     - `subagent_type: solution-architect` for complex multi-file tasks
     - `subagent_type: general-purpose, model: sonnet` for straightforward changes
   - Each subagent prompt must include: task description, relevant context from change artifacts, target files, and constraint to keep changes minimal and scoped
   - For independent tasks, dispatch multiple in a single message (parallel)
   - Never dispatch parallel tasks that edit the same files
   - Review subagent results; check for conflicts if parallel
   - Mark task complete in the tasks file: `- [ ]` -> `- [x]`
   - Continue to next task or batch

   **Pause if:**
   - Task is unclear -> ask for clarification
   - Subagent reports an issue or ambiguity -> escalate
   - Implementation reveals a design issue -> suggest updating artifacts
   - Parallel agents produced conflicting changes -> resolve before continuing
   - Error or blocker encountered -> report and wait for guidance
   - User interrupts

8. **On completion or pause, show status**

   Display:
   - Tasks completed this session
   - Overall progress: "N/M tasks complete"
   - If all done: suggest archive
   - If paused: explain why and wait for guidance

**Output During Implementation**

```
## Implementing: <change-name> (schema: <schema-name>)

Working on task 3/7: <task description>
[...implementation happening...]
Task complete

Working on task 4/7: <task description>
[...implementation happening...]
Task complete
```

**Output On Completion**

```
## Implementation Complete

**Change:** <change-name>
**Schema:** <schema-name>
**Progress:** 7/7 tasks complete

### Completed This Session
- [x] Task 1
- [x] Task 2
...

All tasks complete! You can archive this change with `/openspec:archive`.
```

**Output On Pause (Issue Encountered)**

```
## Implementation Paused

**Change:** <change-name>
**Schema:** <schema-name>
**Progress:** 4/7 tasks complete

### Issue Encountered
<description of the issue>

**Options:**
1. <option 1>
2. <option 2>
3. Other approach

What would you like to do?
```

**Guardrails**
- Keep going through tasks until done or blocked
- Always read context files before starting (from the apply instructions output)
- If task is ambiguous, pause and ask before implementing
- If implementation reveals issues, pause and suggest artifact updates
- Keep code changes minimal and scoped to each task
- Update task checkbox immediately after completing each task
- Pause on errors, blockers, or unclear requirements - don't guess
- Use contextFiles from CLI output, don't assume specific file names

**Fluid Workflow Integration**

This skill supports the "actions on a change" model:

- **Can be invoked anytime**: Before all artifacts are done (if tasks exist), after partial implementation, interleaved with other actions
- **Allows artifact updates**: If implementation reveals design issues, suggest updating artifacts - not phase-locked, work fluidly
