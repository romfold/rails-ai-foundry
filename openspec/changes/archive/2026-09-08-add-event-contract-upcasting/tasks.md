## 1. Contracts and composition

- [x] 1.1 Implement explicit Upcaster entries and owned chain validation; test positive/consecutive versions, duplicates, gaps, unknown types, cross-owner and incomplete chains.
- [x] 1.2 Wire empty-default composition declarations into the store and codec; verify only current contracts encode and historical data decodes into current immutable values.

## 2. Historical evidence

- [x] 2.1 Commit fixtures for every demonstrated transition; verify mixed versions, multi-step payloads, stable IDs/metadata/order and unchanged stored rows.
- [x] 2.2 Verify malformed output and sanitized transformation exceptions, including projection rebuild rollback without stored-event rewrites.

## 3. Delivery

- [x] 3.1 Add an ADR and event guidance describing deterministic application-owned transformations, fixture obligations and static-check limits; verify documentation links.
- [x] 3.2 Run event/installed-profile regressions on all current lanes, core isolation checks, RuboCop and strict OpenSpec validation; record results, commit, merge and archive only after success.
