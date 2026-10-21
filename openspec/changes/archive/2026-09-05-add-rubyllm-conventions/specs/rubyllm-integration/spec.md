## Purpose

Allow applications to opt into RubyLLM without changing the compatibility or loading behavior of Foundry core.

## ADDED Requirements

### Requirement: Explicit optional activation
The system SHALL expose require "rails_ai_foundry/ruby_llm" and support RubyLLM ~> 1.16.0 on Ruby >= 3.1.3 without adding a core runtime dependency.

#### Scenario: Compatible activation
- **WHEN** the integration is required with compatible dependencies
- **THEN** RubyLLM agent, tool, and schema APIs are available

#### Scenario: Unavailable integration
- **WHEN** Ruby is too old or RubyLLM is missing or unsupported
- **THEN** activation fails with an actionable LoadError naming the required versions

#### Scenario: Core isolation
- **WHEN** ordinary Foundry is required without RubyLLM
- **THEN** core generators and standalone checks remain available without loading RubyLLM

### Requirement: Loading without model access
Integration and generated class loading SHALL require neither provider credentials nor network access.

#### Scenario: Eager loading
- **WHEN** a configured application eagerly loads generated AI classes without credentials
- **THEN** boot succeeds without a provider request

#### Scenario: Rails lifecycle
- **WHEN** package loading is explicitly enabled
- **THEN** AI classes use ordinary lazy loading and reload after source edits; new roots require restart
