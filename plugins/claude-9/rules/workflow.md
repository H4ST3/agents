# Workflow Standards

Procedural conventions for commits, output, and collaboration tools.

## Git Commit Conventions

- Format: `<type>(<scope>): <description>`
- Types: feat, fix, docs, style, refactor, test, chore
- Keep subject line under 72 characters
- Use imperative mood ("add" not "added")
- Include ticket number when available
- Do not include Co-Authored-By, Generated-By, or similar attribution lines

## GitHub Issue/PR Creation

Before creating issues or PRs with labels, milestones, or assignees:

1. Run `gh label list --limit 100` to check available labels
2. Only use labels that exist in the output
3. If a needed label is missing, either:
   - Create it: `gh label create "name" --description "desc" --color 0052CC`
   - Or omit the `--label` flag entirely

Never assume labels like 'backend', 'frontend', 'priority:high' exist — they vary by repo.

## Structured Output

When producing analysis, advisory, or review output, use this structure:

```
## Executive Summary
[2-3 sentences]

## Details
[Structured analysis]

## Recommendations
[Actionable next steps]

## Risks & Open Questions
[Anything needing human attention]
```

## Diagrams & Visualizations

Prefer Mermaid diagrams over ASCII art when creating charts, flowcharts, sequence diagrams, or other visualizations. Mermaid renders better and is easier to maintain.
