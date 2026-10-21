# Stable contracts and upgrades

Foundry 1.0 stabilizes development-time interfaces. Generated applications execute Rails and upstream libraries directly. Updating the gem changes available tooling and templates; it does not upgrade application business code, database contents, specification history or installed skills automatically.

## Public surface

| Surface | Stable contract in 1.x |
| --- | --- |
| Configuration | Application and context schema 1, independent dimensions, defaults and validation described below |
| CLI | Documented commands/options, zero/one exit status, versioned JSON reports and read/write boundaries |
| Generators | Names, options, placement, native result boundaries, previews and ownership preservation |
| Skills | Eight names, three targets, complete-catalog receipt behavior and discoverable references |
| Ruby | `RailsAIFoundry::VERSION`; internal Ruby classes and require paths are implementation details |
| Execution | No Foundry production loader, composition, transactions, events, projections or AI runtime |

Run `bundle exec foundry --version` or `bundle exec foundry contracts` anywhere in the installed bundle. The JSON inventory lists absolute installed schema paths, generator names and skill names/targets. It does not initialize Rails or specification tooling. Paths depend on the installation and are not portable identifiers. The schemas' `.invalid` URL identifiers are names, not hosted endpoints: load the local files and their relative references together.

## Configuration schema 1

[Application schema](../schemas/application-v1.json) describes `config/foundry.yml`; [context schema](../schemas/context-v1.json) describes each pack's `foundry.yml`. An omitted schema means integer 1 for native 0.2–0.5 consumers. An explicit unsupported schema fails. Unknown root/context/workflow fields fail rather than being ignored.

```yaml
schema: 1
workload: balanced
workflow:
  specs: spec_kit
defaults:
  profile: rails_native
  patterns:
    events: none
    cqrs: none
  capabilities: {}
```

Workloads are balanced/read_heavy/job_heavy/ingestion/realtime. Profiles are rails_native/modular/domain. Events are none/integration/event_sourced; CQRS is none/queries/read_model. No selection changes another dimension. Contexts require a Ruby namespace; kind defaults to domain and can be platform. Capability entries require a nonempty string adapter and allow application-owned adapter settings. An accepted adapter name is not proof of installation or support.

`workflow.specs` is spec_kit/openspec/none. Existing configuration using spec-kit remains readable; setup normalizes an explicit selection to spec_kit. Defaults apply only to new contexts. New apps default to Spec Kit, adoption recommends OpenSpec, established choices are preserved and ambiguous installations require an explicit choice. Each workflow keeps its own validation/reconciliation semantics.

`checks` and `adoption` are reserved empty mappings in schema 1. There are no implemented policy switches under them. Remove previously ignored nonempty settings and use explicit `check --sources`, `check --boundaries`, `audit` and `parity` commands. Packwerk remains authoritative and new debt is never silently accepted. Do not put application metadata in these mappings.

Package topology belongs to upstream package.yml and packs.yml. Root config/ai.yml is application-owned model alias data; it has no Foundry-wide model/provider schema. Workflow documents refer to these files instead of duplicating the package graph.

JSON Schemas check data shape. Boot-free Ruby checks additionally reject duplicate YAML keys, aliases, unsafe paths and competing ownership. YAML must use string keys and an integer schema value. Editor validation cannot prove Rails loading, dynamic Ruby behavior, provider compatibility or business correctness.

## Commands and evidence

| Command | Behavior / principal options |
| --- | --- |
| `new NAME` | Delegates creation to Rails, then setup; `--root`, `--specs`, `--agent`, `--database`, `--skip-git`, `--skip-dev-gems`, `--pretend` |
| `setup` | Explicit workflow initialization/selection; `--root`, `--specs`, `--agent`, `--greenfield`, `--pretend` |
| `doctor` | Read-only workflow/prerequisite inspection; `--root`, `--specs`, `--agent`, `--greenfield` |
| `adopt` | Boot-free inventory/recommendations; `--root`, `--specs`, `--format=text\|json`, `--sources` |
| `check` | Boot-free structural checks; same options as adopt, plus opt-in `--prompts` and explicit `--boundaries` which may boot test Rails |
| `plan refactor` | Read-only source assessment; `--root`, required `--context`, optional `--profile`, `--format=text\|json` |
| `audit` | JSON debt comparison from a disposable copy; `--root`; does not accept `--verify` |
| `parity` | JSON comparison and identity-bound evidence; `--root`, `--pks`, `--verify` |
| `contracts`, `--version` | Read-only installed inventory / version; no application required |

