## Context

See proposal.md. Existing ROM and data recipes verify isolated behavior, not a complete Rails composition. Use the managed Ruby 3.4.10/Rails 8.1 lane with independent dependencies; core floors remain unchanged.

## Goals / Non-Goals

Prove a usable knowledge application and actual failure recovery. No authoritative event sourcing, distributed transaction, Foundry runtime, automatic adoption or paid provider evaluation.

## Decisions

- Four packs: Access (Rails-native), Knowledge (domain), Search and Answering (modular). Constructor injection and public APIs establish ownership. Migrations and composition initializers stay at root; prompt files stay with Answering.
- ROM owns document rows and outbox intent in one PostgreSQL gateway. A pure document policy validates title/body, lifecycle and expected revision. Public writes use one Dry::Operation result boundary and savepoint rollback.
- Persist leased work with a random fencing token and expiry. Publish a stable metadata-only event to RES after the ROM commit. Verify existing event content on duplicate publication; create independent search/vector work in the acknowledgment transaction. No external subscriber effects occur during publication.
- Workers reclaim expired work, retry bounded failures and quarantine poison payloads. A late worker cannot acknowledge with an obsolete token. Projection revision guards and authoritative visibility make duplicate work harmless.
- Elasticsearch and pgvector are derived data. Exact vector ranking uses bound SQL through the Search-owned ROM gateway. Recheck the current published revision under the Knowledge write gate before storing computed embeddings.
- Use a transaction-level PostgreSQL advisory write gate for state changes and bounded final rebuild validation. Backfill occurs outside the gate; final catch-up uses current database snapshots. Provider work never runs under the gate. Candidate validation failure leaves the active alias/version intact.
- Use native RubyLLM adapters with offline injectable equivalents. Demo token authentication is explicit; tenant request parameters are never authority. Revalidate authorization/current citations before returning answers.
- Solid Queue schedules polling; database delivery records remain the source of recoverable pending work. Independent PostgreSQL/Elasticsearch Compose services bind only to loopback. Record tested dependency versions instead of inferring compatibility.

## Risks / Trade-offs

- Duplicate transport/provider work → stable event identities, revision checks and destination receipts; no exactly-once billing claim.
- Finite demonstration corpus/write gate → bounded timeout and explicit limitations; no production throughput claim.
- Cross-connection atomicity → no external effects until the ROM state transaction commits.
- Event metadata survives content deletion → events contain identifiers/revisions, not document bodies.

## Migration Plan

This is a new independent recipe. Existing examples and business data are untouched. Dispose only of named local acceptance databases and Compose volumes. The subsequent adoption change owns an explicit, tested application-specific persistence transition.
