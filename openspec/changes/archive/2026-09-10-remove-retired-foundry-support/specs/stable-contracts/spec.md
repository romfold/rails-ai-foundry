## MODIFIED Requirements

### Requirement: Identifiable machine-readable evidence
JSON assessments, refactor plans and audit/parity reports SHALL carry report schema 1, the producing Foundry version and report kind. Their evidence and limitations SHALL remain visible. Assessment reports SHALL NOT include retired manifest detection fields. JSON Schema assets SHALL describe required fields and types, and permit additive report fields. Exit status SHALL remain zero for completed successful assessment and one for findings that fail the selected check or command errors. Errors SHALL remain on stderr; prose SHALL NOT be a parsing contract.

#### Scenario: Diagnostic evidence
- **WHEN** source checking detects an explicit Foundry constant in application code
- **THEN** the versioned JSON assessment fails with a stable source.foundry_dependency rule, file, one-based line, detected certainty, remediation message and declared analysis limitations

#### Scenario: Unsupported evidence
- **WHEN** parity verification receives an unversioned or unsupported-format report
- **THEN** it refuses the evidence with instructions to rerun parity and does not approve a backend switch