Schema 1 reports carry `report_schema: 1`, `foundry_version` and `report_kind`. Kinds are check/adopt/refactor/audit/parity/contracts. [Assessment](../schemas/assessment-v1.json), [refactor](../schemas/refactor-v1.json), [debt](../schemas/debt-v1.json) and [inventory](../schemas/contracts-v1.json) schemas define required fields. Readers must ignore additional fields and must reject unsupported report schema versions. Object key order, whitespace, human prose, absolute installation paths and subprocess output are not stable parsing interfaces.

Check/adopt reports use `success`. Refactor uses `complete`: a complete assessment can still contain Foundry dependencies and proposed work; it does not mean a migration is implemented. Audit/parity use success with detailed new/resolved/retained identities and source preservation. Parity additionally requires matching analysis inputs, the installed Foundry producer version and tool identities. Unversioned parity reports must be regenerated; they are not converted or accepted as 1.0 evidence.

Exit zero means the selected command completed successfully. Exit one means invalid input, failed execution, failed selected checks, new debt, parity mismatch or incomplete source parsing. Refactor findings alone do not cause failure unless parsing is incomplete. Errors are human-readable stderr, with no guaranteed JSON error envelope; callers must check status before parsing stdout. Setup/new can print progress before a failure. Unknown commands/options fail.

Boundary, audit and parity command output is decoded as UTF-8 independently of the caller's locale.
Valid Unicode is preserved; invalid byte sequences become the Unicode replacement character (U+FFFD).
This normalization does not change upstream exit statuses, command arguments or accepted debt.

[Source diagnostics](../schemas/diagnostic-v1.json) retain rule, file, one-based line, certainty and message. `source.syntax` means parsing failed; `source.foundry_dependency` means an explicit Foundry constant path in application code was detected. `detected` is syntax evidence, not proven constant resolution or runtime reachability. Findings now carry independent severity (error/warning) and certainty (detected/inferred); only errors fail a source check. See [source rules](source-diagnostics.md) and the explicit [prompt check](prompt-contracts.md). Rule meanings will not be repurposed within 1.x; additive rules may reveal previously missed violations. Message text is remediation guidance, not a code. Packwerk output remains upstream-owned.

Explicit source checks cover shell app/ and all upstream-discovered package app/ Ruby
files, including packages without foundry.yml. Architectural intent remains optional:
domain rules use only the owning package's configured profile. Existing rule meanings
and report fields are unchanged; expanded coverage can reveal previously omitted
violations. Source counts do not prove behavioral coverage. See [source rules](source-diagnostics.md).

## Refactor assessment scope

Refactor assessment includes only the selected configured upstream package's non-hidden
Ruby, including tests and lib. Independently discovered descendants are excluded even
without foundry.yml. Configured root packages are supported; application-root vendor,
node_modules, tmp, log, storage and coverage trees are excluded. Discovery and unsafe or
incomplete inspection fail without fallback or writes. Findings still describe installed
intent; a proposed profile does not alter the assessment's rules. Report schema and exit
semantics remain unchanged. See [adoption](adoption.md) for separate migration evidence.

## Generator and skill ownership

The 16 generator names are context, command, operation, query, model, entity, value_object, policy, port, repository, controller, job, mailer, channel, agent and skills. Invoke them with `bin/rails generate foundry:NAME`. Components take a snake_case name and `--context=NAME`; model fields/migrations are generated separately using Rails. Context takes a name and optional profile/kind/namespace/path/events/cqrs. Agent requires explicit ruby_llm capability selection. Skills accepts `--target=agents|claude|cursor`. All support Rails `--pretend`; automatic destruction is refused.

For Billing's `charge` command:

| Profile | Pack-relative location | Constant |
| --- | --- | --- |
| rails_native | app/operations/billing/charge.rb | Billing::Charge |
| modular | app/commands/billing/charge.rb | Billing::Charge |
| domain | app/application/billing/commands/charge.rb | Billing::Commands::Charge |

