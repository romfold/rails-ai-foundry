# Knowledge recipe constitution

Applications execute Rails and upstream libraries directly. Architectural configuration
belongs to installed Foundry and package files, referenced by specifications rather than
copied into them. PostgreSQL state is authoritative, access is tenant scoped, provider
calls stay outside writer transactions, and derived indexes must be rebuildable.

Use deterministic providers for normal tests. Verify behavior with executable acceptance;
workflow validation and completion messages do not prove correctness. Keep this living
specification, implementation plan and tasks reconciled as behavior changes.

Version: 1.0.0. Ratified: 2026-09-16. Amended: 2026-09-16.
