## Purpose

Demonstrate a bounded support-triage workflow with deterministic provider responses and explicit limits on what offline tests prove.

## ADDED Requirements

### Requirement: Structured triage
Support::Triage.call(text:, knowledge_lookup:, model:, provider:) SHALL return category (billing, technical, other), priority (low, normal, high), and a string summary, or raise a specific invalid-output error.

#### Scenario: Classification
- **WHEN** the provider returns a valid structured result
- **THEN** the validated classification is returned

#### Scenario: Invalid output
- **WHEN** output is malformed, missing fields, or outside the enums
- **THEN** the workflow raises its invalid-output error rather than returning a successful classification

### Requirement: Bounded delegated tools
The workflow SHALL delegate read-only knowledge queries to the caller-supplied authorized operation, keep user and retrieved content outside system instructions, and stop before a fourth tool invocation.

#### Scenario: Knowledge round trip
- **WHEN** the model requests knowledge
- **THEN** the injected operation is called and its result is returned as tool content

#### Scenario: Invocation limit
- **WHEN** a fourth tool call is attempted
- **THEN** a specific limit error is raised before the operation executes

#### Scenario: Untrusted instructions
- **WHEN** support text or a tool result contains instruction-like text
- **THEN** it remains user or tool content and cannot change configured tool capabilities

#### Scenario: Failure propagation
- **WHEN** the provider or injected operation fails
- **THEN** the error remains visible without a second application retry loop

### Requirement: Offline evidence
The default AI suite SHALL use deterministic responses with external network access disabled. Live evaluation SHALL be documented separately and SHALL NOT run by default.

#### Scenario: Credential-free tests
- **WHEN** the AI suite runs without provider credentials
- **THEN** stubbed real RubyLLM requests cover classification, tools, malformed output, and failures

#### Scenario: Live evaluation guidance
- **WHEN** a contributor reads evaluation documentation
- **THEN** it states required credentials, explicit provider/model selection, costs, quality checks, and that offline tests do not prove model quality
