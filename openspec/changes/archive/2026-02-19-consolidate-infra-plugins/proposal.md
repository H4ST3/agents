## Why

The plugin library has three overlapping infrastructure plugins (cloud-infrastructure, kubernetes-operations, cicd-automation) with duplicate agents across them. kubernetes-operations contains a single agent that is an exact copy of one in cloud-infrastructure, plus 4 unique K8s skills that belong in cloud-infrastructure. cicd-automation has a duplicate devops-troubleshooter agent that already exists in incident-response. Consolidating reduces confusion and eliminates duplicate agent registrations.

## What Changes

- Move all 4 kubernetes-operations skills (gitops-workflow, helm-chart-scaffolding, k8s-manifest-generator, k8s-security-policies) into cloud-infrastructure
- Delete the duplicate kubernetes-architect agent from kubernetes-operations (canonical copy stays in cloud-infrastructure)
- Delete the kubernetes-operations plugin entirely (no unique agents remain)
- Delete the duplicate devops-troubleshooter agent from cicd-automation (canonical copy stays in incident-response)
- Update cloud-infrastructure author from "Seth Hobson" to "Christopher Allen"
- Version bumps for cloud-infrastructure and cicd-automation

## Capabilities

### New Capabilities
- `plugin-consolidation`: Consolidating plugins by moving skills, removing duplicate agents, and deleting empty plugins

### Modified Capabilities

## Impact

- `plugins/cloud-infrastructure/` — gains 4 skills (with references, assets, scripts), author update, version bump
- `plugins/cicd-automation/` — loses 1 duplicate agent, version bump
- `plugins/kubernetes-operations/` — deleted entirely
