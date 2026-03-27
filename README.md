# h4st3/agents

Curated fork of [wshobson/agents](https://github.com/wshobson/agents) for personal and professional development workflows.

## Curation Model

Upstream maintains 74 plugins. This fork curates a subset via `marketplace.json` -- the sole gatekeeper for what gets installed. All upstream plugins remain on disk; uncurated plugins are simply not listed in the marketplace and are never installed.

**Do not delete plugin directories to curate.** The marketplace manifest controls installation. Physical deletion breaks upstream tracking.

## Installation

```bash
/plugin marketplace add H4ST3/agents
```

Browse and install:

```bash
/plugin
/plugin install agent-teams@h4st3-agents
```

## Curated Plugins

20 plugins selected from upstream:

| Plugin | Domain |
|--------|--------|
| agent-orchestration | Multi-agent optimization |
| agent-teams | Parallel agent coordination |
| business-analytics | KPIs, dashboards, data storytelling |
| c4-architecture | C4 model documentation |
| cicd-automation | Pipelines, GitHub Actions, GitLab CI |
| cloud-infrastructure | Terraform, multi-cloud, service mesh |
| conductor | Context-driven development |
| content-marketing | Content strategy and workflows |
| customer-sales-automation | CRM and sales workflows |
| data-engineering | Airflow, dbt, Spark, data quality |
| developer-essentials | Git, testing, debugging, code review |
| hr-legal-compliance | Employment, GDPR, compliance |
| incident-response | Runbooks, postmortems, on-call |
| machine-learning-ops | ML pipelines and model ops |
| observability-monitoring | Prometheus, Grafana, tracing, SLOs |
| quantitative-trading | Backtesting, risk metrics |
| seo-analysis-monitoring | SEO analytics |
| seo-content-creation | SEO content generation |
| seo-technical-optimization | Technical SEO |
| shell-scripting | Bash, bats testing, shellcheck |

For the full upstream collection, see [wshobson/agents](https://github.com/wshobson/agents).

## Maintenance

### Validate curation

```bash
make audit
```

Checks that every marketplace.json entry has a corresponding plugin directory.

### Sync with upstream

```bash
make sync                    # Show divergence
git fetch upstream
git merge upstream/main      # Clean merge -- no deleted-file conflicts
make audit                   # Verify marketplace entries still valid
```

After merging, review new upstream plugins and update marketplace.json if any are worth curating in.

### Curation notes

See [docs/curation-notes.md](docs/curation-notes.md) for known plugin overlap and redundancy in the upstream library.

## Upstream

- Repo: [wshobson/agents](https://github.com/wshobson/agents)
- Docs: [Plugin Reference](docs/plugins.md), [Agent Reference](docs/agents.md), [Architecture](docs/architecture.md)

## License

MIT License - see [LICENSE](LICENSE) file for details.
