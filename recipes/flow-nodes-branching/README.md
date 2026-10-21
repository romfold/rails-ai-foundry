# Experimental FlowNodes branching

This independently locked recipe uses [FlowNodes](https://github.com/rjrobinson/flow_nodes) 0.1.0 directly. It is an optional graph workflow for teams that already need explicit branching; constructor injection and ordinary Ruby remain Foundry defaults. Foundry and RubyLLM are absent from this bundle.

`ReviewFlow.call` classifies a request into human review or delivery. The application owns request identity, an effect store and the result. Each call builds a fresh upstream graph. FlowNodes marshals parameters, so parameters contain data and constructor arguments hold callables and shared dependencies.

Run from this directory with Ruby 3.4.10 and Bundler 2.6.9:

```sh
BUNDLE_FROZEN=true bundle install
bin/verify
```

The offline tests cover both branches, unsupported routes, bounded failures and retries, interruption before and after an effect, lost acknowledgment, duplicate delivery, conflicting request content and independent requests. The network guard blocks socket connections, including loopback. No provider credentials are used.

## Operational limits

- In this pinned version, `max_retries` counts total attempts, including the first: classification gets three attempts and delivery two. Backoff is zero only to make acceptance deterministic.
- The effect store is a mutex-protected in-memory demonstration. Deduplication survives repeats in one process, not process restart. Production effects need a database uniqueness constraint and atomic business-state/receipt transaction, or a destination with equivalent idempotency guarantees.
- An interrupt stops graph progress; it cannot undo an effect that already happened. Repeating the request uses the same key. There is no durable scheduler, persisted graph state, cancellation protocol or process-crash recovery claim.
- The classifier is injected. The recipe verifies graph semantics, not model classification quality. Do not add model calls inside a database transaction.

Copy the bounded application code only after deciding that a graph improves the actual workflow. It adds no Foundry execution API and does not change profiles, events, CQRS or the application's specification workflow. The separate CI matrix runs these same commands; hosted results are separate from local evidence.
