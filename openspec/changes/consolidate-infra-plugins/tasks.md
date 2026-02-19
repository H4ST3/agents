## 1. Move kubernetes-operations skills to cloud-infrastructure

- [x] 1.1 `git mv plugins/kubernetes-operations/skills/gitops-workflow/ plugins/cloud-infrastructure/skills/gitops-workflow/`
- [x] 1.2 `git mv plugins/kubernetes-operations/skills/helm-chart-scaffolding/ plugins/cloud-infrastructure/skills/helm-chart-scaffolding/`
- [x] 1.3 `git mv plugins/kubernetes-operations/skills/k8s-manifest-generator/ plugins/cloud-infrastructure/skills/k8s-manifest-generator/`
- [x] 1.4 `git mv plugins/kubernetes-operations/skills/k8s-security-policies/ plugins/cloud-infrastructure/skills/k8s-security-policies/`

## 2. Remove duplicate agents

- [x] 2.1 Delete `plugins/kubernetes-operations/agents/kubernetes-architect.md` (duplicate of cloud-infrastructure's)
- [x] 2.2 Delete `plugins/cicd-automation/agents/devops-troubleshooter.md` (duplicate of incident-response's)

## 3. Delete kubernetes-operations plugin

- [x] 3.1 Delete remaining `plugins/kubernetes-operations/.claude-plugin/plugin.json`
- [x] 3.2 Delete the `plugins/kubernetes-operations/` directory entirely

## 4. Update plugin manifests

- [x] 4.1 Update `plugins/cloud-infrastructure/.claude-plugin/plugin.json`: author to "Christopher Allen", version to 1.3.0, expand description to include Kubernetes operations
- [x] 4.2 Update `plugins/cicd-automation/.claude-plugin/plugin.json`: version to 1.3.1

## 5. Update marketplace.json

- [x] 5.1 Remove kubernetes-operations entry from `.claude-plugin/marketplace.json`
- [x] 5.2 Update cloud-infrastructure entry: version to 1.3.0, author to "Christopher Allen", expand description, update homepage
- [x] 5.3 Update cicd-automation entry: version to 1.3.1
- [x] 5.4 Bump marketplace version from 3.0.0 to 4.0.0 (breaking: plugin removed)
- [x] 5.5 Update marketplace description plugin count from 29 to 28

## 6. Verify

- [x] 6.1 Confirm kubernetes-architect.md exists only in cloud-infrastructure
- [x] 6.2 Confirm devops-troubleshooter.md exists only in incident-response
- [x] 6.3 Confirm all 4 skills exist in cloud-infrastructure with subdirectories intact
- [x] 6.4 Confirm kubernetes-operations directory no longer exists
