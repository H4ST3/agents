# claude-9

Portable soul plugin for Claude Code. Packages personal behavioral configuration — identity, agents, hooks, skills, rules, and standards — into a single installable plugin.

## Install

```bash
claude plugin install claude-9@h4st3-agents
```

## First Run

```
/claude-9:setup
```

This copies managed files (soul, rules, standards) to `~/.claude/` and adds `@import` lines to your `CLAUDE.md`.

## Check Health

```
/claude-9:status
```

Shows installed version, managed file status, and hook health.

## What's Included

- **Soul** — identity and behavioral philosophy
- **Agents** — 6 strategic advisors, 4 execution agents, 1 operations coordinator
- **Hooks** — 4 safety hooks (destructive git guard, sensitive file guard, git -C validation, pre-push review)
- **Skills** — setup, status, escalation protocol, pre-push review, implementation workflow
- **Rules** — Python, security, workflow, agent conventions
- **Standards** — parallel execution, task priorities

## License

Personal configuration. All rights reserved. Not licensed for redistribution or reuse.
