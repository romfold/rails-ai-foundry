## ADDED Requirements

### Requirement: Report encoding and inflection repair preserve ownership
Boundary, audit and parity reports SHALL serialize captured command text as valid Unicode independently of locale, retaining valid UTF-8 and replacing invalid bytes. Namespace inflection configuration SHALL remain application-owned and independently receipted. Upgrade guidance SHALL explain explicit repair of previously generated acronym contexts without silently rewriting completed scaffolds, receipts or global application naming rules.

#### Scenario: Audit and parity command output
- **WHEN** command evidence includes Unicode or invalid UTF-8 under an ASCII locale
- **THEN** report serialization succeeds with normalized text and unchanged command status and debt identities

#### Scenario: Upgrade repair
- **WHEN** an existing acronym context needs loading configuration
- **THEN** documented repair preserves customized application code and existing receipt provenance
