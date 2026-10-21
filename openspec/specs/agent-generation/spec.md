# agent-generation Specification

## Purpose
Generate safe, reusable agent scaffolds inside registered packages while preserving application ownership and existing configuration.

## Requirements

### Requirement: Native pack-owned agent generation
The native agent generator SHALL emit direct RubyLLM agents, tools and schemas inside the owning pack for every profile. It SHALL require an explicit `capabilities.ai.adapter: ruby_llm` selection, preserve architectural settings, and avoid Foundry execution dependencies. New prompt files and behavioral contracts SHALL live inside the owning pack. Lookup SHALL use explicit application-owned paths relative to the agent file, supporting custom roots and nested namespaces. Complete prior scaffolds SHALL remain preserving repeats; relocation requires explicit review. Tool constructors SHALL require application-provided operation and authorization callables; every execution SHALL authorize before invoking the operation.

#### Scenario: Native agent generation
- **WHEN** an application generates an agent using `--context` in a context selecting RubyLLM
- **THEN** the generator creates pack-local agents, tools, schemas and deterministic authorization tests plus pack-local prompt files and a generation receipt
- **AND** no profile, pattern or topology is changed

#### Scenario: Authorization denial
- **WHEN** the injected authorization callback denies a tool call
- **THEN** the operation is never invoked and access denial is reported by application code

#### Scenario: Constructing an agent with callable inputs
- **WHEN** an application constructs a generated agent with operation and authorization callables
- **THEN** reading instructions does not invoke either callable or evaluate prompt text as Ruby or ERB
- **AND** prompt lookup is independent of the Rails application root and process working directory and SHALL observe edits on new agent construction

#### Scenario: Shared model aliases
- **WHEN** the first native agent is generated without root `config/ai.yml`
- **THEN** an empty application-owned model alias mapping is created
- **AND** subsequent generations preserve existing aliases and require the application to select its model/provider at invocation

#### Scenario: Safe repeat and collisions
- **WHEN** a complete generated agent has been customized
- **THEN** repeat generation preserves its artifacts and existing shared configuration
- **AND** occupied paths, malformed configuration, symlinks and partial scaffolds fail without overwriting application files

#### Scenario: Production execution
- **WHEN** a consuming application's production bundle excludes Foundry
- **THEN** the generated agent, tool, schema and prompt remain executable with Rails, packs-rails and RubyLLM
- **AND** offline acceptance verifies behavior independently of any live evaluation

### Requirement: Agent scaffold ownership includes all runtime constants
Agent generation SHALL preflight the agent, tool and schema constants against component and agent receipts before writing any artifact. New agents SHALL participate in application-owned namespace inflection installation. Completed customized agents SHALL remain safe to repeat without receipt conversion.

#### Scenario: Component claims a tool or schema
- **WHEN** the requested agent's tool or schema constant is already owned by a component
- **THEN** generation and preview fail before creating prompts, shared aliases, inflections or receipts

#### Scenario: Existing agent receipt
- **WHEN** a component would claim a runtime constant described by an existing agent receipt
- **THEN** the component is refused and the receipt remains byte-identical
