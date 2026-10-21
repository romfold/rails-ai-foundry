# stable-contracts Specification

## Purpose

Define the stable development-time contracts that let consuming applications validate configuration, interpret evidence and review Foundry upgrades without changing application execution.

## Requirements

### Requirement: Versioned configuration contracts
Foundry SHALL ship application and context JSON Schemas for version 1. Runtime validation SHALL reject unsupported schema versions, unknown root and workflow keys and nonempty reserved checks/adoption mappings before mutation. Missing schema SHALL mean version 1 for existing native consumers. Capability-specific settings SHALL remain application-owned extension data and SHALL NOT confer integration support.

#### Scenario: Invalid application contract
- **WHEN** setup or generation receives schema 2, a misspelled root key or an unsupported checker policy
- **THEN** it fails with corrective guidance and preserves application files

#### Scenario: Native configuration upgrade
- **WHEN** a schema-omitted 0.5 application selects a workflow or generates a component using 1.0
- **THEN** its supported configuration remains accepted without moving contexts, converting data or replacing business code

### Requirement: Identifiable machine-readable evidence
JSON assessments, refactor plans and audit/parity reports SHALL carry report schema 1, the producing Foundry version and report kind. Their evidence and limitations SHALL remain visible. Assessment reports SHALL NOT include retired manifest detection fields. JSON Schema assets SHALL describe required fields and types, and permit additive report fields. Exit status SHALL remain zero for completed successful assessment and one for findings that fail the selected check or command errors. Errors SHALL remain on stderr; prose SHALL NOT be a parsing contract.

#### Scenario: Diagnostic evidence
- **WHEN** source checking detects an explicit Foundry constant in application code
- **THEN** the versioned JSON assessment fails with a stable source.foundry_dependency rule, file, one-based line, detected certainty, remediation message and declared analysis limitations

#### Scenario: Unsupported evidence
- **WHEN** parity verification receives an unversioned or unsupported-format report
- **THEN** it refuses the evidence with instructions to rerun parity and does not approve a backend switch

### Requirement: Discoverable installed contract inventory
The installed gem SHALL expose boot-free version and JSON contract inventory commands, including schema asset paths, generator names and skill targets/names. Schema files SHALL be included in the built gem and SHALL be validated against actual reports and native consumer configuration in contributor CI.

#### Scenario: Installed discovery
- **WHEN** foundry contracts or foundry --version runs outside a Rails application from the built gem
- **THEN** it succeeds without application boot, production integrations or upstream workflow initialization

### Requirement: Reviewable upgrades preserve application ownership
Foundry SHALL document stable generator names, placement, receipt and collision behavior, skill names and targets, and manual upgrade/recovery steps. Repeated complete generation SHALL preserve edited application files. An old or partial skill receipt SHALL cause a non-destructive refusal with review guidance. A gem update SHALL NOT implicitly rewrite generated sources, skills, workflow history, accepted debt or business data.

#### Scenario: Customized previous skills
- **WHEN** an application with the committed 0.5 skill receipt and a customized skill runs the 1.0 installer
- **THEN** installation refuses the conflicting catalog and preserves all application bytes for manual comparison

### Requirement: Stable release policy and evidence
Foundry SHALL publish a documented public contract, SemVer/deprecation policy, supported versus experimental integration boundaries and upgrade procedure. Release acceptance SHALL exercise Ruby 3.3/Rails 7.1 and the managed Ruby 3.4/Rails 8.1 pair, built-gem consumers, offline optional AI, pinned specification tooling, schemas, skills and diagnostics. Unsupported or unexecuted combinations SHALL NOT be described as passing. Release publication SHALL remain a separate action.

#### Scenario: Stable local release
- **WHEN** 1.0 is marked complete in the delivery ledger
- **THEN** current version metadata, implemented contract tests and compatibility evidence agree and historical ADRs and archives remain intact

### Requirement: Report encoding and inflection repair preserve ownership
Boundary, audit and parity reports SHALL serialize captured command text as valid Unicode independently of locale, retaining valid UTF-8 and replacing invalid bytes. Namespace inflection configuration SHALL remain application-owned and independently receipted. Upgrade guidance SHALL explain explicit repair of previously generated acronym contexts without silently rewriting completed scaffolds, receipts or global application naming rules.

#### Scenario: Audit and parity command output
- **WHEN** command evidence includes Unicode or invalid UTF-8 under an ASCII locale
- **THEN** report serialization succeeds with normalized text and unchanged command status and debt identities

#### Scenario: Upgrade repair
- **WHEN** an existing acronym context needs loading configuration
- **THEN** documented repair preserves customized application code and existing receipt provenance

### Requirement: Unpublished skill-led candidate contracts
The unpublished candidate SHALL document pack-local prompts for new agent scaffolds and the optional prompt-check report surface. Complete existing generated artifacts and receipts SHALL be preserved on repeat. Explicit relocation SHALL require review and behavioral verification. Diagnostic severity and certainty SHALL be documented separately and machine-readable report schemas SHALL validate emitted evidence.

#### Scenario: Preserve customized generated output
- **WHEN** generation repeats a complete existing agent with its original receipt
- **THEN** edited application files remain unchanged and no relocation or template synchronization occurs
