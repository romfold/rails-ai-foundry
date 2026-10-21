## Context

See proposal.md. Existing shared scaffold installation already provides conservative receipts and rollback. Every profile supports external adapters; light profiles support models and full profiles support persistence records. RubyLLM 1.16 exposes agent.chat, messages, model, and message.cost publicly.

## Goals / Non-Goals

Track operational invocations through explicit injected wiring. Do not add global subscribers, provider abstractions, business retries, conversation persistence, schema migrations on installation, or automatic composition changes.

## Decisions

- Require `rails_ai_foundry/ai/execution_tracker` explicitly. It activates the existing optional RubyLLM integration; core does not load it.
- Inject a store responding to `transaction_open?`, `start(attributes)`, and `finish(execution_id, attributes)`. The generated store accepts `record:` through its constructor. Use independent short Active Record writes; no transaction wraps the business block.
- Preflight named metadata as bounded strings, the block, an actual RubyLLM agent with a plain chat, freshness, and transaction state. Invalid caller input fails before execution. A storage error checking transaction state is reported as tracking failure and does not block business work; successful transaction detection rejects the invocation.
- Claim chat identity atomically through a process-local mutex and WeakMap, preventing reuse across tracker instances without retaining chats or changing their classes. Claims persist while the chat lives, even if it is reset or the invocation fails. One shared tracker may serve concurrent separate agents; per-call state belongs to a separate execution object.
- Capture identity before execution; validate response/model identity during usage collection. Unsupported model switching invalidates usage and reports an error without changing a business outcome that already happened. Do not support streamed, nested, multi-model, or reused-chat workflows.
- Read assistant messages by object identity once after the block. Sum a token field only when all observed messages supply it; no responses means unknown. Sum message cost totals with decimal conversion only if all costs and each response's input/output counts are known; RubyLLM can otherwise return a partial total. Never read or serialize content/tool payloads/raw responses. Partial responses remain measurable after business failure.
- Use a unique string UUID plus conventional database primary key. Store `execution_id`, `use_case`, `agent`, `prompt_version`, `model_alias`, `provider`, `model`, `trace_id`, `subject_ref`, `status`, `started_at`, `completed_at`, `duration_ms`, input/output/cached/cache_creation/thinking token counts, `estimated_cost`, `failure_kind`, and `failure_class`. Use nullable bigints for tokens and decimal(20,10) for estimated USD cost. Do not generate arbitrary JSON metadata.
- StandardError from storage, usage, or reporting is isolated. Default `tracking_error.rails_ai_foundry` notifications contain only execution_id, stage, and error_class. Do not forward exception objects/messages. Fatal process exceptions are not converted into successful finalization.
- Generate fixed `ai_execution` and `ai_execution_store` artifacts via registry paths. A YAML receipt records layout version, package, destinations, and selected migration. Reject another create-table migration without a matching receipt. Profile changes require manual reconciliation when record paths change.
- Installed guidance teaches explicit adapter/composition wiring, metadata minimization, retention ownership, and manual investigation of running rows. Telemetry is operational even in an event-sourced package; do not append it to domain event streams.

## Risks / Trade-offs

- Tracking can fail without a durable row → sanitized callback/notification makes loss observable while preserving the agreed business availability policy.
- Process death leaves running records → document manual investigation; no unsupported recovery promises.
- Model changes or missing usage make accounting incomplete → leave unknown metrics null and report collection errors rather than inventing values.
- Application code can violate the synchronous boundary dynamically → document the boundary and test supported use; no global provider interception.

## Migration Plan

Preview and generate into an existing v2 package, review/apply the host migration explicitly, then wire the injected store and tracker in composition and call from the external adapter. Commit consumer changes before deployment. Disable tracking wiring to roll back behavior; preserve rows until retention/deletion is separately reviewed. V1 migration remains separate.
