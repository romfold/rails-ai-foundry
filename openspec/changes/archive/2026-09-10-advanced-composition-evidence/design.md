## Context

See proposal.md. Current checks run Packwerk validate/check and hash accepted baselines, but cannot classify fully resolved debt. The core has no production execution layer; the corpus already supplies application-owned vectors, outboxes and offline AI examples.

## Goals / Non-Goals

Provide executable optional recipes and development evidence tools. Keep the twelve-app catalog unchanged; smaller recipe bundles are not additional flagship apps. No production runtime, automatic extraction, data conversion, live provider quality claim or guaranteed bill cap is introduced.

## Decisions

- Use independent recipes/ bundles for ROM/dry-system/Trailblazer and experimental vectors. A single ROM gateway owns state and outbox; explicit savepoint rollback handles failed native results. DI is wiring only; Trailblazer is an alternative native workflow recipe, not wrapped in a Foundry result.
- Audit and parity run upstream regeneration in temporary copies, compare normalized package/target/constant/type/source identities, and hash original inputs before and after. Reject symlinks and unsafe paths, exclude caches, vendor artifacts and secrets from snapshots. Do not parse console prose as a violation identity format. pks evidence is application/input/tool specific and only permits an explicit supplementary check; Packwerk still runs.
- Experimental vector recipes use explicit upstream HTTP protocols with timeout/error handling and trusted tenant/version arguments. Deterministic contract tests always run; a local Weaviate lane verifies actual behavior. Pinecone live credentials are not required to establish experimental protocol support.
- Evidence tooling is outside application runtime. Live RubyLLM calls are explicit, serialized, bounded, without automatic retries, with conservative input reservation and output limits; missing usage stops further calls. Report usage and configured pricing separately. Offline benchmark conditions use the same fixed implementation author, no model and workflow none, alternate order, retain raw samples and validate held-out behavior. An agent/onboarding protocol records matched conditions without inventing measured agent outcomes.

## Risks / Trade-offs

- Optional stacks can conflict with Rails dependencies: isolate locks and test actual combinations.
- Disposable copies can still boot application code: test-only environment, documented disposable database requirement; filesystem preservation is not a network sandbox.
- Static checkers differ: mismatch is useful evidence and blocks pks use, not a reason to weaken Packwerk.
- Provider pricing/token estimates vary: bound requests/time/output, fail closed on usage uncertainty and explicitly avoid guaranteed billing claims.
- Microbenchmarks are narrow: preserve raw data, repeated paired trials and label runtime versus onboarding evidence.

## Migration Plan

Add opt-in commands and recipes, verify core floors and built-gem distribution, update skills/docs and 0.5 metadata, reconcile verified specs and archive. Existing apps need no migration; publishing remains separate.
