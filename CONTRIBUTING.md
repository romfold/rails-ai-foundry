# Contributing

Keep personal workstation paths and credentials out of committed documentation
and evidence. Use repository-relative paths or `$HOME` in commands, review logs
before committing them, and record evidence redactions separately from original
trial results. See [the privacy review](docs/privacy-sanitization.md).

Read [the architecture](docs/architecture/README.md), [the approved implementation program](docs/implementation-program.md) and relevant OpenSpec specifications before editing. Use the locally pinned OpenSpec CLI and six development skills in `.agents/skills/`. Keep tasks active until behavior is verified; planning completion is not implementation completion.

Write project content in English. Follow the [Ruby style guide](https://github.com/rubocop/ruby-style-guide) and [Rails style guide](https://rails.rubystyle.guide), with the repository `.rubocop.yml` authoritative for local style. Preserve Ruby >= 3.3 syntax, railties >= 7.1 compatibility and MIT notices.

Use Ruby 3.4.10 and Node 20.19.0 from `.tool-versions`. Select the managed Ruby explicitly as shown in README. Run:

```sh
bundle exec rake test
bundle exec rake test:package
bundle exec rubocop
ruby script/validate_skills
npm run spec:validate
BUNDLE_GEMFILE=gemfiles/ai_rails_8_1.gemfile bundle exec rake test:ai
```

Run the Rails 7.1 core and AI bundles for compatibility changes. Run `bundle exec rake test:workflows` with pinned Specify 1.0.0 and OpenSpec 1.12.0 available for workflow changes. `script/prepare_acceptance` installs consumer dependencies before offline packaged acceptance. Do not introduce external provider requests in normal tests.

Structural checks must not boot Rails or execute application code. Full Packwerk checks run explicitly in an isolated test application. Preserve accepted upstream debt. Never regenerate baselines to pass a check. Keep Foundry out of generated production execution; use packs-rails, Rails transactions, Dry::Operation and optional RubyLLM directly.

Eight product skills ship from `skills/`; upstream OpenSpec development skills are separate. Keep workflow-specific instructions in small references. Requirements describe behavior, ADRs explain rationale, and ROADMAP records future work. Preserve historical ADRs and archives when current specifications change.

Implement authorized work in bounded verified changes and use focused Conventional Commits. Show executed commands and concise stdout summaries, including failures. Publishing remains separate. Do not claim the twelve-app corpus exists before its standalone applications and CI are executable.

Commit examples: `feat: add context diagnostics`, `fix: preserve workflow configuration`, and `refactor!: remove legacy execution runtimes`.

Executable examples have independent bundles and workflow checks. Run the adoption example's `bin/verify`, RuboCop and local `npm run spec:validate` from its directory. Run `bundle exec ruby script/validate_examples.rb` at the repository root when changing the catalog or example configuration.

The four 0.3 flagships are listed in examples/catalog.yml. For data apps, start their disposable
Compose services and run `bin/setup`, `bin/verify` and `bundle exec rubocop` from the owning app.
Use PostgreSQL client 17 for the RAG SQL schema. Spec Kit prerequisite scripts check artifacts;
behavioral reconciliation is recorded separately. See docs/data-recipes.md for acceptance ownership.
If multiple Bundler versions are installed, use `BUNDLE_VERSION=2.6.9 bundle _2.6.9_ exec rake test:package`
so generated test consumers stay on the documented tooling lane.

The complete 0.4 corpus adds eight independent applications. See docs/integration-recipes.md for their acceptance commands and dependency constraints. Next.js owns frontend/package-lock.json and builds separately; Kafka and Sidekiq acceptance starts real worker processes.

For 0.5 optional integrations, run each recipes/ bundle independently and follow its README. Normal evaluation tests block provider traffic. Run script/verify_adoption_evidence.rb with pks 0.2.40 for real disposable parity/debt acceptance. Runtime benchmarks and agent/onboarding experiments require distinct evidence.

For 1.x interface changes, read docs/stable-contracts.md and run npm run contracts:validate.
That contributor-only lane cross-checks shipped JSON Schemas against Ruby validation, the twelve
applications and emitted CLI evidence. Keep schema changes, upgrade guidance and SemVer coherent;
internal helpers are not public extension APIs. A passing local release is not authorization to publish.

## Distribution and privacy

`packaging/files.txt` is the reviewed archive inventory. Add required resources explicitly;
research drafts, tests, example applications and local plans must not ship. Links titled
"Repository-only reference; not installed" are optional source-checkout references.
Run `ruby script/privacy_check.rb` before sharing evidence. It scans non-ignored Git
files for workstation paths and common credential signatures, reporting only relative
locations/categories. It does not inspect Git history, ignored caches, external stores
or detect every possible secret. It never replaces manual review or secret rotation.

The optional installed delivery-extraction replay uses its own locked bundle:
`BUNDLE_GEMFILE=test_delivery/bundle/Gemfile bundle exec rake test:delivery`.
Prepare local Chrome/ChromeDriver first. It replays the shipped guide in disposable SQLite
applications with both package roots, real HTTP/browser checks, deliberate faults and
reviewed skill upgrades. It does not run or repair Campfire's test harness.
