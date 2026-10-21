# opensearch-cqrs-flagship Specification

## Purpose

Demonstrate a rebuildable search read model with verified catch-up, cutover and recovery.

## Requirements

### Requirement: Rebuildable projection
The application SHALL preserve authoritative database writes independently from search availability and support backfill, catch-up, validation, atomic cutover and recovery. Duplicate delivery SHALL not corrupt the projection.

#### Scenario: Search outage
- **WHEN** indexing fails after a business change commits
- **THEN** the change remains authoritative and recoverable publication intent supports later catch-up
