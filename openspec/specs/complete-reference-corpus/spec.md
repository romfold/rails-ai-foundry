# Complete reference corpus Specification

## Purpose

Make all twelve reference applications independently executable with evidence for their distinct architectural and integration behavior.

## Requirements

### Requirement: Independent complete corpus
All twelve applications SHALL have independent locked dependencies, ordinary Rails delivery, application-local selected workflows, configuration-derived catalog entries, and executable CI. Production execution SHALL not load Foundry runtime code. The eight new greenfield applications SHALL use upstream-initialized Spec Kit.

#### Scenario: Independent verification
- **WHEN** a reference application's documented verification runs with its disposable dependencies
- **THEN** its behavioral suite, architecture checks and selected workflow checks execute from that application without inheriting monorepo workflow state

### Requirement: Persistent and authorized AI examples
Chat SHALL persist conversation history and stream delivery updates, enforce ownership, and expose provider failure. The tool example SHALL authorize each tool invocation, enforce tenant scope, validate structured output and provide deterministic offline evaluations without external model requests.

#### Scenario: Denied tool or conversation access
- **WHEN** a caller attempts another tenant's conversation or tool data
- **THEN** access fails before provider or business execution and no private data is returned

### Requirement: Recoverable vectors and messaging
External vector retrieval SHALL enforce tenant/version filtering, deletion, citations and provider failure, and support projection rebuild and recovery. Event pipelines SHALL handle ordering, retries, duplicate delivery and schema evolution. Durable messaging SHALL retain unacknowledged work for replay and isolate poison messages.

#### Scenario: Replayed delivery
- **WHEN** a worker crashes after committing an effect but before acknowledging it
- **THEN** replay leaves one business effect and ordering/version checks prevent stale state from replacing newer state

### Requirement: Authoritative event streams and outbox
The ledger SHALL derive balances from authoritative streams and reject optimistic conflicts and invalid debits. The background outbox SHALL atomically commit business state and intent, survive publication crash windows, and handle duplicate and poison work.

#### Scenario: Conflicting ledger write
- **WHEN** two writers append using the same expected stream version
- **THEN** one succeeds and the other receives an explicit conflict without corrupting the balance

### Requirement: Isolated asynchronous and frontend delivery
Concurrent batched GraphQL reads SHALL preserve tenant and database-role context and release connections on success and failure. The async server recipe SHALL serve the Rails app through its upstream server. The Rails-root frontend application SHALL have a separate buildable frontend consuming its GraphQL API with authorized data scope and explicit failure behavior.

#### Scenario: Concurrent tenants
- **WHEN** requests from different tenants suspend and resume during batched reads
- **THEN** each receives only its authorized data and no tenant or database-role state leaks into another request
