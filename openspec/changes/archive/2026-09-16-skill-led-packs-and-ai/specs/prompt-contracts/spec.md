## Purpose
Validate explicit application-owned prompt contracts without loading Rails or evaluating prompt content.

## ADDED Requirements

### Requirement: Explicit prompt validation
The check command SHALL support opt-in --prompts validation of contracts under application and configured pack prompt roots. Contracts SHALL identify ownership, template files, trust inputs, output schema, allowed tools and evaluation fixtures, with an optional application model alias. Validation SHALL check data shape and safe file references without resolving constants, evaluating templates or contacting providers. Failures SHALL carry file, line, stable rule, severity, certainty and guidance, compose with other selected checks and preserve files and debt.

#### Scenario: Unsafe or missing prompt artifact
- **WHEN** a contract references a missing file, symlink or path escaping its ownership root
- **THEN** validation fails before executing application code and reports the affected contract

#### Scenario: Ordinary checks remain opt-in
- **WHEN** prompt validation is not requested
- **THEN** ordinary configuration checks keep their existing scope
