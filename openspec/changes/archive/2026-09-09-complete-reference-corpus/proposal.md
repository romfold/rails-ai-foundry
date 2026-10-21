## Why

The four 0.3 flagships establish data and recovery conventions, but eight approved reference applications and advanced integration recipes remain absent. Completing 0.4 makes the twelve-app corpus executable without expanding Foundry's production runtime.

## What Changes

- Add independently bundled chat/Hotwire, authorized agent tools, Qdrant RAG, Kafka/Karafka, PostgreSQL/Sidekiq outbox, RES ledger, GraphQL/async and Rails-root Next.js applications.
- Exercise NATS durable messaging in the event-pipeline application and Falcon in the async GraphQL application.
- Initialize each greenfield workflow with pinned upstream Spec Kit; keep current apps and Foundry's OpenSpec history.
- Verify real infrastructure behavior, independent CI commands, profile-first names, production loading and supported combinations.

## Capabilities

### New Capabilities

- `complete-reference-corpus`: eight additional independent applications, with scenario-specific correctness and upstream integration evidence.

### Modified Capabilities

None. Existing recipes and catalog contracts remain authoritative.

## Impact

Examples, optional dependencies, service recipes, CI, skills/references and delivery documentation. No new core runtime or higher Ruby/Rails compatibility floor. ROM, experimental vectors, full adoption/parity tooling and production benchmarks remain 0.5. Publishing is separate.
