# 0005: Application-level simulation and an independent reference stack

Status: Accepted

## Context

The existing support-triage workflow proves optional RubyLLM integration in a minimal host. A runnable example must demonstrate persistence and user-visible failure handling while preventing live provider requests. Adding Active Record or simulation dependencies to the framework would change unrelated consumers.

## Decision

Expand examples/support_triage in place with an independent, locked Rails application targeting Ruby 3.4.10, Rails 8.1.3.1, RubyLLM 1.16.0, sqlite3 2.9.6, and WebMock 3.26.4. Preserve Foundry version 0.1.0, MIT licensing, and its existing compatibility floors.

Support owns tickets and outcome persistence; Knowledge exposes a read-only catalog search. Reuse the original triage interface and workflow files. Keep migrations and HTTP presentation in ordinary application directories.

Install request-specific WebMock simulation at application boot. Use a reserved .invalid endpoint and placeholder credential, and block unstubbed HTTP requests. Derive responses from the serialized scenario and conversation state rather than shared queues. No environment credential enables live behavior.

## Consequences

The example exercises actual RubyLLM serialization, tool callbacks, and validation without a model account or paid calls. Deterministic scenarios establish integration behavior, not model quality. HTTP interception does not sandbox arbitrary application code.

The example has its own dependency lifecycle and SQLite data. Core AI tests mount only original workflow files, preserving their lightweight compatibility matrix. The framework gem excludes the reference application. Local persistence is implemented here; a general AI persistence integration remains deferred.

The app is single-user and localhost-only. Authentication, deployment, external search, streaming, and live-provider activation require separate changes.

## Completion note — 2026-09-08

Intervening framework changes raised its Ruby floor to 3.3 before this example was finalized. Completion preserves that current floor; the application remains on Ruby 3.4.10. Public Support methods now mediate controller access to private package classes, and both packages declare privacy metadata required by the current checker. The original workflow interface remains unchanged.
