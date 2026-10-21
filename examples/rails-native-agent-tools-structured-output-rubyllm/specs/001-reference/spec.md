# Authorized ticket assistance

An authenticated active user may ask about its tenant's tickets. Lookup never reveals another tenant's ticket.
Closing requires current close permission, checked within the mutation transaction on every call.
Tool arguments cannot select the actor or tenant. Revocation affects already constructed tool instances.
Structured output must reference the requested authorized ticket and its actual current status,
contain a bounded summary and no additional fields. Invalid responses fail visibly.
Offline evaluations cover forged IDs/statuses, injected arguments, revoked access and unavailable providers.
The native agent installs authorized RubyLLM tools, the output schema, pack-local instructions and configured root model alias.

## Reviewed local resolution

A separate workflow persists requests, at most three generation attempts and append-only audit
history. Readers request; active same-tenant editors may approve, including themselves. Approval
binds immutable proposal text/digest and the ticket revision. Execution rechecks current identities
and commits ticket closure, approved resolution and completion together. Requests use scoped
idempotency and one active request per ticket. Retry creates linked new work without old approval.

Generation is offline by default, bounded to 2000 characters and a 30-second provider timeout,
with no transport retry. Ninety-second leased ownership fences results. Thirty-second discovery
selects at most 50 eligible requests after lost scheduling. Model calls may repeat after crashes;
local effects cannot repeat after completion. Cancellation serializes against execution.

HTTP uses trusted identity, tenant concealment, 202 status URLs and 409 conflicts. Browser review
is CSRF-protected, escapes generated content and refreshes only status while preserving unsaved
notes. Polling stops on terminal states or after 120 attempts. Approved is distinct from completed.
The proposal agent has no mutation tools; existing delegated answers behavior is preserved.
