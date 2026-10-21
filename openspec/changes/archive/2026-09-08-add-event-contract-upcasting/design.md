## Context

Codec currently requires exact TYPE/VERSION registration. Contracts owns package-to-contract authorization, Runtime prepares stores from compositions, and projection rebuild already provides transactional rollback. See proposal.md for motivation.

## Goals / Non-Goals

**Goals:** Explicit current-contract evolution, owned declaration validation, isolated data transformations and unchanged persisted envelopes.

**Non-Goals:** Multiple current contracts per TYPE, historical record writes, IO enforcement, snapshots, automatic compatibility inference or changed aggregate-save rereads.

## Decisions

- Expose Events::Upcaster.new(type:, from:, to:, transform:) with an optional block alternative. Validate declaration shape at construction; use a registry to validate ownership, duplicate steps and complete chains against Contracts before use.
- Composition.event_upcasters defaults to []; Runtime passes declarations keyed by owner into Store. Existing direct Store callers default to no upcasters.
- Keep encode's exact current class/version check. Decode resolves the current class, copies historical JSON-compatible data, invokes consecutive transforms and validates every output before current-contract construction. Transformation inputs are isolated mutable copies; output contracts remain immutable.
- Move ContractError into a lightweight event error file so declarations need not load Rails or the persistence adapter. Sanitize transformation errors and clear exception causes to avoid exposing original payload-bearing errors.
- Use committed fixtures for 1-to-2 and 2-to-3 transitions, direct registry/codec tests plus a real SQLite host for mixed-version aggregate/projection replay, immutable stored-row snapshots and rebuild rollback. Preserve existing callback/transaction behavior.

## Risks / Trade-offs

- Application code can perform IO or nondeterministic transformations; documentation and committed historical tests are required, while static rules cannot prove purity.
- Declared historical support becomes a compatibility obligation; removing a required transition makes reads fail explicitly.
- Payload transformation errors can contain sensitive data; messages identify only type and versions, with no cause chain.

## Migration Plan

Deploy current contracts and complete fixture-backed transitions together. Keep historical records untouched. Rollback requires code that can still read any newly written current versions; do not claim that reverting source alone reverses event evolution. Publishing and migrations are outside this local change.
