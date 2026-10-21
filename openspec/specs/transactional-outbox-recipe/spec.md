# transactional-outbox-recipe Specification

## Purpose

Persist publication intent atomically and recover delivery without claiming exactly-once effects.

## Requirements

### Requirement: Atomic publication and replay
Business state and publication intent SHALL commit in the same database transaction. Delivery SHALL occur afterward with bounded retries, poison-message handling and idempotent downstream effects.

#### Scenario: Crash after publication
- **WHEN** delivery succeeds but acknowledgment is interrupted
- **THEN** retry does not duplicate the consumer business effect and intent remains recoverable
