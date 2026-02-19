## Context

The agents repo has 3 infrastructure-related plugins that overlap:
- **cloud-infrastructure** (v1.2.2): 6 agents, 8 skills — the primary infrastructure plugin
- **kubernetes-operations** (v1.2.1): 1 agent (exact duplicate), 4 unique K8s skills
- **cicd-automation** (v1.3.0): 2 agents (1 duplicate of incident-response), 3 skills, 2 commands

kubernetes-operations is functionally a subset of cloud-infrastructure — its only agent is a copy, and its skills (GitOps, Helm, K8s manifests, K8s security) complement the existing kubernetes-architect agent and service mesh skills already in cloud-infrastructure. cicd-automation is a separate concern (CI/CD pipelines) and stays independent.

## Goals / Non-Goals

**Goals:**
- Merge kubernetes-operations skills into cloud-infrastructure
- Remove duplicate agents (kubernetes-architect from k8s-ops, devops-troubleshooter from cicd-automation)
- Delete the now-empty kubernetes-operations plugin
- Update cloud-infrastructure authorship to Christopher Allen
- Bump versions appropriately

**Non-Goals:**
- Merging cicd-automation into cloud-infrastructure (different domain)
- Renaming incident-response debug agents (separate concern, separate change)
- Modifying any skill or agent content (move only, no edits)
- Updating kubernetes-operations author (plugin is being deleted)

## Decisions

### Decision 1: Move skills via git mv

**Choice**: Use `git mv` to move kubernetes-operations skills into cloud-infrastructure.

**Rationale**: Preserves git history for the skill files. Each skill directory has subdirectories (references/, assets/, scripts/) that must move intact.

**Files to move**:
- `plugins/kubernetes-operations/skills/gitops-workflow/` → `plugins/cloud-infrastructure/skills/gitops-workflow/`
- `plugins/kubernetes-operations/skills/helm-chart-scaffolding/` → `plugins/cloud-infrastructure/skills/helm-chart-scaffolding/`
- `plugins/kubernetes-operations/skills/k8s-manifest-generator/` → `plugins/cloud-infrastructure/skills/k8s-manifest-generator/`
- `plugins/kubernetes-operations/skills/k8s-security-policies/` → `plugins/cloud-infrastructure/skills/k8s-security-policies/`

### Decision 2: Version bumps

**Choice**: cloud-infrastructure 1.2.2 → 1.3.0 (minor), cicd-automation 1.3.0 → 1.3.1 (patch).

**Rationale**: cloud-infrastructure gains new skills (feature addition = minor bump). cicd-automation loses a duplicate agent that exists elsewhere (no user-facing functionality change = patch bump).

### Decision 3: Update cloud-infrastructure description

**Choice**: Expand description to mention Kubernetes operations content now included.

**Rationale**: The plugin now covers K8s operational workflows (GitOps, Helm, manifests, security policies) in addition to architecture. The description should reflect this.

## Risks / Trade-offs

- **Marketplace references**: If any marketplace.json or external config references kubernetes-operations by name, those references will break. Mitigation: check marketplace.json and update if needed.
- **Skill path changes**: Skills move from `kubernetes-operations/skills/` to `cloud-infrastructure/skills/`. Since skills are discovered by directory convention, the new location will be auto-discovered. No path references to update.
