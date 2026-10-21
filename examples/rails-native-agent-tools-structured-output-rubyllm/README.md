# Rails-native authorized tools and structured output with RubyLLM

The focal context is [assistance](packs/assistance/foundry.yml). This independent application uses direct
RubyLLM::Tool and RubyLLM::Schema classes, app-owned model aliases, pack-local prompts and ordinary Active Record.

```sh
docker compose up -d --wait
bundle install
bin/setup
bin/rails db:seed
bin/verify
bundle exec rubocop
bin/rails server
```

POST `/answers` with `Authorization: Bearer demo-reader` and JSON `ticket_id` (from the seeded ticket)
and `question`. Default delivery returns explicitly labeled offline evidence and performs no mutation.
The demo editor identity illustrates close permission. Replace demo tokens with your identity provider.

For a native provider integration, configure RubyLLM credentials and call
`Assistance::TicketAgent.with_model(actor_id: trusted_user.id).call(ticket_id: id, question: text)`.
This reads config/ai.yml, installs authorized lookup/close tools and requests AnswerSchema.
No live runner is included; ordinary tests prohibit external traffic. Closing through a model is appropriate
only where the authenticated principal has delegated that permission; use a confirmation flow otherwise.

Each tool rechecks active identity, tenant and current permission; a model cannot pass actor/tenant parameters.
The close tool locks the actor and ticket in one transaction. Repeated closure is harmless.
Response validation independently checks requested ticket identity and current database status. A bounded
summary remains untrusted generated prose, not verified factual evidence; render it as text.

Six offline tests evaluate authorization revocation, cross-tenant access, identity injection, fabricated
structured responses, prompt/tool/schema wiring, provider failures and HTTP identity. These are deterministic
correctness evaluations, not a live-model quality benchmark. Keep [the contract](specs/001-reference/spec.md)
and implementation plan/tasks reconciled. Foundry stays out of production execution.

## Human-reviewed resolution

Run `bin/jobs start` alongside Rails and visit `/demo/login`. A reader requests an offline proposal;
an active same-tenant editor (including the requester) approves the exact proposal and revision.
A native job rechecks authority and atomically closes the ticket, stores the approved resolution
and records completion. Approval alone is not completion.

The proposal agent has no mutation tools. The older `/answers` and explicitly delegated close-tool
demonstration retain their original contract. Read the [runbook](../../docs/reviewed-ticket-resolution.md)
for API inputs, demo authentication, retries, recovery, upgrade/rollback and privacy limits, and the
[acceptance record](../../docs/reviewed-ticket-resolution-evidence.md) for executable evidence.
`bin/verify` now requires Chrome/ChromeDriver and runs explicit HTTP and real-browser checks;
`bin/verify-controls` accepts two valid implementations and rejects four intentional behavioral faults.
