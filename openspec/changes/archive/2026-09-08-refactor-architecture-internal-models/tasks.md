## 1. Internal values

- [x] 1.1 Implement immutable package, profile, and component-location snapshots; test copied nested values and canonical paths.
- [x] 1.2 Delegate manifest and profile helpers and migrate internal decisions; verify mutable hash edits, v1/v2 round trips, and unchanged generator output.

## 2. Layer policies

- [x] 2.1 Extract six focused rules with explicit precedence; verify exact diagnostic messages, overlap cases, and existing projection effects.

## 3. Delivery

- [x] 3.1 Run core and installed-profile regression suites on all three current lanes, RuboCop, and strict OpenSpec validation; record actual results.
- [x] 3.2 Commit the isolated pure refactor and archive only after all acceptance checks pass.
