## Purpose

Provide explicit installed Rails feature verification for RSpec consumers while preserving existing Minitest contracts.

## ADDED Requirements

### Requirement: Explicit native framework verification
The installed helper SHALL accept framework minitest or rspec, default to minitest, and run the application bundle in isolated test processes with bounded timeouts. It SHALL NOT install dependencies. RSpec verification SHALL require completed request examples for caller files and system examples for browser files, including correctly attributed shared examples.

#### Scenario: Installed RSpec application
- **WHEN** an application selects RSpec and explicit request and system files
- **THEN** baseline, caller and browser evidence is independently verified using installed resources
- **AND** all selected files contribute completed examples of the required type

#### Scenario: Existing Minitest invocation
- **WHEN** no framework is selected
- **THEN** existing assertion, selection, skip and timeout behavior remains unchanged

### Requirement: Honest and complete execution evidence
Verification SHALL reject empty, malformed, absent, failed, incomplete, dry-run, narrowed or wrong-type evidence and suite errors. Pending selected examples SHALL fail; baseline pending exceptions SHALL require explicit native IDs. RSpec SHALL report expectation counts as unavailable and SHALL NOT claim that native passing outcomes establish meaningful expectations.

#### Scenario: Hidden missing behavior
- **WHEN** a selected specification is pending, filtered out, empty or never completes
- **THEN** verification returns nonzero and does not claim success

#### Scenario: Passing expectation-free example
- **WHEN** an RSpec example completes successfully without expectations
- **THEN** native execution may pass but output and guidance do not claim assertion coverage

### Requirement: Preserving installed delivery
The RSpec helper SHALL be available from all three installed skill targets without checkout access. Reviewed upgrades SHALL preserve customization, selected workflows and accepted debt.

#### Scenario: Upgraded custom-root consumer
- **WHEN** an installed consumer with customized guidance accepts an upgrade
- **THEN** native request/browser controls execute and unrelated application state remains unchanged
