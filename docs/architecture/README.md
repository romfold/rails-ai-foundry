# Architecture

Package topology and optional architecture intent have separate responsibilities in
source verification. All upstream-discovered package app/ Ruby files receive general
source checks, including packages without foundry.yml. Only the owning package's explicit
intent enables domain-profile rules. This avoids both skipped code and accidental profile
inheritance during incremental adoption. Source coverage is static evidence; Packwerk and
behavioral tests remain independent. See [source diagnostics](../source-diagnostics.md).

Foundry guides implementation through skills, optional generators and checks at development time. Applications use Rails and upstream libraries directly. Package discovery belongs to packs-specification, package operations to packs, Rails loading to packs-rails and dependency/privacy/cycle checks to Packwerk with its extensions. Read [pack operations](../packs.md) and the executable [first feature](../first-feature.md).

Profile, events, CQRS, capabilities, workload and specification workflow are independent dimensions. See [profiles](profiles.md) and [native contexts](../native-contexts.md). Capability intent is not proof of an installed integration.

package.yml owns topology, dependencies, public paths and stewardship. Adjacent foundry.yml owns context profile, namespace, patterns and capabilities. Root config/foundry.yml owns application defaults and workflow. Root config/ai.yml owns model aliases. Workflow requirements describe intended behavior; plans propose implementation and reference configuration rather than duplicating it. Code and tests provide evidence.

Keep feature controllers, views, jobs, channels, mailers, agents, tools and schemas in the owning pack. Rails base classes, shared UI and cross-context delivery stay in the shell. Migrations stay at root. Same-pack delivery can use internal objects; cross-pack calls require declared dependencies and public APIs.

Use one native Dry::Operation result boundary. Transactional commands explicitly roll back failure, including nested savepoints. Introduce ports for real boundaries; do not mandate repository wrappers for ordinary Active Record. Efficient queries are valid in every profile. Use constructor injection; optional ROM, DI and workflow recipes are independently verified in [advanced composition](../advanced-composition.md).

Foundry has no application execution runtime. [Historical decisions](../decisions/README.md) remain historical context. New AI prompts live inside the owning pack with explicit source-relative lookup; see [prompt contracts](../prompt-contracts.md). [Source diagnostics](../source-diagnostics.md) distinguish concrete errors from advisory architectural inferences.

The [0.3 data recipes](../data-recipes.md) demonstrate these contracts in four independently
bundled applications. Outbox delivery, projections, embeddings and voice control remain
application-owned. Each recipe records its bounded-demo tradeoffs and actual integration tests.

The [complete integration corpus](../integration-recipes.md) extends these contracts with native RES, external vectors, Kafka/NATS, async GraphQL/Falcon and a separate frontend. The app bundles own compatibility constraints.

The [1.0 stable contract](../stable-contracts.md) freezes configuration/report schemas and the public
generator and skill surfaces. Internal Ruby helpers remain private implementation details. Upgrades
preserve application-owned execution, workflow history and accepted debt.

Prompt verification follows the same inventory/intent separation as Ruby source checks. An upstream package can own AI contracts without declaring a Foundry profile or capability. Nested packages cannot borrow a parent prompt owner or namespace. Static declaration checks and application-owned behavioral/evaluation tests remain independent.
