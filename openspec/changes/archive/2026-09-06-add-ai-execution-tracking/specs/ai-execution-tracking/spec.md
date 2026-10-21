## Purpose

Provide optional package-owned operational records for explicit AI business invocations without changing their outcomes or persisting conversation content.

## ADDED Requirements

### Requirement: Explicit execution lifecycle
The optional tracker SHALL expose track(agent:, use_case:, prompt_version:, model_alias:, trace_id: nil, subject_ref: nil) with an injected store and reporting callback. It SHALL track one fresh synchronous agent invocation including tool rounds, create a running record before execution, and finalize success or failure afterward. It SHALL return the original block result, classify dry-monads Failure as business failure, and re-raise StandardError exceptions unchanged.

#### Scenario: Completed invocation
- **WHEN** the block returns normally or returns a dry-monads Failure
- **THEN** the tracker records succeeded or failed respectively and returns that exact result

#### Scenario: Exceptional invocation
- **WHEN** the block raises a StandardError
- **THEN** the tracker attempts failure finalization with only sanitized failure kind/class and re-raises the same exception

#### Scenario: Unsupported invocation
- **WHEN** the agent/chat is reused, contains prior non-system messages, or tracking starts in an open database transaction
- **THEN** the block is rejected before execution with corrective guidance

#### Scenario: Concurrent tracking
- **WHEN** separate fresh agents run concurrently
- **THEN** records and usage remain isolated and duplicate tracking of a shared chat is rejected

### Requirement: Outcome-preserving operational metadata
Tracking SHALL store UUID, business and agent identifiers, prompt/model identity, optional opaque references, status, UTC timestamps, monotonic duration, nullable token counts and estimated cost, and sanitized failure kind/class. It SHALL exclude conversation content, tool payloads, exception messages, input fingerprints, and unrestricted metadata. It SHALL count each assistant message once and preserve unknown usage/pricing as null.

#### Scenario: Tool rounds and partial usage
- **WHEN** an invocation produces multiple assistant messages or fails after some responses
- **THEN** available usage is collected once per response, unknown fields remain null, and no content is stored

#### Scenario: Tracking failure
- **WHEN** storage, usage collection, or the reporting callback fails
- **THEN** the business result or original exception is preserved and reporting receives only execution ID, stage, and error class

#### Scenario: Process interruption
- **WHEN** the process terminates before finalization
- **THEN** the running record can remain for manual investigation without an automatic retry or scheduler

### Requirement: Conservative package-owned generation
The command bin/rails generate foundry:ai_tracking --package=PACKAGE SHALL generate one operational record, store adapter, host migration, tests, and receipt for a registered manifest-v2 package. It SHALL use registry-defined model paths for light profiles, persistence-record paths for full-domain profiles, external-adapter paths for the store, Foundry's abstract record base, and package-prefixed tables. It SHALL not install dependencies, run migrations, or modify agents/composition.

#### Scenario: All package profiles
- **WHEN** generation runs for any profile or platform package
- **THEN** the generated files follow ordinary constant mapping, strict checks pass, and the migration creates a uniquely identified execution table owned by that package

#### Scenario: Preview and edited repeat
- **WHEN** generation is previewed or repeated after customization
- **THEN** preview writes nothing and compatible repeats preserve all edited files

#### Scenario: Conflicting or unsafe generation
- **WHEN** inputs, receipts, migrations, paths, or partial scaffolds conflict
- **THEN** generation fails before writes; interrupted writes remove only unchanged newly created artifacts and preserve concurrent edits

### Requirement: Distributable offline workflow
The gem SHALL bundle tracking resources and guidance in its existing seven skills. Tracking SHALL remain optional, respect existing compatibility floors, and be verifiable through installed public commands with provider requests blocked. Changed catalogs SHALL require manual reconciliation.

#### Scenario: Installed workflow
- **WHEN** the developer follows installed guidance to generate, migrate, wire, run, and check tracking
- **THEN** each profile works without an example application, provider credentials, or unbundled workflow resources
