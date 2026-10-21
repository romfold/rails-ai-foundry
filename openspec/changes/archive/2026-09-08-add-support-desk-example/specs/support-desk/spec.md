## Purpose

Provide a local, runnable reference application with persistent tickets and explicit, inspectable triage outcomes.

## ADDED Requirements

### Requirement: Reproducible local application
The application SHALL provide idempotent bin/setup and localhost-bound bin/dev commands, its own pinned bundle, and persistent SQLite storage.

#### Scenario: Repeated setup
- **WHEN** setup runs with existing tickets
- **THEN** the database is prepared and existing tickets remain unchanged

#### Scenario: Restart persistence
- **WHEN** the application restarts after saving a ticket
- **THEN** the saved ticket and its last outcome remain available

### Requirement: Ticket interface
The application SHALL provide a ticket list, new-ticket form, and detail page with accessible labels, validation, empty states, and escaped user content. Titles and descriptions SHALL be required and limited to 140 and 4000 characters.

#### Scenario: Valid ticket
- **WHEN** valid input and a supported demo scenario are submitted
- **THEN** an untriaged ticket is saved and its detail page is shown

#### Scenario: Invalid input
- **WHEN** required text is missing, too long, or the scenario is unknown
- **THEN** the form reports errors without saving a ticket

#### Scenario: Missing ticket and unsafe HTML
- **WHEN** a missing ticket is requested or stored text contains HTML
- **THEN** missing tickets return 404 and text renders escaped

### Requirement: Explicit triage outcomes
A separate POST action SHALL run the existing workflow synchronously and persist the latest success or failure. Failure SHALL preserve the ticket and display a friendly explanation without raw provider errors.

#### Scenario: Success
- **WHEN** a success scenario runs
- **THEN** category, priority, and summary are saved with triaged status

#### Scenario: Failure
- **WHEN** a malformed response, provider failure, or tool limit occurs
- **THEN** failed status and a stable failure code are saved with no successful classification

#### Scenario: Repeat
- **WHEN** triage runs again
- **THEN** the latest outcome replaces the previous outcome without adding history

### Requirement: Package ownership
Ticket operations SHALL belong to Support and read-only Knowledge.search(query:) SHALL provide catalog lookup through the declared Support-to-Knowledge dependency.

#### Scenario: Lookup
- **WHEN** triage requests knowledge
- **THEN** the Knowledge public contract returns matching committed articles without modifying the catalog

#### Scenario: Public application boundary
- **WHEN** controllers list, build, find, or triage tickets
- **THEN** they use Support's public entry point and the full Foundry check reports no private cross-package references
