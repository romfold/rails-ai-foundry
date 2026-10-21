## 1. Bounded enumeration

- [x] 1.1 Implement filtered batches, iteration-start boundary and PostgreSQL start-visibility filtering; verify empty filters, order, batch limits and concurrent appends.
- [x] 1.2 Use enumeration for rebuild while keeping history/read arrays and aggregate-save reread; verify existing return contracts.

## 2. Regression and delivery

- [x] 2.1 Verify unrelated unsupported events are not decoded, later-batch failures roll back, and PostgreSQL late commits remain excluded.
- [x] 2.2 Run SQLite and installed-profile matrix, PostgreSQL suite, RuboCop and strict OpenSpec; document bounded reads and full-stream limits, record results, commit and archive after success.
