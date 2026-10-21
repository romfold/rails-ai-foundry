## Purpose

Provide verified native source diagnostics for Rails consumers while keeping Foundry a development-time conventions kit.

## ADDED Requirements

### Requirement: Explicit native source migration checks
Native checking and read-only adoption SHALL support an explicit source check for legacy Foundry runtime constant paths. The check SHALL parse selected Ruby sources without initializing Rails or executing application code. It SHALL inspect application app/ and discovered contexts' app/ directories, using upstream discovery and installed Foundry sidecars to select contexts.

#### Scenario: Legacy runtime reference
- **WHEN** selected Ruby source references an explicit RailsAIFoundry runtime constant path
- **THEN** the source check reports file, line, rule, detected certainty and corrective guidance
- **AND** exits unsuccessfully without modifying source or accepted debt

#### Scenario: Syntax and non-code text
- **WHEN** legacy API names occur only in comments or plain strings
- **THEN** those names do not produce findings
- **AND** unparseable Ruby produces a failing syntax diagnostic rather than a clean result

#### Scenario: Custom roots and isolated verification
- **WHEN** a configured context uses a custom upstream pack root
- **THEN** the same source checking applies without loading its classes or initializers
- **AND** symbolic link sources are rejected

### Requirement: Source findings declare their limits
Source reports SHALL distinguish detected syntax from proven constant resolution and behavioral correctness. They SHALL disclose excluded roots, aliases, dynamic lookup, lexical references, requires and non-Ruby files. Packwerk SHALL remain authoritative for dependency/privacy checking.

#### Scenario: Optional and composable checks
- **WHEN** sources are not explicitly requested
- **THEN** ordinary native configuration checking retains its current scope
- **AND WHEN** source and Packwerk checks are requested together
- **THEN** failure of either check fails the command

#### Scenario: Installed Rails task
- **WHEN** a configured native installed-gem consumer runs foundry:architecture:sources
- **THEN** the Rake task invokes the same explicit boot-free source assessment
