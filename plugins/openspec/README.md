# OpenSpec - Spec-Driven Development Plugin for Claude Code

OpenSpec provides lightweight, spec-driven change management. It separates "what is" (`specs/`) from "what will change" (`changes/`) and guides development through an artifact pipeline: **proposal → specs → design → tasks → implementation**.

## Philosophy

- **Composable over prescribed** -- works alongside existing TDD, code review, and git plugins
- **Brownfield-first** -- designed for evolving existing systems, not just greenfield projects
- **Low ceremony** -- fast iteration for agentic workflows without mandatory gates or approvals
- **Schema-driven** -- different workflows for different change types

## Prerequisites

- Node.js 18+
- `npm install -g @fission-ai/openspec@latest`

## Commands

| Command                | Description                                                  |
| ---------------------- | ------------------------------------------------------------ |
| `/openspec:new`        | Create a new change with scaffolded artifacts                |
| `/openspec:ff`         | Fast-forward: create all artifacts at once                   |
| `/openspec:continue`   | Resume working on existing change, create next artifact      |
| `/openspec:apply`      | Implement tasks from a change                                |
| `/openspec:verify`     | Verify implementation matches artifacts                      |
| `/openspec:archive`    | Move completed change to archive                             |
| `/openspec:bulk-archive` | Archive multiple changes at once                           |
| `/openspec:explore`    | Enter thinking mode to explore before changing               |
| `/openspec:sync`       | Sync artifact changes from external source                   |
| `/openspec:onboard`    | Guided tutorial: walk through full cycle                     |

## Workflow

The artifact lifecycle follows a linear pipeline:

1. **New** (`/openspec:new`) -- Create a change directory with initial scaffolding
2. **Proposal** -- Define what you want to change and why
3. **Specs** -- Capture the current state of affected components
4. **Design** -- Describe the target state and approach
5. **Tasks** -- Break the design into implementable units
6. **Apply** (`/openspec:apply`) -- Implement each task against the codebase
7. **Verify** (`/openspec:verify`) -- Confirm implementation matches artifacts
8. **Archive** (`/openspec:archive`) -- Move completed change out of active work

Use `/openspec:ff` to collapse steps 2-5 into a single pass when the change is well-understood. Use `/openspec:continue` to pick up where you left off if interrupted mid-pipeline.

## Two-Folder Model

OpenSpec maintains a strict separation between current state and proposed changes:

- **`specs/`** -- Source of truth. Documents what the system **is** today. Updated only after changes land. Treat these as living documentation of the current architecture, APIs, and behavior.
- **`changes/`** -- Proposals. Documents what **will change**. Each change gets its own directory with proposal, design, and task artifacts. Archived or deleted after implementation.

This separation ensures specs always reflect reality, not intent. Changes reference specs but never modify them directly -- specs are updated as a final step after implementation is verified.

## Installation

```bash
/plugin install openspec
```

## License

MIT
