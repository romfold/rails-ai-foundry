## Context

See proposal.md. Assistance currently provides an offline answer endpoint and an explicitly delegated close tool. The new workflow is independent of that demonstration and preserves its contract.

## Goals / Non-Goals

Provide durable local effects and a reviewable authorization boundary. Do not promise exactly-once provider calls, support editable proposals, external actions, or introduce a framework runtime.

## Decisions

- Use additive PostgreSQL tables, a partial unique active-ticket index and requester/key uniqueness. Store a canonical input digest for idempotency conflicts.
- Serialize application transitions by locking identities in ascending ID order, then ticket, then request. Approval binds an immutable proposal digest and source lock version. Recheck requester and approver at execution; readers may request, active same-tenant editors may approve including themselves.
- Keep generation outside transactions. Claim with a fresh token and 90-second lease, persist at most three attempts, and fence every result with current ownership, permission and revision checks. Thirty-second provider timeout and zero transport retries bound each call.
- Persist work before best-effort enqueue. A 30-second recurring sweep of at most 50 database work items recovers lost scheduling. Queue delivery never establishes business authority.
- Commit local ticket closure, resolution, request completion and completion audit atomically. Audit business records are append-only; logs contain only safe identifiers and classifications.
- Use native Rails delivery and a status-only Turbo frame refreshed with bounded polling. Browser sessions use explicitly documented demo identities and CSRF protection; API identity comes only from trusted bearer tokens.
- Use offline deterministic providers by default and injected controlled RubyLLM responses for adapter verification. No implicit live provider selection.

## Risks / Trade-offs

- Provider replay after process death → document at-least-once invocation and fence persisted results.
- Permission or ticket changes during generation/review → mark stale and require a new request.
- Demo authentication is unsuitable for production → label it explicitly and retain tenant/permission checks server-side.
- Queue loss or duplicate jobs → durable discovery and atomic idempotent execution.
- Rails locking and PostgreSQL constraints require service tests → use a disposable database and synchronized process tests.

## Migration Plan

Stop workers, apply additive migrations and queue schema, then restart workers and recurring discovery. Preserve existing tickets and events. On rollback stop workers first and retain requests, attempts, audit records and additive ticket fields; do not discard review history.

Browser form submissions use ordinary 303 redirects to the status page; JSON asynchronous responses use 202 with Location and status_url. Browser sessions retain CSRF protection; API clients use trusted bearer identity.
