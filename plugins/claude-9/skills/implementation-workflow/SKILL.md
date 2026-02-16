---
name: implementation-workflow
description: Structured workflow for implementing tasks. Walks through requirements gathering, codebase exploration, planning (with approval gate), implementation, and verification. Use when tackling non-trivial implementation tasks.
user-invocable: true
allowed-tools: Read, Grep, Glob, Edit, Write, Bash, Task
---

# /implementation-workflow

Orchestrates a structured implementation workflow for any task, from requirements through to verified code.

## Usage

```
/implementation-workflow [task description or link]
```

## Workflow Phases

Execute these phases in order, tracking progress throughout:

### Phase 1: Requirements Gathering

1. **Understand the task** — read the description, linked issues, or user story
2. **Extract details:**
   - What needs to be built or changed
   - Acceptance criteria (if defined)
   - Technical constraints or guidance
   - Dependencies or blockers
3. **Clarify ambiguities** — ask user if requirements are unclear
4. **Output:** Clear requirements summary

```markdown
## Requirements: [Task Name]

### What
[What needs to be built or changed]

### Acceptance Criteria
- [ ] Given [context], when [action], then [result]

### Technical Context
[Constraints, guidance, dependencies]

### Open Questions
[Anything unclear]
```

### Phase 2: Codebase Exploration

Use the Explore subagent to understand relevant code:

1. **Identify affected areas** — which modules, services, files
2. **Understand existing patterns** — how similar things are done in this project
3. **Map dependencies** — models, APIs, components, external services
4. **Check for blockers** — technical debt, missing prerequisites
5. **Output:** Exploration summary with file paths and patterns to follow

### Phase 3: Implementation Planning

Enter plan mode to design the approach:

1. **Break down into steps** — ordered list of changes
2. **Identify critical path** — what must be done first
3. **Estimate complexity** — flag if scope is larger than expected
4. **Define testing strategy** — what tests to write alongside code
5. **Get user approval before proceeding**

```markdown
## Implementation Plan: [Task Name]

### Approach
[1-2 sentence summary]

### Steps
1. [ ] [Change] — [file(s) affected]
2. [ ] [Change] — [file(s) affected]

### Testing Strategy
- [ ] Unit tests for [component]
- [ ] Integration test for [flow]

### Risks
- [Risk]: [Mitigation]
```

### Phase 4: Implementation

Execute the approved plan:

1. **Work through steps in order**, marking complete as you go
2. **Follow existing patterns** identified during exploration
3. **Write tests alongside code** — not after
4. **Commit incrementally** if requested (don't auto-commit)

**Quality checks during implementation:**
- Does this match the acceptance criteria?
- Are edge cases handled?
- Is error handling appropriate?
- Does it follow project conventions?

### Phase 5: Verification

Before marking complete:

1. **Run tests** — ensure all pass
2. **Verify against criteria** — check each acceptance criterion
3. **Manual verification** — guide user through testing if needed
4. **Summarize** — list all changes made

```markdown
## Completed: [Task Name]

### Changes Made
- [file:line] — [what changed]

### Tests Added
- [test file] — [what's tested]

### Acceptance Criteria Verification
- [x] [Criterion 1] ✓
- [x] [Criterion 2] ✓

### Notes
[Anything the user should know]
```

## Error Handling

**If requirements are unclear:** Stop and ask for clarification
**If scope is larger than expected:** Alert user before proceeding
**If blocked by dependencies:** Identify blockers and ask how to proceed
**If tests fail:** Fix before proceeding — do not skip failing tests

## Agent Usage

Leverage agents when appropriate:

| Agent | When to Use |
|-------|-------------|
| `solution-architect` | Complex multi-component design |
| `code-reviewer` | Pre-merge quality review |
| `acceptance-tester` | Verify against criteria after implementation |
| `cto-advisor` | Architecture decisions with significant trade-offs |
