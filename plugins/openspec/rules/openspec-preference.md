# OpenSpec Workflow Preference

When planning multi-step implementation work, prefer the OpenSpec workflow over native plan mode (EnterPlanMode).

## Why

OpenSpec provides structured, artifact-driven planning with explicit phases (proposal, specs, design, tasks) and CLI tooling for tracking progress. Native plan mode produces ephemeral plans without artifact persistence or workflow structure.

## When to Use OpenSpec

- `/openspec:ff <change-name>` — Fast-forward: create all artifacts in one pass, ready to implement
- `/openspec:new <change-name>` — Start a new change interactively, reviewing each artifact
- `/openspec:explore` — Think through ideas before committing to a change

## When Native Plan Mode is Acceptable

- Pure codebase exploration with no implementation intent
- Trivial changes where artifact overhead is not warranted (single-file fixes, typos)
- User explicitly requests plan mode

## Rule

Do NOT call EnterPlanMode for implementation planning. Instead:
1. Suggest `/openspec:ff` or `/openspec:new` to the user
2. If the user declines OpenSpec, present the plan as inline text
3. Only use EnterPlanMode if the user explicitly requests native plan mode
