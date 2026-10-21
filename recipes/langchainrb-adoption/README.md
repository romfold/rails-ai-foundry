# Experimental Langchainrb adoption

This independently locked recipe uses [Langchainrb](https://github.com/patterns-ai-core/langchainrb) 0.19.5 for an existing assistant integration. RubyLLM remains the default native AI convention elsewhere. This bundle has no Foundry, Rails or RubyLLM runtime dependency.

`SupportDesk::Conversation` creates a native `Langchain::Assistant` and advances its lifecycle with automatic tool execution disabled. It extracts requested calls through the upstream adapter, permits only `TicketLookup.lookup`, and dispatches that explicit method. The tool rechecks authorization and the constructor-bound tenant on every access. Model-supplied names cannot invoke arbitrary Ruby methods.

Run from this directory with Ruby 3.4.10 and Bundler 2.6.9:

```sh
BUNDLE_FROZEN=true bundle install
bin/verify
```

Acceptance replaces only provider I/O with `ScriptedLLM`; it uses the real assistant, adapter, message, function-definition and response objects. Socket connections are blocked. Tests cover completion, native tool round trips, denied authorization and cross-tenant access, unknown functions, history restoration and isolation, provider failures and bounded repeated tool requests. No live client or credentials are needed. The pinned dependency emits a notice about `logger` leaving Ruby's default gems in Ruby 4; the verified recipe lane is Ruby 3.4.10.

## Application responsibilities

The trusted plain prompt is read relative to this recipe, independent of the working directory. History snapshots contain user, assistant and tool messages; system instructions always come from the application. Restore only server-owned storage after authenticating its conversation owner. The JSON snapshot is a copy, not shared mutable session state. It is not a public history import API or durable conversation store.

Each `ask` accepts 1–2000 characters, permits six total provider attempts, two attempts per transient I/O failure and four tool calls per response. Failed processing stays failed and requires a fresh session or an explicit application recovery decision. These limits bound the demonstration; live adapters also require timeouts and request/token/time/spend budgets. Normal verification never enables live evaluation.

This tool only reads. Duplicate calls therefore recheck authorization and repeat the read. Before adding write tools, design idempotency, concurrent updates and durable receipts explicitly. Sequential tool execution does not establish exactly-once effects. User text remains untrusted conversation content, and tool authorization is enforced in code rather than delegated to the prompt.

The recipe adds no shared AI abstraction, generator or automatic migration. Keep existing integration boundaries deliberate. The separate CI matrix runs the same offline commands; hosted results are separate from local evidence.
