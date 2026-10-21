# Rails AI Foundry

Current version: unpublished **1.0.0 local candidate**. See [release preparation](docs/release-preparation.md)
for installation, reviewed upgrades and remaining public-distribution prerequisites.

Foundry 1.0 is a development-time conventions and skills kit built on Rails, [packs](https://github.com/rubyatscale/packs), [packs-rails](https://github.com/rubyatscale/packs-rails) and Packwerk, with native RubyLLM conventions. It supplies architecture guidance, optional small generators, focused checks and eight agent skills. Applications execute ordinary Rails, packs-rails, Dry::Operation and optional RubyLLM code. Foundry owns no loading, composition, transaction, event, projection or AI execution runtime.

## Start a new application

Install the local gem before running the executable:

```sh
gem build rails_ai_foundry.gemspec
gem install ./rails_ai_foundry-1.0.0.gem
foundry new my_app --specs=spec-kit
cd my_app
bin/rails generate foundry:skills
bundle exec foundry check --sources
```

Start with the installed `foundry-plan` skill when ownership is unclear, then use
`foundry-add-feature` to implement behavior and `foundry-verify` to prove it. Read
the application’s selected workflow and actual `package.yml`/`foundry.yml` first.
Use [the first-feature journey](docs/first-feature.md) for a complete worked example.
For human-approved AI work, continue with [the installed AI journey](docs/first-ai-feature.md).
Small context/component generators are optional shortcuts, not the required entrypoint.

The default application uses PostgreSQL, Puma, Hotwire and Solid Queue, with no additional cache. The command delegates application creation to Rails. Foundry is a development/test dependency; generated production code uses upstream libraries directly. Implement generated scaffold exceptions and behavioral tests before claiming a feature works.

Spec Kit requires the pinned Specify CLI 1.0.0 and its Python tooling. OpenSpec requires CLI 1.12.0. Setup preflights prerequisites and reports installation instructions rather than silently falling back. See [setup](docs/setup.md) for selection and interruption behavior.

| Application context | Default workflow |
| --- | --- |
| New, no established workflow | Spec Kit |
| Existing, no established workflow | OpenSpec |
| Established workflow | Preserve selection |
| Foundry repository | OpenSpec |
| Explicit opt-out | none |

Use `--specs=openspec` or `--specs=none` explicitly. Switching selection preserves documents and history; it does not convert or synchronize specifications.

## Existing applications

Add Foundry to development/test, and packs-rails plus dry-operation to application dependencies. Start with `bundle exec foundry adopt --format=json`, a read-only assessment. Then use `bundle exec foundry setup --specs=openspec` when adopting that workflow. Existing roots, application configuration and accepted Packwerk debt are preserved. See [adoption](docs/adoption.md).

Profiles (`rails_native`, `modular`, `domain`), events, CQRS, capabilities, workload and workflow are independent. `package.yml` owns topology; pack-local `foundry.yml` owns architectural intent; root `config/foundry.yml` owns defaults and workflow. Feature delivery stays in its pack, Rails base classes stay in the shell, and migrations stay at root.

Start with the [first-feature tutorial](docs/first-feature.md) and [packs usage](docs/packs.md): skills guide ownership and behavior, upstream tools manage packages, and tests prove the result. The [next program](docs/next-program.md) records the current skill-led direction.

For an existing screen, follow the installed [delivery extraction guide](docs/delivery-pack-extraction.md).
It moves controllers, helpers, views, JavaScript and tests together while preserving shell-owned
models and data, then verifies native loading, assets, authorization and browser behavior.

For Rails HTTP changes using Minitest or explicit RSpec, the verification skill includes an [executable helper](skills/foundry-verify/references/verification.md)
that runs the baseline and selected integration/system tests and rejects missing or failed evidence.
Require its invocation in application CI to block incorrect completion; installed instructions alone do not enforce it.

Read [native contexts](docs/native-contexts.md), [native AI](docs/native-ai.md), [architecture](docs/architecture/README.md) and [core workflow](docs/core-workflow.md). Use efficient Active Record queries in every profile, introduce ports for real boundaries, and keep ordinary writes synchronous. Choose optimizations from measured workload evidence.

For installed guidance updates, use the explicit [skill upgrade workflow](docs/skill-upgrades.md).
It previews changes, applies safe updates and retains customized guidance pending recorded review.
Ordinary generation continues to preserve local edits.

## Current conventions

Foundry uses only the current conventions described above. Historical ADRs and OpenSpec archives record earlier design decisions.

## Executable applications

Version 0.4 completes twelve independently bundled Rails applications. The directory prefix identifies the focal context's profile.

These application links refer to the repository; example applications are not installed with the gem.

| Application | Demonstration |
| --- | --- |
| [Rails-native AI chat](examples/rails-native-ai-chat-rubyllm-hotwire/README.md "Repository-only reference; not installed") | Persistent history, RubyLLM streaming boundary and Hotwire delivery |
| [Rails-native authorized tools](examples/rails-native-agent-tools-structured-output-rubyllm/README.md "Repository-only reference; not installed") | Per-call authorization, structured output and offline evaluations |
| [Rails-native pgvector RAG](examples/rails-native-rag-pgvector/README.md "Repository-only reference; not installed") | Tenant retrieval, embedding lifecycle and citations |
| [Modular Qdrant RAG](examples/modular-multi-tenant-rag-qdrant/README.md "Repository-only reference; not installed") | External vector boundary and validated rebuild/cutover |
| [Modular OpenSearch CQRS](examples/modular-opensearch-cqrs/README.md "Repository-only reference; not installed") | Derived search, outbox and recovery |
| [Modular RabbitMQ voice](examples/modular-realtime-voice-rabbitmq/README.md "Repository-only reference; not installed") | Reliable control, interruption and bounded media |
| [Modular Kafka/Karafka pipeline](examples/modular-event-pipeline-kafka-karafka/README.md "Repository-only reference; not installed") | Ordered retries, schema evolution and a NATS JetStream recipe |
| [Modular PostgreSQL/Sidekiq outbox](examples/modular-transactional-outbox-postgresql-sidekiq/README.md "Repository-only reference; not installed") | Atomic intent, lost-job recovery and idempotent fulfillment |
| [Domain RES ledger](examples/domain-event-sourced-ledger-rails-event-store/README.md "Repository-only reference; not installed") | Authoritative streams and optimistic concurrency |
| [Modular async GraphQL](examples/modular-graphql-async-dataloader/README.md "Repository-only reference; not installed") | Batched concurrent reads, tenant/role cleanup and Falcon |
| [Rails-native Next.js/GraphQL](examples/rails-native-nextjs-graphql/README.md "Repository-only reference; not installed") | Rails-root monorepo with an independent frontend |
| [Modular legacy adoption](examples/modular-legacy-adoption-packwerk/README.md "Repository-only reference; not installed") | Incremental extraction and no-new-debt checks |

Each app owns its workflow, locks, acceptance command and CI lane. Eleven greenfield apps use Spec Kit;
legacy adoption uses OpenSpec. Read [integration recipes](docs/integration-recipes.md),
[data recipes](docs/data-recipes.md) and [tested combinations](docs/compatibility.md) before adapting code.
Normal model tests remain offline; data/broker tests use disposable loopback services. Local passing evidence
does not claim hosted CI, live-model quality or production throughput. Publishing remains separate.

## Development

Use Ruby 3.4.10 and Node 20.19.0 from `.tool-versions`. Select managed Ruby explicitly:

```sh
export PATH="$HOME/.asdf/installs/ruby/3.4.10/bin:$PATH"
bundle install
npm ci
bundle exec rake test
bundle exec rake test:package
bundle exec rubocop
ruby script/validate_skills
npm run spec:validate
```

Optional AI and real workflow acceptance run in separate lanes. See [CONTRIBUTING](CONTRIBUTING.md) and [compatibility](docs/compatibility.md). Normal tests prohibit external model requests. MIT licensed.

The [0.5 advanced composition and evidence guide](docs/advanced-composition.md) links optional ROM/DI/workflow recipes, experimental vectors, disposable debt auditing and parity, budgeted evaluations and controlled benchmark results. All optional recipes own separate bundles. The [coordinated knowledge program](docs/next-program.md) adds an integrated application, executable adoption journey and [coding-agent benchmark suite](benchmarks/README.md "Repository-only reference; not installed"), with the measured pilot status recorded explicitly.

The [1.0 stable contracts and upgrade guide](docs/stable-contracts.md) defines schema 1, versioned diagnostics, generator/skill ownership, support tiers and SemVer policy. `foundry contracts` lists the installed contract assets without booting an application. Contributors validate those assets with `npm run contracts:validate`.
