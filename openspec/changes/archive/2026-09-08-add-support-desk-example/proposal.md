## Why

The tested support-triage workflow needs a runnable reference application that demonstrates package boundaries, persistence, and visible failure handling. An offline application makes those behaviors reviewable without credentials or paid requests.

## What Changes

- Expand the existing example into a local Rails support desk with SQLite and an independent locked bundle.
- Add ticket creation, listing, detail, and explicit synchronous triage.
- Add a read-only Knowledge domain package and deterministic, request-local RubyLLM simulation.
- Verify browser behavior, setup repetition, persistence, and existing compatibility matrices.

## Capabilities

### New Capabilities
- `support-desk`: Local ticket persistence, interface, and package-owned operations.
- `offline-provider-simulation`: Deterministic RubyLLM scenarios with outbound requests blocked.

### Modified Capabilities
None. The existing Support::Triage.call contract and framework behavior are preserved.

## Impact

Changes the example application, its tests, documentation, and the lightweight AI fixture mount. The framework gem excludes examples and retains version 0.1.0, MIT, Ruby >= 3.3, and railties >= 7.1. The application selects Ruby 3.4.10, Rails 8.1.3.1, SQLite 2.9.6, RubyLLM 1.16.0, and WebMock 3.26.4. No authentication, deployment, live-provider activation, or publishing.
