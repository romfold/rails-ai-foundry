# Roadmap

Foundry is a development-time conventions kit. The [completed implementation program](docs/implementation-program.md) records the complete authorized scope and all twelve descriptive example names.

| Release | Scope | Status |
| --- | --- | --- |
| 0.2 | Remove legacy runtimes; native contexts, generators, operations, AI, optional workflows and upstream checks | Implemented and locally verified; publishing separate |
| 0.3 | Outbox, pgvector, OpenSearch, RabbitMQ and four flagship applications | Implemented and locally verified; all four flagships and data recipes delivered |
| 0.4 | Complete twelve standalone apps; RES, Qdrant, Kafka, NATS, GraphQL, Falcon and Next.js | Complete; twelve apps locally verified (see compatibility.md) |
| 0.5 | Optional ROM/DI/workflow recipes, experimental vectors, full adoption/parity tooling, evaluations and benchmarks | Complete; recipes, audit/parity and evidence tooling locally verified |
| 1.0 | Stable schemas, diagnostics, generators, skills and upgrade policy | Complete; stable contracts and upgrade policy locally verified; publishing separate |

The 0.2 acceptance boundary is the core kit and generated consumers. The removed 0.1 examples do not gate it on the later twelve-app corpus. Publishing is separate from local implementation and verification.

## Skill-led program — implemented locally

The [skill-led program](docs/next-program.md) delivers packs usage and a replayed first feature, pack-local AI contracts, focused source diagnostics, Neighbor RAG evidence and independent experimental FlowNodes/Langchainrb recipes. All twelve applications were replayed locally. Existing small generators remain optional; new capability generators and a packs CLI wrapper are out of scope.

## Remaining scopes

Bounded, resumable operations for the integrated knowledge recipe are covered by the
[runbook and evidence](docs/knowledge-operations.md). This extends the existing application
and skills without changing the twelve-example catalog or stable Foundry contracts.

- Execute hosted compatibility CI once a repository destination is configured, then make a separate publication decision.
- Broaden evidence only through a separately authorized study with harder held-out tasks and more repetitions. The integrated composition, guided adoption, six-task corpus and eighteen-trial Cursor pilot are locally complete; see [program evidence](docs/next-program.md).
- Run separately authorized, budgeted live evaluations and matched agent/onboarding studies; current offline and runtime evidence does not establish those outcomes.

## Human-reviewed AI work — locally implemented

The existing authorized-tools example now demonstrates durable proposal generation, human approval
and atomic local ticket closure. See the [runbook](docs/reviewed-ticket-resolution.md),
[ADR 0012](docs/decisions/0012-application-owned-reviewed-ai-work.md) and
[behavioral evidence](docs/reviewed-ticket-resolution-evidence.md). The next scope is not implicitly
authorization for external actions, live providers or further agent studies. The unfinished study
acceptance and hosted release CI gates remain unchanged.

## Skill-led AI delivery — implemented and locally verified

The program ships an explicit resource inventory, a self-contained reviewed-AI journey
replayed from the installed gem, and a separate study validated by fourteen offline controls. New agent execution requires separate approval.
No new application, runtime, provider or public configuration surface is planned.

The explicit gem inventory and installed reviewed-AI journey passed local acceptance; see
[delivery evidence](docs/evidence/2026-09-23/skill-led-delivery.md "Repository-only reference; not installed").
The separate [reviewed-AI study protocol](benchmarks/reviewed-ai/README.md "Repository-only reference; not installed")
prepares six proposed trials; execution requires separate authorization.

## Reviewed skill upgrades — implemented and locally verified

The existing skill generator now supports read-only assessment, explicit safe updates,
recorded customization decisions and conditional recovery/rollback for current catalogs.
See the [installed upgrade guide](docs/skill-upgrades.md) and
[local evidence](docs/evidence/2026-09-24/reviewed-skill-upgrades.md "Repository-only reference; not installed").
Ordinary generation remains preserving. Agent studies, hosted CI and publication remain
separately gated; this change adds no application execution runtime.

## Broader verification and safe data adoption

Explicit RSpec evidence extends the existing installed verification helper. The existing
knowledge-adoption recipe adds an independent populated tenant-backfill scenario with
compatible writers, resumable checkpoints and bounded cutover. See
[implementation evidence](docs/evidence/2026-09-24/broader-verification.md "Repository-only reference; not installed")
and [ADR 0014](docs/decisions/0014-native-verification-and-data-adoption.md).
The existing `verify-1-0-release-candidate` record owns complete candidate verification;
its hosted-CI gate remains pending a repository destination. No additional agent study,
production migration framework, runtime or catalog application is introduced.

## Package-aware everyday verification

The opt-in helper combines root and upstream-discovered package tests, verifies loaded
files and leaves browser selection explicit. Applications own their repeatable command;
see the [guide](docs/package-aware-verification.md) and [ADR 0015](docs/decisions/0015-package-aware-verification.md).
The change is locally verified and archived as `2026-09-29-deliver-package-aware-feature-verification`;
see its [acceptance evidence](docs/evidence/2026-09-29/package-aware-verification.md "Repository-only reference; not installed").
Historical release evidence and the pending hosted-CI gate remain unchanged. No further agent study is implied.

## Campfire adoption — extracted, behavioral acceptance pending

