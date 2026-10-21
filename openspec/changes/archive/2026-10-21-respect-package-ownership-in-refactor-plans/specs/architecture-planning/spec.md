## ADDED Requirements

### Requirement: Selected package ownership
Context refactoring SHALL determine source ownership through the consuming application's upstream package inventory, independently of whether descendants declare Foundry intent. It SHALL inspect only Ruby owned by the selected configured context, excluding separately discovered nested packages before parsing or collecting model evidence. Existing context selection and ambiguity behavior SHALL remain unchanged; unconfigured packages SHALL NOT become selectable refactoring contexts implicitly.

#### Scenario: Nested package with malformed tests
- **WHEN** a selected parent contains an independently discovered nested package with malformed Ruby in its tests
- **THEN** the parent assessment excludes that Ruby and is not marked incomplete because of it
- **AND** the exclusion applies with or without a nested foundry.yml

#### Scenario: Descendant model evidence
- **WHEN** a model is declared only in a nested package and the selected parent's source uses a similarly named constant
- **THEN** the nested declaration does not supply model evidence to the parent's assessment

#### Scenario: Custom roots and overlapping discovery
- **WHEN** upstream discovery includes custom or nested roots, repeated paths, and packages with similar name prefixes
- **THEN** selected owned files are inspected once in deterministic order without crossing package boundaries

#### Scenario: Selected context without intent
- **WHEN** the requested package has no foundry.yml
- **THEN** refactoring refuses context selection without inventing a profile or changing configuration

### Requirement: Root and non-app source assessment
Refactoring SHALL retain inspection of non-hidden Ruby descendants owned by a selected non-root context, including tests and lib. A root package explicitly discovered upstream with root-level context intent SHALL be selectable and SHALL inspect its owned non-hidden Ruby, excluding application-root vendor, node_modules, tmp, log, storage and coverage trees. Nested package boundaries SHALL apply to root assessment as to other contexts. Reports SHALL describe this inspection scope without treating source parsing as behavioral verification.

#### Scenario: Configured root context
- **WHEN** upstream discovers the root package and it has valid root-level context intent
- **THEN** refactoring assesses root-owned Ruby using its installed profile and namespace
- **AND** source locations are normalized application-relative paths without a leading ./
- **AND** application-level configuration is not mistaken for context intent

#### Scenario: Non-app Ruby remains evidence
- **WHEN** selected context tests or lib contain malformed Ruby
- **THEN** the assessment reports source.syntax, sets complete to false and returns failure without writes

#### Scenario: Root dependencies and descendants
- **WHEN** excluded root dependency/generated trees or independently discovered descendants contain malformed Ruby
- **THEN** that Ruby does not affect the selected root assessment
- **AND** owned Ruby under app, lib, test, spec, config, db and script remains eligible

### Requirement: Safe read-only package assessment
Refactoring SHALL fail without a successful assessment when upstream discovery is invalid or eligible source inspection is unsafe or incomplete. It SHALL reject symlinked eligible paths, path escapes and unreadable, disappeared or non-regular selected sources rather than silently skipping them. It SHALL NOT boot Rails, execute inspected Ruby, mutate consumer files or fall back to a narrower inventory. Errors SHALL identify safe relative locations where applicable without printing source contents. Existing report schema, diagnostic meanings, proposed-profile behavior and zero/one exit semantics SHALL remain unchanged.

#### Scenario: Unsafe or unreadable source
- **WHEN** eligible traversal encounters a symlink or a selected source cannot be read
- **THEN** the command fails with actionable diagnostic text and leaves the consuming application unchanged

#### Scenario: Failed upstream discovery
- **WHEN** the locked upstream discovery fails or returns malformed or unsafe paths
- **THEN** refactoring fails without inspecting only root files as a fallback

#### Scenario: Proposed profile and read-only execution
- **WHEN** a caller proposes a different profile for an otherwise parseable selected context
- **THEN** findings use installed intent, preserve severity and certainty, and can accompany a completed assessment
- **AND** source, locks, workflow artifacts, customized skills, receipts and accepted debt remain unchanged
- **AND** completion does not claim that the proposed migration or behavioral verification occurred
