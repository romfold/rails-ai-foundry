# 0015: Package-aware verification with application-owned commands

Status: Accepted

## Context

Native framework defaults can omit tests kept inside packs. Passing package paths
explicitly can replace root discovery. A passing unrelated suite then provides a
misleading baseline, despite correct individual framework evidence.

## Decision

Offer opt-in discovery through the consumer's locked `packs-specification`. Combine
conventional root/package non-system files and explicit additions deterministically.
Keep browser selections explicit and require loaded-file evidence for every planned
baseline file, separately from test/example ownership. Retain native framework outcome
rules and the documented limitations of RSpec expectation counts and trusted tests.

Applications copy and review their own small `bin/verify-feature` command. Mixed
frameworks need two required invocations. Foundry neither owns a runner/configuration
runtime nor derives feature acceptance from changed files. Packwerk remains separate.

## Consequences

Existing invocations retain discovery behavior. Custom discovery/filter settings fail
conservatively in the opt-in mode; unusual applications can keep their existing explicit
workflow. New helper files ship through reviewed skill upgrades. Loading is evidence
of inclusion, not assertion quality or requirements completeness. No persisted manifest,
result cache, configuration key, task runner or automatic command overwrite is introduced.

See [the installed guide](../package-aware-verification.md) and the repository-only
[acceptance record](../evidence/2026-09-29/package-aware-verification.md "Repository-only reference; not installed").
