# Agent Library - Tightly Controlled Source

> **Private fork of wshobson/agents** — Curated agent collection for personal projects

A streamlined, production-focused agent library for Claude Code. This is a tightly controlled fork containing only the agents, skills, and plugins needed for my personal development workflow.

## Philosophy

This repository follows a **minimal, curated** approach:

- **Quality over quantity** - Only proven, actively-used agents
- **Zero bloat** - Removed 40+ unused plugins from upstream
- **Security-first** - Custom security baseline and guidelines (see `SECURITY_BASELINE.md`)
- **Strict version control** - All changes reviewed before merge
- **No marketplace dependencies** - Self-contained and isolated

## What's Included

### Core Plugins (29 retained)

**Development & Workflows:**
- `agent-orchestration`, `agent-teams`, `conductor`
- `debugging`
- `developer-essentials`, `git-pr-workflows`

**Infrastructure & Operations:**
- `kubernetes-operations`, `cloud-infrastructure`, `cicd-automation`
- `observability-monitoring`, `incident-response`

**Data & AI:**
- `data-engineering`, `machine-learning-ops`
- `database`

**Documentation & Testing:**
- `documentation`, `c4-architecture`

**Domain-Specific:**
- `quantitative-trading` (investments project)
- `seo-*` (content and analysis)
- `business-analytics`, `customer-sales-automation`
- `content-marketing`, `hr-legal-compliance`
- `shell-scripting`

### What Was Removed

41 plugins removed for being unused, overly specialized, or outside my stack:

- Language-specific plugins (Python, JS/TS, Rust, Go, Java, etc.)
- Framework-specific agents (Django, FastAPI, React, etc.)
- Niche domains (blockchain, gaming, embedded, reverse engineering)
- Redundant review/quality plugins
- Migration and refactoring tooling

These can be pulled from upstream if needed, but default is minimal.

## Repository Structure

```
agents/
├── .claude-plugin/
│   └── marketplace.json          # Plugin registry
├── plugins/                       # 29 curated plugins
│   ├── agent-orchestration/
│   ├── conductor/
│   ├── kubernetes-operations/
│   └── ... (26 more)
├── docs/                          # Original documentation
├── tools/                         # Utility scripts
├── SECURITY_BASELINE.md           # Security requirements
└── README.md                      # This file
```

## Installation

This is a **private fork**, not the public marketplace. To use:

```bash
# Clone into ~/projects/agents (already done)
cd ~/projects/agents

# Symlink to Claude Code plugins directory (if needed)
ln -s ~/projects/agents ~/.claude/plugins/h4st3-agents

# Or reference directly in project .claude config
```

## Usage

Reference agents by their plugin name:

```bash
# Use conductor for context-driven development
/conductor:setup

# Launch agent orchestration
/agent-orchestration:orchestrate

# Kubernetes operations
/kubernetes-operations:deploy
```

## Maintenance

### Updating from Upstream

```bash
# Check upstream for useful changes
git fetch upstream
git log upstream/main --oneline -20

# Cherry-pick specific commits (never merge wholesale)
git cherry-pick <commit-hash>
```

### Adding New Plugins

1. **Justify the addition** - Must solve a real, current need
2. **Review security** - Check against `SECURITY_BASELINE.md`
3. **Test in isolation** - Verify no conflicts with existing agents
4. **Document usage** - Update this README

### Rules

- **No bulk merges from upstream** - This defeats the purpose of curation
- **Remove before adding** - If adding a plugin, consider what to remove
- **Security review required** - All new agents must pass security baseline
- **Test before commit** - Agents must work as intended
- **Keep README current** - Document changes immediately

## Security

See `SECURITY_BASELINE.md` for:
- Agent sandboxing requirements
- Secrets management rules
- External API call policies
- Human-in-the-loop (HITL) gates

See `README-SECURITY.md` for security guidelines specific to this repository.

## Differences from Upstream

| Aspect | Upstream (wshobson/agents) | This Fork (H4ST3/agents) |
|--------|---------------------------|--------------------------|
| **Focus** | Comprehensive marketplace | Curated personal library |
| **Plugin Count** | 73 plugins | 29 plugins (60% reduction) |
| **Maintenance** | Community contributions | Single maintainer (strict) |
| **Updates** | Frequent additions | Cherry-picked only |
| **Security** | Standard practices | Custom baseline required |
| **Purpose** | Public consumption | Private workflow |

## Related Projects

This agent library is used across multiple projects in `~/projects`:

- **grantwiser** - Grant management platform
- **cja-systems** - Business development operations
- **atlas** - Personal AI assistant
- **investments** - Quantitative trading
- **Internal tools** - Various automation

See `~/projects/CLAUDE.md` for workspace-level agent routing.

## License

Inherits MIT license from upstream `wshobson/agents`.

Modifications and security additions © 2024 Chris Anderson (H4ST3).

---

**Upstream:** [wshobson/agents](https://github.com/wshobson/agents)
**This Fork:** https://github.com/H4ST3/agents (private)
