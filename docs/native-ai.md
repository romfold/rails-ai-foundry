# Native AI conventions

Native contexts generate ordinary RubyLLM 1.16 agents, tools and schemas. They execute without Foundry. Implement agents with direct upstream code; `foundry:agent NAME --context=NAME` is an optional scaffold.

Add `gem 'ruby_llm', '~> 1.16.0', require: false` to the application bundle and run `bundle install`. Keep `packs-rails` in the application's production dependencies. Require `ruby_llm` before calling `RubyLLM.configure` in an application initializer, and configure only selected provider credentials through the application's secret store.

Select the capability in the owning pack's `foundry.yml`, preserving its other fields:

```yaml
capabilities:
  ai:
    adapter: ruby_llm
```

Preview and generate:

```sh
bin/rails generate foundry:agent summarize --context=support --pretend
bin/rails generate foundry:agent summarize --context=support
```

The generator creates `Support::SummarizeAgent`, `Support::SummarizeTool` and `Support::SummarizeSchema` under the pack's `app/agents`, `app/tools` and `app/schemas`. Delivery placement is the same in all profiles. It also creates `packs/support/app/prompts/support/summarize_agent/instructions.txt`, `contract.yml` and `evaluation.yml` inside the owning pack, pack-owned authorization tests, and a generation receipt. Names derive from the configured context namespace, including nested namespaces and existing package roots.

The first agent creates `config/ai.yml` with an empty `shared.models` mapping. Existing configuration is preserved byte-for-byte. Choose model aliases in that file using ordinary Rails environment configuration, for example:

```yaml
shared:
  models:
    support:
      model: your-selected-model-id
      provider: your-selected-provider
```

Invocation uses upstream constructor injection and Rails configuration directly:

```ruby
selected = Rails.application.config_for(:ai).fetch(:models).fetch(:support)
agent = Support::SummarizeAgent.new(
  **selected,
  operation: authorized_tenant_scoped_lookup,
  authorize: ->(query:) { policy.allowed_query?(query) }
)
response = agent.ask(user_message)
```

The application supplies the trusted principal, tenant scope and policy. The model supplies only the query. The callback must return boolean `true` and runs on every execution before the operation; any other return value raises the tool's `NotAuthorized` error. Do not pass an operation result object as authorization. Authorization is not a substitute for enforcing tenant scope inside the operation. Construct an agent per independent conversation/request and keep external calls outside database transactions. Add application tests for invalid arguments, changed permissions, tenant isolation, provider failure, output validation and usage limits.

Generated agents inherit `RubyLLM::Agent` and use its `inputs`, `instructions`, `tools` and `schema` macros. Plain text is read with an explicit `File.read(File.expand_path(..., __dir__))` instruction block each time an agent is constructed. Lookup is relative to the agent source file and supports custom pack roots and nested/acronym namespaces. It is independent of process working directory and observes subsequent prompt edits. Missing prompts fail construction before a provider request. This deliberately avoids RubyLLM 1.16's default ERB prompt path: that path evaluates Proc inputs while resolving prompt locals, which can invoke injected operations before a tool call. There is no Foundry prompt loader or template engine. User messages and retrieved/tool content belong in their respective message roles. Never insert them into trusted instructions.

The [prompt contract](prompt-contracts.md) records ownership, prompt/evaluation file references, behavior, trust boundaries, output schema and allowed tools. Run `bundle exec foundry check --prompts` explicitly; it checks declarations and file existence without booting Rails or evaluating templates. It references the output schema without copying its fields or the architecture configuration. Update prompts, contracts and behavioral tests together. The generated schema asks for structured output; application code must validate returned shape and business meaning before acting on it. Scaffold tests do not establish model quality or prompt-injection resistance.

Generation never installs a provider, changes a profile/pattern, creates a persistence table, or selects a paid model. Missing capability selection produces actionable configuration instructions. Complete repeats preserve edits; collisions, unsafe paths, malformed configuration and partial scaffolds fail before new writes. Preview does not boot the application or load RubyLLM when using the Ruby installer API; invoking a Rails generator follows Rails' usual startup behavior.

Run generated tests with `bin/rails test packs/support/test/agents`, then application behavior and Packwerk checks. Normal tests remain offline. The optional [evidence recipe](../recipes/evidence/README.md "Repository-only reference; not installed") supplies a separately activated, budgeted live runner. Deliberate live evaluations require explicit activation, credentials, model selection and request/token/time/spend limits. Provider billing remains authoritative; transport retries can repeat tool side effects. Consult the upstream [agents](https://rubyllm.com/agents/), [tools](https://rubyllm.com/tools/) and [configuration](https://rubyllm.com/configuration/) documentation for supported APIs.

## Existing application-owned prompts

Complete existing agent receipts remain preserving repeats, including scaffolds with application-root prompts. Generation does not relocate prompts or refresh code. To adopt pack-local ownership, generate a comparison scaffold in a disposable app, review the agent lookup and prompt/contract/test files, and move the owned set explicitly in a reviewed branch. Preserve the original receipt as provenance outside the active generated set; accept a new receipt only with its matching complete reviewed scaffold. Do not edit receipt paths/hashes to bypass conflicts. Test prompt edits, missing files, authorization and fresh production loading after relocation. Root prompts remain appropriate for cross-context delivery and can declare owner `.` for explicit prompt checking.
