## ADDED Requirements

### Requirement: Explore command routes by exploration scope
The explore command SHALL present the user with a choice of exploration scope before proceeding. The options SHALL be: OpenSpec-scoped exploration (confined to change artifacts and specs), broad exploration (general codebase investigation delegating to Explore subagent), or brainstorming-first (invoke brainstorming skill before exploring). The system SHALL route to the appropriate tool or skill based on the user's selection.

#### Scenario: User selects OpenSpec-scoped exploration
- **WHEN** user invokes `/openspec:explore` and selects "OpenSpec-scoped"
- **THEN** the command operates in its current stance mode, confined to reading openspec artifacts, specs, and related codebase context
- **AND** the "never write code" guardrail remains active
- **AND** `openspec list --json` is run for context

#### Scenario: User selects broad exploration
- **WHEN** user invokes `/openspec:explore` and selects "Broad exploration"
- **THEN** the command delegates codebase investigation to an Explore subagent or general exploration flow
- **AND** the "never write code" guardrail does NOT apply
- **AND** OpenSpec context is provided if an `openspec/` directory exists but does not constrain the exploration

#### Scenario: User selects brainstorming first
- **WHEN** user invokes `/openspec:explore` and selects "Brainstorming first"
- **THEN** the command invokes the `superpowers:brainstorming` skill first
- **AND** after brainstorming completes, offers to transition into OpenSpec-scoped or broad exploration

#### Scenario: User provides topic argument
- **WHEN** user invokes `/openspec:explore <topic>` with a topic argument
- **THEN** the routing question is still presented (topic does not imply scope)
- **AND** the topic is passed through to whichever exploration mode is selected

### Requirement: Onboard command uses smart init flow
The onboard command SHALL detect whether the openspec plugin is providing Claude Code commands and avoid generating duplicate `.claude/` integration files. When initialization is needed, it SHALL use `openspec init --tools none` by default and offer other AI tool setup.

#### Scenario: Project needs initialization with plugin active
- **WHEN** the onboard command runs and no `openspec/` directory exists
- **AND** the command is executing as a plugin command (plugin is active)
- **THEN** the command SHALL ask the user if they need OpenSpec setup for other AI tools
- **AND** if no other tools needed, run `openspec init --tools none`
- **AND** if other tools selected, run `openspec init --tools <comma-separated-selection>` excluding `claude`

#### Scenario: Project already initialized
- **WHEN** the onboard command runs and `openspec/` directory exists
- **THEN** initialization is skipped entirely and onboarding proceeds

#### Scenario: CLI not installed
- **WHEN** the onboard command runs and `which openspec` fails
- **THEN** the command SHALL display install instructions and stop

### Requirement: All commands use consistent prefix
All command files SHALL reference other openspec commands using the `/openspec:*` prefix exclusively. No references to `/opsx:*` SHALL remain in any command file.

#### Scenario: Internal cross-references
- **WHEN** a command file references another openspec command (e.g., suggesting next steps)
- **THEN** it SHALL use `/openspec:*` prefix (e.g., `/openspec:apply`, `/openspec:new`)

### Requirement: CLI-dependent commands detect installation
Commands that invoke the `openspec` CLI SHALL verify the CLI is available at runtime before proceeding. If the CLI is not found, the command SHALL display installation instructions and stop execution.

#### Scenario: CLI available
- **WHEN** a command runs its CLI detection check and `openspec` is found in PATH
- **THEN** the command proceeds normally

#### Scenario: CLI not available
- **WHEN** a command runs its CLI detection check and `openspec` is not found in PATH
- **THEN** the command SHALL output: "OpenSpec CLI is not installed. Install with: `npm install -g @fission-ai/openspec@latest`"
- **AND** the command SHALL stop execution

#### Scenario: Explore in broad mode without CLI
- **WHEN** user selects broad exploration and the CLI is not installed
- **THEN** broad exploration proceeds normally since it does not require the CLI

### Requirement: EnterPlanMode soft gate when OpenSpec available
When the openspec plugin is active, invocation of the `EnterPlanMode` tool SHALL trigger a soft confirmation asking the user whether they intended to use native plan mode or the OpenSpec workflow.

#### Scenario: User confirms native plan mode
- **WHEN** `EnterPlanMode` is invoked and the soft gate presents the choice
- **AND** user confirms they want native plan mode
- **THEN** `EnterPlanMode` proceeds normally

#### Scenario: User chooses OpenSpec instead
- **WHEN** `EnterPlanMode` is invoked and the soft gate presents the choice
- **AND** user indicates they prefer OpenSpec
- **THEN** `EnterPlanMode` is cancelled and the user is directed to `/openspec:new` or `/openspec:ff`

### Requirement: OpenSpec preference rule
The plugin SHALL include a rule file that instructs Claude to prefer the OpenSpec workflow over native `EnterPlanMode` for multi-step changes in projects where OpenSpec is active.

#### Scenario: Rule loaded in OpenSpec-enabled project
- **WHEN** the openspec plugin is active and the rule file is loaded
- **THEN** Claude SHALL default to suggesting `/openspec:new` or `/openspec:ff` instead of `EnterPlanMode` for planning tasks
- **AND** the rule SHALL not prevent use of `EnterPlanMode` when the user explicitly requests it
