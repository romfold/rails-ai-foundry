# Plan

Use installed application/pack configuration. Persist users and tickets with PostgreSQL constraints.
Construct RubyLLM tools with a trusted actor ID and query current authorization at each execution.
Keep close mutation inside a database transaction. Validate schema shape plus authoritative ticket identity/status.
Use deterministic evidence for default HTTP delivery and constructor-injected native chat for model integrations.
Verify HTTP identity, cross-tenant tools, revocation, output validation and provider failure without external requests.

Use application-owned Active Record transactions, Active Job and Solid Queue. Lock identities
in sorted order, then ticket then request; fence generation by token and revision after provider
I/O. Queue submission follows commit and database discovery supplies recovery. Keep delivery,
jobs, services, prompts and schema in Assistance, migrations at root. Verify process deaths,
current authorization, concurrent decisions, HTTP and actual browser behavior. See ADR 0012
and the reviewed-resolution runbook; architecture configuration remains in installed manifests.
