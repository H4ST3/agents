# Curation Notes

Reference material for maintaining the h4st3/agents marketplace. Documents known overlap, redundancy, and consolidation opportunities in the upstream plugin library (wshobson/agents).

Last reviewed: 2026-03-27 (against upstream commit `91fe43e`)

## Known Plugin Overlap

### cloud-infrastructure ↔ kubernetes-operations
Heavy overlap in Kubernetes tooling. cloud-infrastructure has terraform, multi-cloud, and service mesh skills. kubernetes-operations has k8s manifests, helm charts, gitops, and k8s security. The upstream maintains both as separate plugins, but a significant portion of kubernetes-operations content is cloud-infrastructure-adjacent.

Skills that overlap or are closely related:
- k8s-manifest-generator, k8s-security-policies, helm-chart-scaffolding, gitops-workflow (kubernetes-operations) vs terraform-module-library, cost-optimization (cloud-infrastructure)
- Service mesh skills (istio, linkerd, mtls, service-mesh-observability) exist in cloud-infrastructure but relate to k8s networking

### cicd-automation agent duplication
cicd-automation contains agents that duplicate content in other plugins:
- `cloud-architect.md` — overlaps with cloud-infrastructure's scope
- `kubernetes-architect.md` — overlaps with kubernetes-operations
- `terraform-specialist.md` — overlaps with cloud-infrastructure
- `deployment-engineer.md` — also appears in cloud-infrastructure

### developer-essentials internal redundancy
- `monorepo-architect.md` agent overlaps with `monorepo-management` and `nx-workspace-patterns` skills in the same plugin
- The agent provides high-level guidance that the skills already cover in more detail

### observability-monitoring agent scope creep
- `database-optimizer.md` — database optimization is out of scope for an observability plugin
- `network-engineer.md` — network engineering is out of scope for an observability plugin

### incident-response
- `code-reviewer.md` agent — code review is out of scope for incident response; better served by developer-essentials or a dedicated review plugin

## Consolidation History

During the 2026-03 curation (pre-fork-reset), the following consolidations were attempted:
- kubernetes-operations → merged into cloud-infrastructure (5982-line diff)
- Multiple agents consolidated from deleted plugins into cicd-automation (1352 lines) and observability-monitoring (1762 lines)

These consolidations were structurally sound but unmaintainable as fork diffs. After the fork reset, all upstream plugins exist independently again. The marketplace.json selects which plugins are installed — consolidation is not necessary for curation.

## Implications for Future Curation

1. **Don't consolidate across plugins in the fork.** If upstream has redundancy, either live with it or propose consolidation upstream via PR.
2. **Marketplace selection handles overlap.** If cloud-infrastructure and kubernetes-operations overlap, just pick one (or both) in marketplace.json. No need to merge content.
3. **Agent duplication is an upstream issue.** The same agent archetype (cloud-architect, deployment-engineer) appearing in multiple plugins is a wshobson/agents structural problem. Consider filing upstream issues.
