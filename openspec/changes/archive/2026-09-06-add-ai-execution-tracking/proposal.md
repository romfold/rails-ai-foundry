## Why

Profile-compatible AI generation is implemented, but consumers cannot yet record a business-level execution without inventing persistence and lifecycle wiring. Add explicit, optional operational tracking while preserving application outcomes and existing RubyLLM APIs.

## What Changes

- Add an injected execution tracker for a single fresh synchronous agent invocation and its tool rounds.
- Generate package-owned operational records, a store adapter, migration, tests, and conservative receipt through `foundry:ai_tracking`.
- Preserve business results and exceptions on telemetry failures; store only operational metadata.
- Bundle tracking guidance in the existing seven skills and prove installed workflows across the compatibility matrix.

## Capabilities

### New Capabilities

- `ai-execution-tracking`: Explicit tracking lifecycle, metadata persistence, safe generation, and failure isolation.

### Modified Capabilities

None.

## Impact

Optional AI runtime, one Rails generator using existing profile paths, consumer migrations, shipped skill references, and offline acceptance. No automatic agent/composition edits, provider calls, conversation storage, new profiles, examples, publishing, or pushing.
