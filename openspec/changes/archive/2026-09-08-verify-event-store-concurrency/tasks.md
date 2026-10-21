## 1. Schema and test boundary

- [x] 1.1 Validate processing columns/indexes before effects; test missing, nullable, partial, composite and valid constraints on SQLite and PostgreSQL.
- [x] 1.2 Add a separate PostgreSQL bundle and isolated schema host; verify missing explicit URL rejection and PostgreSQL 17 version.

## 2. Concurrency and completion

- [x] 2.1 Verify first lock-row creation, duplicate delivery, rebuild/publication and stale aggregate races with independent connections and barriers.
- [x] 2.2 Run SQLite matrix and PostgreSQL tests, RuboCop and strict OpenSpec; record exact local versions and outcomes, document setup, commit and archive after success.
