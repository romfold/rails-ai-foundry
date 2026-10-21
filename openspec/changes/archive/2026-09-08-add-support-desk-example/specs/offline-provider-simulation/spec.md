## Purpose

Demonstrate real RubyLLM request and tool execution using isolated deterministic responses without contacting external providers.

## ADDED Requirements

### Requirement: Scenario-driven simulation
The application SHALL offer billing, technical, general, malformed-output, provider-failure, and excessive-tool scenarios and visibly explain that the chosen scenario determines the response.

#### Scenario: Successful round trip
- **WHEN** a success scenario runs
- **THEN** real RubyLLM serializes a request, executes one knowledge tool call, and receives a canned structured result

#### Scenario: Excessive calls
- **WHEN** the excessive-tool scenario runs
- **THEN** the existing workflow stops before a fourth operation invocation

### Requirement: Network isolation
The example SHALL use a reserved .invalid endpoint and fixed placeholder credentials, and SHALL block all unstubbed outbound requests. Environment credentials SHALL NOT activate live behavior.

#### Scenario: Unknown request
- **WHEN** an outbound request does not match the simulation endpoint
- **THEN** it is blocked without network access

#### Scenario: Environment credentials
- **WHEN** real-looking credentials are present in environment variables
- **THEN** the simulation endpoint and placeholder credential remain selected

### Requirement: Request isolation and trust
Responses SHALL derive from each serialized request and conversation state, not a shared response sequence. Ticket text SHALL remain user data, and knowledge results SHALL remain tool data.

#### Scenario: Interleaved requests
- **WHEN** different ticket scenarios are interleaved
- **THEN** each receives its own scenario result and tool sequence

#### Scenario: Instruction-like content
- **WHEN** ticket text attempts to select another scenario or alter instructions
- **THEN** the validated scenario remains authoritative and the text stays outside trusted instructions