Other non-domain components use app/<plural kind>/<namespace>; models always use app/models. Domain entities/value objects/policies use app/domain/<namespace>/<plural kind>; repositories use app/infrastructure; other domain components use app/application with their category. Delivery always uses pack-owned controllers/jobs/mailers/channels and application shell base classes. AI owns pack agents/tools/schemas/prompts/evaluation fixtures and application-root aliases. Migrations stay at root. See [native contexts](native-contexts.md) and [AI](native-ai.md) for exact behavior.

Complete same-receipt generation preserves edited output; it is not template synchronization. A changed selection, partial scaffold, unsafe path or conflicting constant receipt fails before writing. Namespace/receipt checks are structural evidence, not complete Ruby resolution. New-file failures roll back files created by that invocation; an interrupted upstream workflow setup can leave a journal for explicit inspection. A full application creation interrupted after Rails runs remains a partial destination for review.

Keep `.foundry` receipts in version control. Receipt paths and their ownership role remain supported in 1.x; their bytes are opaque to callers and are not a template-merging API. Do not rewrite hashes to bypass a conflict.

Component and agent generation share receipt-based constant ownership checks. An agent claims its
agent, tool and schema constants; conflicts with any component are refused in either generation order,
including previews, before shared aliases or other files are created. Existing receipts remain readable
without conversion. These checks do not discover every hand-written or dynamically defined constant.

Namespaces such as `API`, `APIClient`, `GraphQL` and `Platform::API` receive a dedicated application-owned
initializer using Rails autoloader inflector overrides. Its name is
`config/initializers/foundry_inflections_<SHA256-of-relative-pack-path>.rb`; the independent receipt is
`<pack>/.foundry/inflections.yml`. Generated code uses only Rails and does not change global ActiveSupport
inflections or table naming. New context/component/agent generation preflights both scaffolds and writes
new files in one rollback boundary. Edited complete initializers are preserved; partial or conflicting
ownership fails before writing. Normal namespaces need no extra files.

Overrides apply to basenames across the application's Rails autoloaders. Generation rejects incompatible
configured namespace segments such as `API` and `Api`, including nested segments in different packs.
Custom application inflectors and code outside configured namespace declarations still require review:
an override for `api` also affects a Ruby file named `api.rb`. Run `bin/rails zeitwerk:check` and owning tests
in a fresh process after generation. Structural inspection does not boot Rails or execute initializers,
and preserving a customized initializer is not proof of its behavior.

The eight skill names are foundry-add-package, foundry-add-feature, foundry-architecture-review, foundry-verify, foundry-profile-promotion, foundry-event-workflow, foundry-adopt-existing-app and foundry-plan. Targets map to .agents/skills, .claude/skills and .cursor/skills. References ship with each installed skill. Generated upstream OpenSpec/Spec Kit instructions are separate and remain managed by their pinned upstream tooling.

The verification skill also ships an optional Rails/Minitest or explicit RSpec helper under its own
`scripts/` directory, with usage under `references/verification.md`. These development
resources use the same receipt/collision protections as instructions; prior catalogs
require reviewed reconciliation. Current eight-skill installations can use explicit upgrades;
historical unsupported receipts retain the manual procedure below. They add no Foundry CLI command, public configuration
key or application runtime. A required application CI invocation enforces the helper's
exit status; installation does not constrain an agent's submission behavior.

## Explicit current-catalog skill upgrades

`foundry:skills --upgrade` assesses complete current eight-skill catalogs without writes.
Add `--apply=DIGEST`, `--resolve=DECISIONS_FILE` or `--rollback=SESSION_ID` for explicit,
mutually exclusive actions. All three targets and non-mutating pretend are supported.
See [reviewed upgrades](skill-upgrades.md) for classification, review, privacy and recovery.
Pending review returns nonzero; only final acceptance publishes the incoming template
receipt. Original receipts and actual accepted customizations remain separate provenance.
These additive options do not change ordinary generator repeat/collision behavior.

## Historical upgrade from 0.5

