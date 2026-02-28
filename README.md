# Agent Library - Curated Claude Code Plugins

> **Curated fork of [wshobson/agents](https://github.com/wshobson/agents)** — Streamlined agent collection for production workflows

A streamlined, production-focused agent library for Claude Code. This is a tightly controlled fork containing only the agents, skills, and plugins needed for focused development workflows.

## Philosophy

This repository follows a **minimal, curated** approach:

- **Quality over quantity** - Only proven, actively-used agents
- **Zero bloat** - Removed 40+ unused plugins from upstream
- **Security-first** - Custom security baseline and guidelines (see `SECURITY_BASELINE.md`)
- **Strict version control** - All changes reviewed before merge
- **Marketplace-native** - Proper Claude Code plugin marketplace structure

## What's Included

### Core Plugins (27 retained)

**Development & Workflows:**
- `agent-orchestration`, `agent-teams`, `conductor`, `openspec`
- `debugging`, `developer-essentials`
- `agent-browser`, `skill-creator`

**Infrastructure & Operations:**
- `cloud-infrastructure`, `cicd-automation`
- `observability-monitoring`, `incident-response`

**Data & AI:**
- `data-engineering`, `machine-learning-ops`
- `database`

**Documentation & Testing:**
- `documentation`, `c4-architecture`

**Identity & Standards:**
- `claude-9` (portable soul plugin)

**Domain-Specific:**
- `quantitative-trading`
- `seo-analysis-monitoring`, `seo-content-creation`, `seo-technical-optimization`
- `business-analytics`, `customer-sales-automation`
- `content-marketing`, `hr-legal-compliance`
- `shell-scripting`

### What Was Removed

41 plugins removed for being unused, overly specialized, or outside this collection's focus:

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
│   └── marketplace.json          # Plugin registry (single source of truth for versions)
├── plugins/                       # 27 curated plugins
│   ├── agent-orchestration/
│   ├── claude-9/
│   ├── conductor/
│   └── ... (24 more)
├── docs/                          # Original documentation
├── tools/                         # Utility scripts (validate-marketplace.py)
├── Makefile                       # Development commands
├── SECURITY_BASELINE.md           # Security requirements
└── README.md                      # This file
```

## Installation

This is a **curated fork** distributed as a Claude Code plugin marketplace.

### Add as a marketplace (from local clone)

```bash
# In Claude Code, run:
/plugin marketplace add /path/to/agents
```

### Add as a marketplace (from GitHub)

```bash
# In Claude Code, run:
/plugin marketplace add H4ST3/agents
```

### Install individual plugins

```bash
# Browse available plugins
/plugin

# Install specific plugins
claude plugin install conductor@h4st3-agents
claude plugin install debugging@h4st3-agents
```

## Usage

Reference plugins by their namespaced name:

```bash
# Use conductor for context-driven development
/conductor:setup

# Launch agent orchestration
/agent-orchestration:orchestrate

# Use openspec for spec-driven development
/openspec:propose
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

### Version Management

**Single Source of Truth:**
- Plugin versions are defined **ONLY** in `.claude-plugin/marketplace.json`
- Individual `plugin.json` files contain identity metadata (name, author, license, description) but **no version field**
- This prevents version drift and simplifies maintenance

**Version Bump Guidelines:**
- **PATCH** (x.y.Z): Bug fixes, documentation updates, minor tweaks
- **MINOR** (x.Y.0): New commands/agents/skills added, backward-compatible features
- **MAJOR** (X.0.0): Breaking changes to existing functionality, API changes

**Validation:**
Run `make validate-marketplace` to verify:
- No phantom plugins (marketplace entry without directory)
- No orphaned plugins (directory without marketplace entry)
- No `version` fields in plugin.json files

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
| **Plugin Count** | 73 plugins | 27 plugins (63% reduction) |
| **Maintenance** | Community contributions | Single maintainer (strict) |
| **Updates** | Frequent additions | Cherry-picked only |
| **Security** | Standard practices | Custom baseline required |
| **Purpose** | Public consumption | Curated workflow |

## License

Inherits MIT license from upstream `wshobson/agents`.

Modifications and security additions © 2024 Christopher Allen (H4ST3).

---

**Upstream:** [wshobson/agents](https://github.com/wshobson/agents)
**This Fork:** https://github.com/H4ST3/agents
