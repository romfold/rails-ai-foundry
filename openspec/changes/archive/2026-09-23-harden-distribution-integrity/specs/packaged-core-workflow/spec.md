## ADDED Requirements

### Requirement: Intentional distributable documentation
The archive SHALL select documentation through an explicit resource list, include required local link targets and exclude research drafts, local plans, secrets, tests and example applications. Contributor checks SHALL report suspected privacy findings by location and category without exposing values.

#### Scenario: Contaminated source tree
- **WHEN** an archive is built with arbitrary local documents and synthetic sensitive files present
- **THEN** the installed resource inventory remains unchanged and required local documentation links resolve

#### Scenario: Privacy finding
- **WHEN** contributor scanning encounters a personal workstation path or supported credential signature
- **THEN** it fails with a location/category diagnostic and does not print the matched value
