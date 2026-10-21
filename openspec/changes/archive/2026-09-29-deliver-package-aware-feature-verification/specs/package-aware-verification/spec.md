## Purpose

Provide opt-in complete non-system verification across application and package test roots with explicit loading and behavioral evidence.

## ADDED Requirements

### Requirement: Package-aware baseline is explicit and additive
The installed helper SHALL support --include-pack-tests for Minitest and RSpec, combining conventional root and upstream-discovered package tests with explicit baseline additions. Non-opt-in behavior SHALL remain unchanged.

#### Scenario: Root and package coverage
- **WHEN** an application enables package-aware verification with custom, nested or sidecar-free packages
- **THEN** its root and package non-system tests execute in a deterministic deduplicated baseline and failures from either reject completion

#### Scenario: Package-only application
- **WHEN** only packages contain executable tests
- **THEN** the combined baseline executes them without requiring an unrelated root test

### Requirement: Discovery is safe and reviewable
The helper SHALL print relative root, package, explicit and deferred-browser selections before tests. Unsafe paths, ambiguous ownership, missing dependencies, invalid configuration and unsupported discovery settings SHALL fail before test execution. It SHALL NOT install dependencies or silently fall back.

#### Scenario: Browser boundary
- **WHEN** system files are discovered or a system path is supplied as an explicit baseline
- **THEN** automatic discovery defers system files and explicit baseline system paths fail with guidance to use --browser

#### Scenario: Upstream topology failure
- **WHEN** topology cannot be resolved safely inside the selected application
- **THEN** verification fails before any test phase and makes no application changes

### Requirement: Planned baseline files must load
The helper SHALL reject successful commands that omit planned baseline files using structured loaded-file evidence. Loaded files SHALL remain distinct from executed test ownership. Existing outcome, skip, timeout, interruption and selected-type checks SHALL continue to apply.

#### Scenario: Silent file omission
- **WHEN** unrelated tests pass but a planned package or root file was not loaded
- **THEN** verification fails rather than accepting the printed success summary

#### Scenario: Shared definitions
- **WHEN** a planned shared definition loads and its including test executes
- **THEN** loading is recorded without assigning the including test's behavioral credit to the definition

### Requirement: Installed application command remains application-owned
The distribution SHALL include executable guidance for a fixed application-owned verification script, including separate required invocations for mixed frameworks, without overwriting scripts or introducing an orchestration runtime.

#### Scenario: Reviewed installed upgrade
- **WHEN** upgraded skills are used in default or custom-root consumers under any supported target
- **THEN** the application command executes the new helper and propagates behavioral failures while customized guidance, workflow, receipts and accepted debt are preserved
