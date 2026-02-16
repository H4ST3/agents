# OpenSpec Workflow

Spec-driven development for non-trivial changes. Lightweight structure without rigid ceremony.

## When to Use

- Multi-file changes or new features → use OpenSpec
- Single-file fixes, typos, quick tweaks → skip OpenSpec, implement directly
- If unsure → use `/opsx:ff` for fast single-shot artifact generation

## Commands

| Command | When |
|---------|------|
| `/opsx:new <description>` | Start a new change — creates proposal template |
| `/opsx:continue [name]` | Create the next artifact (specs, design, or tasks) |
| `/opsx:ff <description>` | Fast-forward: generate all artifacts in one shot |
| `/opsx:apply [name]` | Implement tasks — reads all context, tracks progress |
| `/opsx:archive [name]` | Archive completed change, sync specs to source of truth |
| `/opsx:verify [name]` | Verify implementation matches specs before archiving |

## Artifact Flow

`proposal → specs + design → tasks → apply → archive`

- **proposal.md**: Why, what changes, capabilities (new/modified specs), impact
- **specs/\<capability\>/spec.md**: Testable requirements with WHEN/THEN scenarios
- **design.md**: Technical decisions with rationale and alternatives considered
- **tasks.md**: Checkboxed implementation tasks — persists across sessions

## Session Continuity

Start new sessions with `/opsx:apply <change-name>`. Artifacts carry full context. Task checkboxes track progress across sessions automatically.

## Conventions

- One active change at a time — finish and archive before starting the next
- Archive promptly after completion — promotes specs to `openspec/specs/` as source of truth
- `openspec/specs/` is cumulative across all archived changes — living documentation of capabilities
- Use `/opsx:ff` for straightforward changes; step-by-step `/opsx:continue` for complex ones needing review at each stage
- Compose with other skills as needed: TDD, code review, debugging, etc.
- Specs are testable — each WHEN/THEN scenario maps to a test case

## Spec Writing

- Use `### Requirement: <name>` for each requirement
- Use `#### Scenario: <name>` with `WHEN`/`THEN` format for each scenario
- Use SHALL/MUST for normative requirements
- Every requirement needs at least one scenario
- Scenarios should map 1:1 to test cases

## Design Decisions

- Document the "why" not just the "what"
- Include alternatives considered for each decision
- Flag risks with mitigations
- Keep open questions explicit — resolve them before or during implementation
