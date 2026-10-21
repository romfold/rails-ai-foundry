# Complete reviewed ticket resolution

Implement the four unfinished application service entrypoints used by this existing
Rails ticket application under `components/support_desk` / `SupportDesk`: RequestResolution.call, GenerateResolution.call,
ReviewResolution.call and ExecuteResolution.call. Their native jobs/controllers,
records, schemas, offline provider and UI already exist. Inspect their call signatures
and keep existing endpoints and ordinary ticket persistence working. These are local
application interfaces, not a required general service-object architecture: delegation
and equivalent implementations behind the existing callers are valid.

A reader requests an immutable proposed resolution. An active same-tenant editor may
approve, including the requester. Bind approval to the exact proposal digest and source
ticket revision. Never let generation close a ticket. Execute only approved local work;
recheck requester/approver authorization and revision, and atomically close the ticket,
store approved text, complete work and append one completion audit. Duplicate execution
must have no additional local effect. Preserve the existing explicit API status codes.

Enforce requester-scoped idempotency and one active request per ticket. Changed content
under the same key conflicts. Foreign-tenant resources are concealed. Record attempts,
provider provenance and safe failure classifications. Provider calls run outside database
transactions. Maximum three attempts, bounded backoff, 30-second provider timeout and
90-second fenced leases. Recheck ownership, cancellation, permissions and ticket revision
before accepting output. Invalid output and unavailable providers must not approve work.
Queue scheduling is a wake-up: pending state remains discoverable after lost scheduling.
Cancellation serializes against execution. Failed generation retries create linked work
and never renew approval. Preserve audit/history, not a reset to an earlier approval.

Use the supplied deterministic provider, never credentials or live model calls. Keep
questions/proposals bounded to 2,000 characters. Preserve plain-text rendering, server
permissions, CSRF, bounded status polling and unsaved scratch input. Test actual HTTP
callers, the review browser and process/queue recovery. Existing visible tests are a
baseline, not evidence that the new feature works. Add your own tests without changing
supplied tests or protected config, manifests, task instructions or installed guidance.

Package profile remains rails_native. Use efficient ordinary Rails code with no new
runtime, provider, orchestration engine or external action. Workflow is none.

The example in shipped guidance is prior art, not the task fixture. Adapt it to the
existing SupportDesk context and tests; do not create an Assistance pack or replace
application identity/configuration. Private evaluation cases are not shipped guidance.
