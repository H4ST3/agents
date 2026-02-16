<!-- SOUL:BEGIN v1.0.0 -->
# Parallel Execution Standards

Best practices for launching subagents and parallel workloads in Claude Code.

## Concurrency Limits

| Constraint | Limit | Notes |
|-----------|-------|-------|
| **Hard cap** | 10 concurrent subagents | Platform limit; additional tasks are queued |
| **Batch behavior** | Waits for entire batch | Does NOT dynamically pull from queue as agents finish |
| **Nesting** | Not allowed | Subagents cannot spawn other subagents |

## Recommended Concurrency by Workload

| Workload | Max Agents | Examples |
|----------|-----------|----------|
| Light | 5-8 | File reads, grep, git ops, research |
| Medium | 3-4 | Builds, linting, code review |
| Heavy | 2 | Full test suites, large analysis |

## When to Parallelize

- **DO**: Independent research tasks, file exploration across unrelated modules, parallel code reviews with different focus areas
- **DON'T**: Tasks with shared state, same-file edits, sequential dependencies

## Subagents vs Agent Teams

| Use Case | Mechanism |
|----------|-----------|
| Focused tasks returning a result | Subagents (Task tool) |
| Inter-agent discussion needed | Agent Teams (experimental) |
| Context isolation / verbose output | Subagents (background) |
| Competing hypotheses / debate | Agent Teams |

## Model Selection for Parallel Work

- **opus**: Architecture decisions, complex analysis, code review
- **sonnet**: Implementation, research, testing (default)
- **haiku**: Simple lookups, formatting, data extraction — prefer for lightweight parallel tasks to reduce token burn

## Best Practices

1. **Size batches wisely**: One slow agent blocks the entire batch of 10, so group tasks of similar expected duration
2. **Push toward the limit**: Default to 5-8 agents for research/exploration, not 3
3. **Use background execution** (`run_in_background: true`) for tasks that don't need immediate results
4. **Pre-approve permissions** before spawning background subagents (they auto-deny unapproved prompts)
5. **Background agents cannot use MCP tools** — use foreground for MCP-dependent work
6. **Keep return payloads concise** — many agents returning detailed results consumes main context rapidly
7. **Design focused agents**: Each should excel at one specific task with a clear description

## Anti-Patterns

- Spawning 3 agents when 8 would be independent and safe — **under-parallelizing wastes time**
- Launching 10 heavy agents on resource-constrained systems — causes I/O storms
- Returning full verbose output from subagents — pollutes main context
- Using Agent Teams for simple delegate-and-report tasks — wastes 5x tokens
<!-- SOUL:END -->
