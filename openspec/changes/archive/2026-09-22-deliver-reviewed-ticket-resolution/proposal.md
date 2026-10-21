## Why

The authorized-tools example demonstrates delegated execution but does not demonstrate durable AI work requiring a human decision. Add an executable, application-owned approval boundary with recovery evidence while preserving the existing delegated-tool API.

## What Changes

- Extend Assistance with persisted resolution requests, generation attempts, immutable proposals and audit history.
- Add fenced generation, durable discovery, approval and atomic local ticket closure using native Rails and Solid Queue.
- Add an accessible review UI and explicit HTTP interfaces, including tenant isolation, authorization and conflict semantics.
- Verify failures, process recovery, browser behavior and faulty controls; document reusable guidance only after acceptance.

## Capabilities

### New Capabilities
- `reviewed-ticket-resolution`: human-reviewed, durable local ticket resolution in the existing Rails-native example.

### Modified Capabilities

None. Existing answers, catalog identities, Foundry interfaces and benchmark evidence remain unchanged.

## Impact

Changes the independently bundled authorized-tools example, additive root migrations, its living Spec Kit artifacts, product guidance, compatibility evidence and roadmap. Adds an ADR. No production Foundry runtime, provider credentials, paid evaluations or additional agent studies are introduced.
