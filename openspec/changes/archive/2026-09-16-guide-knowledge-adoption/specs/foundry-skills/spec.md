## ADDED Requirements

### Requirement: Verified adoption checkpoints
Existing adoption, planning, refactoring and verification guidance SHALL prescribe characterization before extraction, independently useful package boundaries, explicit public caller repair, separate persistence changes, checkpoint rollback instructions and executable evidence. Guidance SHALL preserve selected workflows and reviewed debt and distinguish assessment completion from migration completion.

#### Scenario: Incremental knowledge extraction
- **WHEN** a skill guides extraction of a business boundary
- **THEN** it retains existing persistence for the extraction checkpoint and verifies endpoints, authorization and failure behavior before recommending a separate persistence change

#### Scenario: Failed checkpoint
- **WHEN** behavior or boundary acceptance fails
- **THEN** guidance requires repairing or rolling back the checkpoint and leaves completion unclaimed
