## ADDED Requirements

### Requirement: Focused architecture diagnostics
Explicit source checking SHALL inspect configured pure-domain source for Rails/persistence/provider references, delivery source for direct provider access, and queries/projections for explicit persistence writes. It SHALL also report obvious provider calls within transactions or callbacks for review. Each diagnostic SHALL separate severity (error or warning) from certainty (detected or inferred); concrete prohibited syntax fails, while inferred concerns are advisory. Query writes SHALL fail; projection writes SHALL be advisory because rebuildable read models legitimately persist state. Reports SHALL name limitations and retain Packwerk authority without evaluating Ruby.

#### Scenario: Direct domain persistence dependency
- **WHEN** a pure-domain file references an explicit persistence constant
- **THEN** source checking emits a detected error with a stable rule and location

#### Scenario: Inferred transaction concern
- **WHEN** a provider call appears inside a transaction block
- **THEN** source checking reports the location as an inferred warning and does not claim runtime proof
