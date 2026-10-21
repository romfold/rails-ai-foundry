# Reviewed ticket resolution specification

## Purpose

Demonstrate durable, human-reviewed AI ticket resolution with tenant isolation, recoverable generation and exactly one approved local effect.

## Requirements

### Requirement: Persisted request identity and review
The application SHALL persist requests and append-only audit history, enforce one active request per ticket, and preserve requester-scoped idempotency. Only an active same-tenant editor SHALL approve the exact proposal and source revision; self-approval is permitted.

#### Scenario: Repeated submission
- **WHEN** the requester repeats an idempotency key
- **THEN** identical content returns the existing request and changed content returns a conflict

#### Scenario: Review authority
- **WHEN** an editor approves a matching proposal and ticket revision
- **THEN** the approval is recorded without presenting it as completed execution

#### Scenario: Stale or unauthorized decision
- **WHEN** a reader, revoked identity or stale revision attempts approval
- **THEN** no approval is granted and foreign-tenant resources remain concealed

### Requirement: Recoverable bounded generation
The application SHALL default to offline generation, bound input/output to 2000 characters, use a 30-second provider timeout without transport retries, and persist at most three generation attempts with bounded backoff and 90-second leases. Pending work SHALL be rediscovered every 30 seconds in batches of at most 50.

#### Scenario: Delayed worker
- **WHEN** a worker returns after its lease expired or ownership changed
- **THEN** its proposal is rejected without overwriting newer work

#### Scenario: Lost scheduling and provider failure
- **WHEN** enqueue is lost or generation fails
- **THEN** database discovery recovers eligible work and exhausted attempts remain visible; retry creates a linked new request

#### Scenario: Cancellation during generation
- **WHEN** cancellation commits before proposal persistence
- **THEN** returned provider output cannot restore the request

### Requirement: Atomic approved local action
The application SHALL revalidate current identities, tenant, approval and revision before committing closure, approved resolution, completion and audit together. The proposal agent SHALL have no mutation tool.

#### Scenario: Execution replay
- **WHEN** execution dies before commit or replays after commit
- **THEN** the local action and completion record occur exactly once

#### Scenario: Cancellation race
- **WHEN** cancellation races execution
- **THEN** the first committed outcome wins and a completed action cannot be cancelled

### Requirement: Safe delivery and human review
The application SHALL provide create, view, approve, reject, cancel and retry endpoints; accepted JSON work returns 202 and a status URL, conflicts return 409. Browser forms SHALL redirect to the status page after accepted decisions. It SHALL preserve the answers contract and provide CSRF-protected review controls, escaped text and bounded status-only polling.

#### Scenario: Status refresh
- **WHEN** a proposal becomes available or reaches a terminal state
- **THEN** only the status frame refreshes, unsaved input remains and terminal polling stops

### Requirement: Executable evidence and reusable guidance
Acceptance SHALL include real PostgreSQL and queue recovery, process crashes, browser review, faulty controls and installed guidance replay with default and custom package roots. Historical trials and unfinished study acceptance SHALL remain unchanged.

#### Scenario: Invalid implementation control
- **WHEN** a control bypasses approval, ignores revision changes, accepts stale generation or duplicates execution
- **THEN** behavioral acceptance rejects it
