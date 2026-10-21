## Why

The final 1.0 core is verified locally, but the twelve applications need a complete acceptance pass at the final commit and hosted CI evidence is still absent.

## What Changes

- Run all twelve locked applications with disposable services against the final 1.0 source matching the built gem.
- Record command outcomes, failures, provenance and cleanup; fix demonstrated release blockers if found.
- Verify hosted CI after a repository destination becomes available, and prepare a release decision without publishing.

## Capabilities

No behavioral requirement changes are proposed. This verification/evidence change skips specification deltas. Any demonstrated behavioral defect will receive a concrete regression and an appropriate spec update if its contract changes.

## Impact

Disposable acceptance infrastructure and release evidence. Live model/provider spending, agent productivity experiments and publication remain separately configured work.

## October local candidate authorization

The user authorized audit-snapshot implementation followed by a current local candidate,
with all dependencies unchanged, hosted CI skipped and no publication. Preserve the older
hosted-CI task as a deferred historical gate; it does not block this explicitly local
deliverable. Freeze a fresh committed source/archive, refresh release-critical acceptance,
attribute reused unchanged corpus evidence, correct the current changelog, and record the
release decision and missing public destinations. Do not configure a remote, create a tag
or publish as part of this work.