1. Work in a reviewed branch. Record the current gem/bundle, configuration, skill receipts, workflow selection and accepted debt. Run current application tests before changing dependencies.
2. Install the reviewed local 1.0.0 gem (publication is separate), update only the Foundry bundle selection and inspect the lock diff. Do not update every optional integration incidentally.
3. Run `foundry --version`, `foundry contracts`, and `foundry check --sources --format=json`. Keep schema-omitted native files or explicitly set schema 1. Correct unknown/ignored keys without moving topology, changing profiles or enabling capabilities.
4. Existing generated Ruby remains application-owned. Compare desired fresh templates in a disposable consumer; manually apply justified changes with behavioral tests. Regenerating a completed component does not refresh its implementation.
5. For skills, generate the new catalog into an empty disposable destination with the chosen target, compare against the installed catalog, and manually merge local guidance. A previous-version receipt intentionally refuses automatic replacement, including pretend. Preserve that receipt as the provenance of the installed custom catalog. To accept a wholly fresh catalog, explicitly relocate the old eight skill directories and target receipt to a review backup outside the target, then install; leave unrelated skills/instructions in place. Never claim a manually merged catalog matches fresh hashes.
6. Preserve workflow history and selected tooling. Re-run doctor and workflow-specific checks. An interrupted setup requires inspecting the journal and listed files, repairing/relocating partial artifacts with upstream tooling, and only then removing the reviewed journal. None disables integration without deleting specifications.
7. Run isolated `foundry check --boundaries`, owning behavioral tests and relevant offline AI/evaluations. Audit resolved debt separately; review each proposed baseline removal. Regenerate parity evidence and save it outside the application to avoid changing its input fingerprint.
8. Review the complete diff. Commit tooling/configuration changes separately from intentional application changes. To roll back tooling, restore the prior reviewed commit and locks and reinstall that version. Business changes require their own tested rollback; Foundry never converts data.

### Repair an existing acronym namespace

Completed generation remains a preserving repeat, including older contexts/components/agents without
inflection receipts. It does not silently add repair files. Creating a new component or agent can install
the missing initializer and its separate receipt if both are absent; existing original receipts stay unchanged.

To repair loading without adding a component, generate the same context path and namespace with updated
tooling in a disposable consumer. Review its initializer and copy the initializer together with its
independent inflection receipt into the application, leaving original receipts and customized code intact.
Do not overwrite occupied destinations: compare and reconcile existing application inflections explicitly.
If only one of the initializer/receipt pair exists, restore the missing owned file from version control or
move the reviewed pair to a backup before applying the repair. Verify namespace mappings against other
contexts and run fresh-process eager loading and owning tests. Roll back the repair through its reviewed diff.

The regression receipt at test/fixtures/contracts/skills-0.5.0.json was derived from commit c4cd7ad; it tests refusal and byte preservation.

## Versioning and support policy

Patch releases correct defects without intentionally changing documented accepted configuration, command options, result meanings or generated ownership contracts. Minor releases can add optional capabilities, diagnostic rules, schema-compatible fields and explicit options. Bug fixes can expose invalid behavior; release notes must identify the affected diagnostic and remediation. Removing/renaming a public field, changing its meaning, changing a default architecture/workflow, raising a supported Ruby/Rails floor or changing generator placement requires a major release.

Deprecations retain behavior through the current major series, provide a replacement in release notes and documentation, and precede removal by at least one minor release. A security fix that cannot preserve behavior must identify the exception and its migration explicitly. Internal Ruby helpers, exact scaffold wording, formatting, test counts, upstream output and experimental recipes are outside the public compatibility guarantee. New templates never silently rewrite installed code.

| Tier | Contract |
| --- | --- |
| Core | Rails/packs/native operations, CLI, schemas, generators, eight skills; Ruby >= 3.3 and railties >= 7.1 floors |
| Optional AI | RubyLLM remains optional; separately tested pinned integration and offline contracts, no model-quality promise |
| Mainstream recipes | PostgreSQL/outbox/pgvector/OpenSearch/RabbitMQ/Sidekiq/Kafka examples; their locked combinations and documented limits |
| Advanced recipes | ROM, dry-system, Trailblazer, Qdrant, NATS, async GraphQL/Falcon and separate Next.js; independent bundles/acceptance |
| Experimental | Pinecone/Weaviate; explicitly bounded protocol/service evidence and no stable provider API promise |

