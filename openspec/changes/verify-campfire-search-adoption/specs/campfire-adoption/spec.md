## Purpose

Establish reproducible adoption evidence in an independently developed Rails application while retaining its existing behavior and infrastructure.

## ADDED Requirements

### Requirement: Existing application behavior survives extraction
Adoption SHALL preserve search URLs, visibility, per-user history, message indexing, ordering, result limits and browser rendering without migrating application data or changing the existing execution stack.

#### Scenario: Membership changes
- **WHEN** a user loses access to a room containing matching messages
- **THEN** search does not return those messages after extraction

#### Scenario: Search lifecycle
- **WHEN** messages are created, edited or deleted and users record or clear searches
- **THEN** search results and user-specific history retain the baseline behavior

### Requirement: Verification includes the application and extracted package
Installed verification SHALL execute root and package tests and explicit HTTP/browser acceptance; boundary enforcement SHALL reject undeclared private access independently of behavioral results.

#### Scenario: Fault controls
- **WHEN** authorization is bypassed, root/package coverage is omitted, or private pack code is accessed
- **THEN** the corresponding behavioral, coverage or boundary check fails

### Requirement: Evidence identifies compatibility and limits
The adoption record SHALL identify source and result revisions, built gem and dependency fingerprints, baseline failures, commands, results and rollback instructions. It SHALL NOT describe unexecuted checks or blocked prerequisites as completed acceptance.

#### Scenario: Incompatible pinned dependencies
- **WHEN** the existing locked application cannot run with the adoption dependencies
- **THEN** acceptance remains incomplete and records the incompatibility without silently replacing the application stack

#### Scenario: Separate browser evidence
- **WHEN** the authorized browser review compares the original and extracted applications
- **THEN** it uses disposable synthetic state with frozen dependencies and records expected behavior, actual outcomes and a visibility-bypass control
- **AND** it does not substitute for blocked installed-helper acceptance or authorize test-harness changes
