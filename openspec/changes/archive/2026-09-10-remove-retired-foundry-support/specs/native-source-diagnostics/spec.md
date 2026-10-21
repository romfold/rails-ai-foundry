## MODIFIED Requirements

### Requirement: Explicit native source migration checks
Native checking and read-only adoption SHALL support an explicit source check for explicit Foundry constant paths in application code. The check SHALL parse selected Ruby sources without initializing Rails or executing application code. It SHALL inspect application app/ and discovered contexts' app/ directories, using upstream discovery and installed Foundry sidecars to select contexts.

#### Scenario: Development tool reference
- **WHEN** selected Ruby source references an explicit RailsAIFoundry runtime constant path
- **THEN** the source check reports file, line, rule, detected certainty and corrective guidance
- **AND** exits unsuccessfully without modifying source or accepted debt

#### Scenario: Syntax and non-code text
- **WHEN** Foundry constant names occur only in comments or plain strings
- **THEN** those names do not produce findings
- **AND** unparseable Ruby produces a failing syntax diagnostic rather than a clean result

#### Scenario: Custom roots and isolated verification
- **WHEN** a configured context uses a custom upstream pack root
- **THEN** the same source checking applies without loading its classes or initializers
- **AND** symbolic link sources are rejected