A tier is a maintenance/verification scope, not an SLA. Gem constraints permit resolution; only lanes with recorded passing evidence are verified. Compatibility floors are not a claim that every intermediate/future version combination has been run. Keep Rails JSON < 3, Sidekiq connection_pool 2.5.5 and Falcon traces constraints in their owning recipes until replacement evidence passes. Upstream specification tooling upgrades need explicit pin changes and initialization/collision/reconciliation acceptance. Read [compatibility evidence](compatibility.md) for exact versions and limits.

## Release acceptance

Before a stable release, run both core floors, built-gem consumers, optional AI lanes, real pinned workflow setup, `npm run contracts:validate`, RuboCop, skills and catalog validation, and strict OpenSpec validation. New/changed integrations run their independent locked acceptance; unchanged recipes retain dated evidence. Contract validation uses contributor-only Ajv with local schemas and actual Ruby-emitted samples. Normal provider tests stay offline. Schema validation, agent reports and planning completion are not behavioral proof.

Synchronize verified current specifications and versions only after acceptance; preserve historical records. Record failed attempts and corrected causes, exact successful commands/counts and unexecuted lanes. Local verification is distinct from hosted CI, provider-quality measurements and production load. Build and inspect the gem from a clean reviewed commit before a separately authorized tag/upload. Never infer publication authorization from completion of this milestone.

## Audit capture policy

Adoption and audit debt inventory share eligible input paths. Audit/parity derive accepted
debt and separate analyzer working copies from one verified capture. Private agent metadata,
including `.claude`, and application-root `.foundry/skill-upgrades` are excluded; ordinary
Foundry receipts remain inputs. The opaque fingerprint binds the input-policy revision,
so earlier parity evidence requires regeneration without a report schema change.
See [adoption](adoption.md#verified-audit-inputs) for capture and execution-isolation limits.

## Unpublished candidate cleanup

Before publication, the unused compatibility surface was removed: assessments describe only current configuration, and source checking reports general development-tool dependencies. Schema 1 describes this final candidate; no previous candidate report conversion or retired configuration migration is provided. Runtime and report compatibility policy applies to published releases.

The unpublished candidate now defaults new AI scaffolds to pack-local prompts. Existing complete receipts are preserved, including application-root prompt placement; no automatic relocation occurs. See the explicit review procedure in [native AI](native-ai.md). Prompt-contract checking is an additive opt-in command/report surface. Published-release placement changes still follow the major-version policy above.

## Native verification frameworks

The installed helper accepts `--framework=minitest|rspec`, defaulting to Minitest.
Its existing phase, path, timeout and reviewed-baseline-skip options remain available.
RSpec request/system metadata, completed native outcomes and suite errors provide
execution evidence, not expectation counts. Missing dependencies fail without installation.
Mixed frameworks require separate invocations. See the installed verification reference
for filtering, shared examples and evidence limits. No application configuration key or
production dependency selects a framework.

## Opt-in package baseline

The installed helper accepts `--include-pack-tests` for Minitest and RSpec. It discovers
packages through locked `packs-specification` and combines conventional root/package
non-system tests with explicit additive baselines, without duplicate canonical files.
System tests remain explicit through `--realtime --browser`. The printed inventory
identifies root/package/explicit paths, deferred browser files and packages without tests.
Unsupported custom discovery, unsafe paths and missing prerequisites fail without fallback.
Each planned baseline file must have internal loaded-file evidence; execution ownership
and existing framework outcome requirements remain independent. Existing invocations
without the flag retain default discovery and baseline replacement semantics.

No public report schema or saved manifest is added. Applications own repeatable commands;
see [package-aware verification](package-aware-verification.md). Helper changes use the
existing reviewed skill-upgrade contract and do not enforce application CI.

Prompt validation covers application and every upstream package app/prompts root, including packages without foundry.yml. Actual package ownership governs contract placement; only explicit owning-context configuration restricts agent namespaces. Existing prompt schema 1 and report fields remain unchanged. Expanded coverage can expose previously skipped violations; see [prompt contracts](prompt-contracts.md) for recognition rules, failure channels and limits.
