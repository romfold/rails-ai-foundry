## ADDED Requirements

### Requirement: Native pack-owned agent generation
The native agent generator SHALL emit direct RubyLLM agents, tools and schemas inside the owning pack for every profile. It SHALL require an explicit `capabilities.ai.adapter: ruby_llm` selection, preserve architectural settings, and avoid Foundry execution dependencies. Root application prompts and their behavioral contracts SHALL remain outside the pack. Tool constructors SHALL require application-provided operation and authorization callables; every execution SHALL authorize before invoking the operation.

#### Scenario: Native agent generation
- **WHEN** an application generates an agent using `--context` in a context selecting RubyLLM
- **THEN** the generator creates pack-local agents, tools, schemas and deterministic authorization tests plus root prompt files and a generation receipt
- **AND** no profile, pattern or topology is changed

#### Scenario: Authorization denial
- **WHEN** the injected authorization callback denies a tool call
- **THEN** the operation is never invoked and access denial is reported by application code

#### Scenario: Constructing an agent with callable inputs
- **WHEN** an application constructs a generated agent with operation and authorization callables
- **THEN** reading instructions does not invoke either callable or evaluate prompt text as Ruby or ERB
- **AND** prompt lookup uses the Rails application root regardless of the process working directory

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

## REMOVED Requirements

### Requirement: Package-owned scaffold
**Reason**: The unused 0.1 implementation is retired in the approved 0.2 breaking reset.
**Migration**: Use native context tooling and direct upstream APIs; see docs/migration-0.2.md. Later example and event recipes remain tracked in docs/implementation-program.md.

### Requirement: Conservative generation
**Reason**: The unused 0.1 implementation is retired in the approved 0.2 breaking reset.
**Migration**: Use native context tooling and direct upstream APIs; see docs/migration-0.2.md. Later example and event recipes remain tracked in docs/implementation-program.md.

### Requirement: Profiled AI layer isolation
**Reason**: The unused 0.1 implementation is retired in the approved 0.2 breaking reset.
**Migration**: Use native context tooling and direct upstream APIs; see docs/migration-0.2.md. Later example and event recipes remain tracked in docs/implementation-program.md.
