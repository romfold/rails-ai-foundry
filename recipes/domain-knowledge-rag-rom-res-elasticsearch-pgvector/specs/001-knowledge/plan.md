# Implementation plan

Use Rails delivery and upstream package loading. The installed configuration governs
profiles and boundaries. PostgreSQL document state is authoritative; RES carries
integration events. Application-owned ROM commands, SQL delivery leases, Elasticsearch
indices, pgvector tables and RubyLLM adapters implement the behavioral contract.

Keep the core gem outside production execution. Test real disposable databases and
search services, deterministic providers, native operation failures, concurrent claims,
crash windows, tenant isolation, invalid citations and rebuild recovery. Record executed
commands and limitations in the recipe README. Reconcile this plan and tasks whenever
requirements or implementation change; agent reports are not acceptance evidence.

Use the Knowledge journal and public paged API for commit-safe catch-up. Search owns run
leases, manifests and destination recovery. Keep exact vector SQL and bounded refill;
retain the global writer gate as a documented limitation. A zero-delta final activation
policy keeps providers and corpus validation outside the gate. Reconcile ambiguous alias
actions before cleanup or another activation. Additive operational migrations preserve
business rows/events. See `../../../../docs/knowledge-operations.md` for the runbook and
the adjacent evidence record for the deterministic scale and process-crash acceptance.
