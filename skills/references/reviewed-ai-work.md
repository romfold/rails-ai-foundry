# Human-reviewed AI work

Use this reference when the requested feature separates proposing an action from a human's
approval and its later execution. Ordinary synchronous CRUD does not need this workflow.
Explicitly delegated tools may execute immediately when that authority is the intended contract;
a proposal agent must not receive those mutation tools merely because they already exist.

Keep requests, attempts, decisions and audit history in the owning application. Bind approval to
immutable proposal content and a source revision. Recheck current tenant and permissions at both
review and execution; a retry must not resurrect approval. Whether requester self-approval is
allowed is a product decision, not a universal separation-of-duties rule.

Commit work before enqueueing, and make persisted pending work discoverable after lost scheduling.
Run providers outside transactions with bounded attempts, timeouts and expiring ownership tokens.
Reject delayed former owners. Atomically commit local effects, completion and audit; queue replay
must not repeat them. Model invocation may repeat after a crash even when local effects cannot.
Define cancellation's serialization point and test both orders against execution.

Exercise the HTTP/job caller and the real review screen. Generated text is untrusted; preserve
unsaved input when polling and stop at terminal states. Turbo frame navigation preserves outer
frame attributes, so status flags that change must live inside refreshed content. Keep approval
visibly distinct from completion. Test revocation, changed revisions, duplicate delivery and
process death on both sides of the commit. Require faulty approval-bypass, revision-bypass,
stale-owner and duplicate-effect controls to fail assertions, not just crash their test harness.
Equivalent direct transaction scripts and delegated services are valid when these behaviors pass.

Executable source: `examples/rails-native-agent-tools-structured-output-rubyllm` in the Foundry
repository, with `bin/verify`, `bin/verify-controls`, HTTP/system tests and process recovery tests.
The repository's `docs/reviewed-ticket-resolution.md` links the example and operational runbook.
Installed gems provide guidance; they do not install this application or grant live-provider access.

For a source-checkout-free walkthrough, locate `docs/first-ai-feature.md` under
`bundle show rails_ai_foundry`. Follow its ticket, review, durability and verification
checkpoints in a disposable application first. Adapt ownership, existing authorization
and workflow deliberately; do not paste its demo shell over an existing application.
