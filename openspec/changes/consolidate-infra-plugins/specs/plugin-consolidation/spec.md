## ADDED Requirements

### Requirement: Kubernetes skills belong in cloud-infrastructure
All Kubernetes operational skills (gitops-workflow, helm-chart-scaffolding, k8s-manifest-generator, k8s-security-policies) SHALL reside in the cloud-infrastructure plugin alongside the existing kubernetes-architect agent and service mesh skills.

#### Scenario: Skills moved with full directory structure
- **WHEN** the consolidation is complete
- **THEN** the 4 skill directories (with all references, assets, and scripts) SHALL exist under `plugins/cloud-infrastructure/skills/`
- **AND** no files SHALL be lost during the move (references/, assets/, scripts/ subdirectories preserved)

#### Scenario: Skills function identically after move
- **WHEN** a skill is invoked after consolidation
- **THEN** it SHALL behave identically to before the move (no content changes, only location changes)

### Requirement: No duplicate agents across plugins
Each agent name SHALL exist in exactly one plugin. Duplicate agents SHALL be removed from the non-canonical plugin.

#### Scenario: kubernetes-architect duplicate removed
- **WHEN** consolidation is complete
- **THEN** `kubernetes-architect.md` SHALL exist only in `plugins/cloud-infrastructure/agents/`
- **AND** `kubernetes-architect.md` SHALL NOT exist in `plugins/kubernetes-operations/agents/`

#### Scenario: devops-troubleshooter duplicate removed
- **WHEN** consolidation is complete
- **THEN** `devops-troubleshooter.md` SHALL exist only in `plugins/incident-response/agents/`
- **AND** `devops-troubleshooter.md` SHALL NOT exist in `plugins/cicd-automation/agents/`

### Requirement: Empty plugins are deleted
When a plugin has no unique agents, skills, commands, rules, or hooks remaining after consolidation, the entire plugin directory SHALL be deleted.

#### Scenario: kubernetes-operations deleted after content moved
- **WHEN** all kubernetes-operations skills have been moved to cloud-infrastructure
- **AND** the only agent was a duplicate that has been removed
- **THEN** the entire `plugins/kubernetes-operations/` directory SHALL be deleted

### Requirement: Plugin manifests reflect current state
Plugin manifests SHALL accurately reflect the plugin's contents and use the correct author attribution.

#### Scenario: cloud-infrastructure manifest updated
- **WHEN** consolidation is complete
- **THEN** `plugins/cloud-infrastructure/.claude-plugin/plugin.json` SHALL have author "Christopher Allen"
- **AND** the version SHALL be bumped (minor version increment)
- **AND** the description SHALL mention Kubernetes operations content

#### Scenario: cicd-automation manifest updated
- **WHEN** the duplicate agent is removed from cicd-automation
- **THEN** `plugins/cicd-automation/.claude-plugin/plugin.json` version SHALL be bumped (patch increment)
