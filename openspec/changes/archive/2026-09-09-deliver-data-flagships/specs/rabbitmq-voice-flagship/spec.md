## Purpose

Demonstrate reliable voice control with explicit separation from bounded media transport.

## ADDED Requirements

### Requirement: Voice interruption and recovery
The application SHALL authorize sessions, separate media from control messages, bound buffering, handle interruption and reconnect, and recover duplicate or poison control deliveries.

#### Scenario: Interrupted response
- **WHEN** a new user turn cancels an active response
- **THEN** stale response media cannot resume and control state remains recoverable