The separate Campfire branch extracts Search delivery into a Rails-native pack while retaining
all existing dependency versions and persistence ownership. Loading, assets, package boundaries
and production independence are checked. Existing Rails/Minitest test-discovery failures remain
unchanged; the installed helper correctly rejects the incomplete run. This is not verified release
evidence. See the [continuation record](docs/evidence/2026-10-10/campfire-search-extraction.md "Repository-only reference; not installed").
The active `verify-campfire-search-adoption` change remains unarchived. The twelve-app catalog,
historical release gates, and studies are unchanged.

### Campfire Search browser review — 2026-10-14

The [separate browser comparison](docs/evidence/2026-10-14/campfire-browser-review/README.md "Repository-only reference; not installed")
found no extraction regression with frozen dependencies and synthetic data. Visibility
bypass was detected and healthy recovery confirmed. This completes the bounded browser
review, not the blocked installed-helper/coverage acceptance. The existing adoption change
remains open; Rails, Minitest and the test harness were not changed.

## Installed delivery-pack extraction guidance — locally verified

The installed [delivery guide](docs/delivery-pack-extraction.md) turns existing-screen
extraction into staged, observable checkpoints. It retains shell-owned models/data and
uses native packs/packs-rails, routes, importmap/Propshaft and application-owned verification.
[ADR 0016](docs/decisions/0016-installed-delivery-extraction.md) records the rationale.
The contributor replay covers both package roots and reviewed upgrades across three targets;
see [local evidence](docs/evidence/2026-10-14/delivery-pack-extraction.md "Repository-only reference; not installed").
This is an installed guide and acceptance fixture, not another catalog application.
Campfire's blocked native-test acceptance, the existing studies and hosted release gate
remain separate and open.

Archived as `2026-10-14-guide-existing-delivery-pack-extraction` after executable acceptance.

## Package-aware source verification — locally verified

Explicit source checking now covers shell app/ and every upstream-discovered package
app/ Ruby tree, including packages without foundry.yml. Package ownership determines
which explicit profile rules apply; nested unconfigured packages inherit no profile.
Checks remain boot-free and independent from Packwerk and behavioral acceptance.

Source implementation `19ec255` and an acceptance-driven exact-byte skill-upgrade fix
`b27b8e1` pass both locked Rails core lanes and installed acceptance. Existing dependencies,
eight skills and twelve applications are unchanged. See [local evidence](docs/evidence/2026-10-15/package-source-verification.md "Repository-only reference; not installed")
and [source-check behavior](docs/source-diagnostics.md). The change is archived as
`2026-10-15-cover-upstream-packages-in-source-checks` after verified reconciliation.
Campfire native tests, the unfinished guidance study and hosted release CI remain open.

## Package-aware prompt verification — locally verified

Explicit prompt checking now covers shell and all upstream package app/prompts roots,
including packages without foundry.yml. Actual package ownership constrains contracts
and references; only the owning package's explicit configuration restricts agent namespaces.
Invalid discovery and unsafe inspection fail without executing prompts or evaluations.

Implementation `acb3cd1` passes both locked Rails core and AI lanes, packaged acceptance,
and the installed AI journey across both roots and all three skill targets. Dependencies,
eight skills and twelve applications are unchanged. See [local evidence](docs/evidence/2026-10-15/package-prompt-verification.md "Repository-only reference; not installed")
and [prompt contracts](docs/prompt-contracts.md). Archived as
`2026-10-15-cover-upstream-packages-in-prompt-checks` after verified reconciliation.
Campfire's native-test limitations, unfinished study and hosted release gate remain open.

## Package-aware refactoring assessment — locally verified

Refactor plans now inspect only the selected configured package's owned Ruby, including
tests and lib. Independently discovered children are excluded before parsing/model evidence;
configured upstream root packages are supported with documented dependency/data exclusions.
Existing report semantics and installed-profile rules remain unchanged.

Implementation `4550ddb` passes both core lanes, installed-gem acceptance and reviewed
guidance upgrades across both package roots and all three targets. See
[local evidence](docs/evidence/2026-10-21/package-refactor-verification.md "Repository-only reference; not installed")
and [adoption scope](docs/adoption.md). Dependencies, eight skills and twelve applications
remain unchanged. The change is archived as
`2026-10-21-respect-package-ownership-in-refactor-plans` after verified reconciliation;
Campfire native tests, studies and hosted release CI remain separately open.

## Private adoption evidence and local release preparation

Audit capture excludes private agent guidance and skill-upgrade backups, aligns accepted
debt with analyzed inputs, and gives Packwerk/pks separate copies of one verified capture.
Parity fingerprints bind the input-policy revision; earlier evidence must be regenerated.
The installed review workflow preserves customizations and accepted debt. See
[adoption](docs/adoption.md#verified-audit-inputs) and
[October candidate evidence](docs/evidence/2026-10-21/release-candidate/README.md "Repository-only reference; not installed").

The release scope freezes a local 1.0.0 artifact with unchanged dependencies. Hosted CI is
explicitly skipped for this candidate, with its historical task retained as deferred.
RubyGems.org publication waits for the user's explicit readiness. The supplied repository is
[romfold/rails-ai-foundry](https://github.com/romfold/rails-ai-foundry).
No tagging, remote configuration or publication is authorized by preparation.
Campfire harness repair and further studies remain separate work.
