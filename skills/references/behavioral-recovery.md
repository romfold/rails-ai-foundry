# Behavioral contracts and recovery evidence

Read this when the requested work changes an entrypoint, authorization boundary, background
publication, realtime delivery, projection rebuild or resource budget. Choose checks for the actual contract;
do not introduce the knowledge recipe's advanced stack into unrelated applications.

## Verify the contract through its caller

Name the supported caller (HTTP request, job, tool or public package API), expected result,
permitted side effects and authorization context. Exercise that caller with real persistence
where the contract depends on transactions or queries. Check persisted state after failure,
not merely the return value. Keep Packwerk and source diagnostics as separate evidence.

Permit equivalent direct, delegated and relocated implementations when they preserve the
same observable behavior and declared package boundary. Avoid grading method spellings,
controller file locations or literal call syntax. A service double can prove that a declared
public API was used; an endpoint test must still prove its output and authorization behavior.
Same-pack Rails delivery may use internal models when its contract allows it. Do not turn a
particular extraction exercise into a universal model-access prohibition.

Include an intentional fault that static checks could miss: foreign-tenant output, a failed
transaction leaving a write, a stale revision returned as current, or an acknowledged event
whose effect was never persisted. Confirm the behavioral check rejects it. Keep evaluator
fixtures outside any candidate coding-agent environment; this guidance does not authorize
agent trials or provider requests.

## Bound work and prove recovery

For a claimed resource bound, measure fetched rows/bytes and query counts on more than one
page of data. SQL LIMIT bounds materialization, not necessarily database CPU or total scanned
rows. State the result when the budget is exhausted; do not silently expand the budget or
return unauthorized/stale results to fill a page. Exercise oversized records explicitly.

For durable work, identify state/intent commit, destination persistence, local acknowledgment
and selection cutover as separate failure points. Kill a separate worker at explicit barriers
and restart it against the same persisted work identity. Use clocks or controlled lease expiry
for ownership tests instead of timing sleeps. Test delayed former owners as well as retries.
A database lease alone does not cancel an external request already submitted.

An uncertain destination response is an unknown outcome. Inspect actual destination state
before claiming success or unchanged selection. Prevent cancellation, replacement and cleanup
from contradicting a pending cutover. A count match alone does not establish identity,
revision or content equality. Provider work belongs outside writer transactions; revalidate
authoritative visibility before returning projected results or citations.

Keep normal providers deterministic and offline. Record commands, versions, source hashes,
observed failures/timeouts, recovery duration and operational limits. Separate runtime samples
from coding-agent experiments and preserve original experiment grades. Do not infer a measured
improvement for code changed after the experiment.

## Realtime updates and local drafts

Verify both the acting browser's response and a separately authenticated viewer's broadcast.
Wait for connected subscriptions and observable DOM changes, not arbitrary sleeps. Trace the
actual stream, payload and target when a request succeeds but another viewer does not update.
Exercise committed creation/deletion and rollback; no rolled-back change should be broadcast.

When several commit hooks use the same callback method, inspect the effective registrations:
Rails can replace an earlier registration with a later one. Use distinct callbacks or an
appropriately scoped combined hook, and prove each intended action publishes after commit.
Callback declarations alone do not establish delivery.

For browser actions, inspect the rendered form's destination, effective HTTP method,
accessible control and required attributes. Helpers with label, URL and options arguments
can render valid-looking but incorrect HTML when arguments are omitted or misplaced. Verify
the action through the visible control and check the resulting authorized state change.

When reusing viewer-specific CSS or Stimulus controls, inspect their actual selector and
data-attribute contracts. Test nested records owned by different people: an ancestor's
visibility rule can hide an authorized inner action. Check computed visibility after the
reveal interaction, rather than inferring it from HTML attributes or a successful request.

Use stable entry IDs or another demonstrated idempotency mechanism so response/broadcast
echoes do not duplicate items. Keep shared markup independent of the originating request's
current user; viewer-specific controls need viewer-local rendering and server authorization.
Updating one item must not replace another viewer's composer. Test unsaved input through
broadcasts and any existing refresh/morph behavior, as well as reset/cancel for the actor.
Trace updates to parent records from `touch` and callbacks as well as the explicit stream
target. A narrow child update can still trigger a destructive parent replacement.
Equivalent append/remove, targeted update, or guarded morph designs are valid when these
behaviors pass. Include faulty no-delivery, duplicate-echo and draft-wiping controls.
