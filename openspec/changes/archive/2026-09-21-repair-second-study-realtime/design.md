## Context

The new candidate uses body/user rather than the earlier repair's content/creator. The existing preparer hardcodes the first study's two candidates. Current verification already restores trusted tests and uses offline credential-free containers.

## Goals / Non-Goals

Repair this candidate in disposable applications and provide fresh evidence. Do not change its data schema, upstream requirements, product skills or historical scores. No provider calls or live agents.

## Decisions

- Preserve the candidate's routes and attributes. Locate deletion by requested ID inside the authorized comment, then check ownership, preventing accidental deletion of the caller's own record.
- Distinct commit callbacks publish entry additions/removals to the existing card stream. Matching HTTP streams and stable entry IDs settle the submitter and deduplicate echoes.
- Permanent composer state survives morph/refresh. Success or cancel resets locally; invalid submission retains input. Shared markup uses account context and client-side viewer controls with server authorization.
- Add a named dated fixture set as a sibling of legacy fixtures. Optional preparer selection preserves the old entry point; provenance gates prevent accidentally repairing another candidate.
- Reuse fresh verification with unchanged upstream tests plus candidate-specific supplemental tests. Keep full/incremental repair equivalence and standalone faults as recorded evidence.

## Risks / Trade-offs

- Whole-strip replacements can be valid with composer protection; include a passing alternative instead of enforcing one markup shape.
- Callback and UI symptoms may share causes; capture the original request, persistence, callback and broadcast evidence before repair.
- A passing repaired candidate does not improve the paid score or demonstrate agent effectiveness; label all new outcomes human-assisted regression evidence.

## Migration Plan

No deployed application or business-data migration. New fixtures and reports are additive; existing preparer use remains supported.
