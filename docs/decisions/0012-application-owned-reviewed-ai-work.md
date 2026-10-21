# 0012: Application-owned reviewed AI work

Status: Accepted, September 22, 2026. Implementation evidence is tracked by
`deliver-reviewed-ticket-resolution`; acceptance is not implied by this decision.

## Context

ADR 0011 keeps execution in Rails and upstream libraries. The authorized-tools example already
has a delegated close tool, but immediate delegated authority does not demonstrate a human
approving a particular generated proposal before durable execution.

## Decision

Represent work as ordinary application records and Active Job jobs. PostgreSQL constraints and
transactions establish request identity, current authorization and atomic local effects. Solid
Queue is a wake-up mechanism; a recurring query recovers pending database work. Provider calls
run outside transactions, with bounded attempts and leases fenced by fresh ownership tokens.

Approval binds immutable text and the source ticket revision. Any active same-tenant editor,
including the requester, may approve. Execution revalidates both requester and approver and
commits ticket closure, approved resolution, completion and audit together. The proposal agent
receives no mutation tool. The existing delegated close-tool API retains its different contract.

## Consequences

No orchestration engine, generic executor, Foundry runtime or configuration key is introduced.
Retries may repeat provider invocation, but replay cannot repeat a committed local effect.
External actions need separately designed idempotency and reconciliation and are excluded.
Application records retain review history; operational logs omit business content and raw errors.
Demo authentication and local-only effects keep this an executable teaching application, not
production identity infrastructure. Browser and crash tests establish the behavior rather than
class names, job declarations or architecture checks alone.

See the [runbook](../reviewed-ticket-resolution.md) and
[Rails Active Job guidance](https://guides.rubyonrails.org/active_job_basics.html) for transaction
and queue considerations. A shared queue database is convenient here, not a correctness premise.
