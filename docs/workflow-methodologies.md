# Workflow Methodologies

This workspace includes two spec-driven development plugins that solve overlapping problems. This guide explains each approach, their overlap, and when to use which.

## Conductor

**Context-Driven Development with enforced TDD.** Conductor creates "tracks" (scoped work units) with specifications, phased plans, and task breakdowns. It implements via strict Red-Green-Refactor with coverage gates, phase verification checkpoints, and git-aware semantic revert.

**Workflow:** Setup → New Track (spec + plan) → Implement (TDD per task) → Verify → Commit

Key characteristics:

- **Full lifecycle management** from project setup through implementation
- Generates `product.md`, `tech-stack.md`, `workflow.md`, `tracks/`
- Phase gates with manual checkpoint approval
- 80% coverage targets per task
- Git-aware revert by logical unit (track/phase/task)
- Fixed naming conventions and track lifecycle

## OpenSpec

**Lightweight spec-driven change management.** OpenSpec separates "what is" (`specs/`) from "what will change" (`changes/`) using a two-folder model. It guides development through an artifact pipeline without prescribing implementation methodology.

**Workflow:** new → proposal → specs → design → tasks → apply → verify → archive

Key characteristics:

- **Focused solely on spec and change management**
- Schema-driven (different workflows for different change types)
- Brownfield-first -- designed for evolving existing systems
- Low ceremony -- no mandatory TDD gates or phase approvals
- Composable with other plugins for TDD, review, and git workflows

## Feature Comparison

| Aspect | Conductor | OpenSpec |
| --- | --- | --- |
| Philosophy | Prescribed lifecycle | Composable primitives |
| Ceremony | High (tracks, phases, gates) | Low (new → apply → archive) |
| TDD | Built-in Red-Green-Refactor | Compose via `superpowers:test-driven-development` |
| Code review | Built-in gates | Compose via `code-review:code-review` |
| Git operations | Built-in semantic revert | Compose via `git-pr-workflows:git-workflow` |
| Spec management | Per-track spec.md | Dedicated `specs/` + `changes/` separation |
| Brownfield support | Detected at setup | Core design principle |
| Verification | Mandatory phase checkpoints | On-demand via `/openspec:verify` |
| Context bootstrap | Full (product, tech stack, workflow) | None (spec/change only) |

## Plugin Overlap

Conductor bundles capabilities that are also available as discrete plugins elsewhere in the workspace:

| Conductor Capability | Equivalent Plugin |
| --- | --- |
| TDD enforcement | `superpowers:test-driven-development` |
| Phase verification | `superpowers:verification-before-completion` |
| Code review gates | `superpowers:requesting-code-review`, `code-review:code-review` |
| Git-aware operations | `superpowers:finishing-a-development-branch`, `git-pr-workflows:git-workflow` |
| Plan creation | `superpowers:writing-plans`, `superpowers:executing-plans` |
| Debugging workflow | `superpowers:systematic-debugging` |
| Parallel execution | `superpowers:dispatching-parallel-agents` |

This means Conductor's unique remaining value is **context artifact management** (`product.md`, `tech-stack.md`, `tracks.md`) and the **integrated spec → plan → task hierarchy**. OpenSpec covers spec and change management independently, and the other capabilities compose in as needed.

## Recommendation: OpenSpec for Agentic Workflows

When development cycles are driven by AI agents executing in parallel, **OpenSpec with composable plugins** is the preferred approach:

1. **Rigid pipelines become friction.** Conductor enforces a specific ceremony per task -- every task goes through Red-Green-Refactor, every phase needs manual checkpoint approval. When parallel agents can implement, test, and review in minutes, this pipeline slows things down rather than adding discipline.

2. **Composable primitives adapt per-task.** With OpenSpec, you can skip TDD for a quick config change, enforce it for core logic, and run code review only on significant changes. The spec layer stays consistent regardless. A monolithic workflow cannot offer this flexibility.

3. **OpenSpec focuses on what's actually unique.** Every advantage Conductor has over OpenSpec -- TDD, review, git, verification -- is already available as a discrete skill. OpenSpec handles the one thing nothing else does: structured spec and change management.

4. **Lower ceremony means faster iteration.** In an environment where development cycles are accelerating, the overhead of track setup, phase gates, and mandatory approvals creates friction that outweighs the discipline it provides.

## When Conductor Is the Better Fit

Conductor remains valuable in specific situations:

- **Greenfield projects** needing full context bootstrapping (product vision, tech stack, workflow preferences, style guides)
- **Teams requiring enforced discipline** where mandatory TDD gates and phase approvals prevent shortcuts
- **Environments without the superpowers plugin ecosystem** where Conductor's bundled capabilities fill real gaps
- **Onboarding new contributors** who benefit from a prescribed, step-by-step workflow rather than composable primitives
