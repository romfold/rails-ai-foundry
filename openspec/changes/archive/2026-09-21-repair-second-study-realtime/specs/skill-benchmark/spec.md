## ADDED Requirements

### Requirement: Independently selected repair sets
Contributor repair preparation SHALL support named, separately attributed repair sets while preserving default first-study preparation. It SHALL validate selected study revision, upstream task, image and original candidate identity before preparing output and SHALL reject unknown sets or mismatched provenance.

#### Scenario: Selecting a later study repair
- **WHEN** the contributor selects the September 21 realtime repair set
- **THEN** only its verified candidate, repair patches and supplemental checks are prepared
- **AND** the first study's fixtures and all historical grades remain unchanged

#### Scenario: Mismatched reconstruction inputs
- **WHEN** the study, task, image or candidate differs from the selected repair provenance
- **THEN** preparation fails without claiming a valid repair workspace

#### Scenario: Repair equivalence
- **WHEN** a repair is accepted
- **THEN** applying its incremental patch to the original candidate reconstructs the same tree as its complete patch against the sealed baseline
- **AND** original upstream requirements remain unchanged and faulty controls fail behavioral assertions
