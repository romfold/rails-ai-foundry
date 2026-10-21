## Context

See proposal.md. The existing example owns the reusable triage agent, tool, schema, prompt, and call interface. The framework loads package Ruby roots but does not integrate package views/assets.

## Goals / Non-Goals

Goals: one workflow source, visible offline behavior, durable local tickets, and an independently reproducible application bundle.
Non-goals: authentication, external services, background jobs, history, email, uploads, live calls, or framework compatibility changes.

## Decisions

- Evolve examples/support_triage in place. Use normal Rails controllers/views/assets, with Active Record models and operations in Support. Keep migrations at the application root. Mount only original workflow files in the old lightweight AI host, avoiding a new Active Record requirement there.
- Use Support::Ticket with an explicit support_tickets table. Persist title, description, scenario, status, category, priority, summary, failure_code, and timestamps. Validate title <= 140 and description <= 4000, both required. Create untriaged; a POST triage action saves the latest success or failure. No database transaction spans model execution.
- Add Knowledge.search(query:) over committed JSON articles, with Support depending on Knowledge. The lookup is read-only and receives only the query.
- Use a process-wide WebMock guard and one stateless handler for a reserved .invalid endpoint. A serialized JSON user message carries the scenario and ticket text. Derive every response from that message and tool-result count; never use shared response queues. All successful scenarios perform one tool lookup before returning canned schema output. Excessive-tools keeps requesting calls until the existing fourth-call guard raises.
- Use fixed simulation-only model/provider settings and credentials, regardless of environment keys. Require the guard before Rails boots. Request logs exclude ticket parameters; no debug model logging. No real provider activation path exists.
- Use SQLite with independent ignored database files and a committed application lockfile. bin/setup runs bundle install and db:prepare, never reset or destructive seeds. bin/dev binds localhost without forwarding binding arguments.
- Use server-rendered HTML and local CSS through Propshaft, with a clear offline banner, accessible forms, and mobile layouts. No JavaScript dependency is needed for the ticket flow.

## Risks / Trade-offs

- Canned responses do not evaluate model quality -> disclose scenario-driven behavior throughout the UI and docs.
- A local single-user demo is not an authenticated service -> localhost binding and no deployment instructions.
- Process-wide WebMock changes network behavior -> confine it to this example, block all unstubbed requests, and test environment credentials cannot enable live behavior.
- New persistence files would break the lightweight host -> explicitly mount the original workflow subset from its single source.

## Migration Plan

Run the example's setup to create its own database and launch locally. Existing consuming apps need no changes. Stop the example to roll back use; preserve the local database unless deliberately discarded by the user.

## Completion against the evolved framework

The September 8 completion retains the current framework's Ruby >= 3.3 floor, introduced by intervening core changes. The original seven core and six AI runs remain historical evidence; current regression acceptance uses Ruby 3.3.10/Rails 7.1.6, Ruby 3.4.10/Rails 8.1.3.1, and Ruby 4.0.6/Rails 8.1.3.1.

Both legacy version-1 packages declare enforce_privacy and app/public metadata. Controllers use the public Support entry point for listing, building, finding, and triaging tickets. Ticket and TriageTicket remain private implementation classes. This satisfies the newer static boundary checks without migrating the example to another profile or changing the original triage workflow.
