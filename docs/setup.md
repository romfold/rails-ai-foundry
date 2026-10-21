# Setup

Use `foundry new NAME --specs=spec-kit` to delegate Rails creation and setup. Existing apps use `foundry setup --specs=openspec`; explicit spec-kit and none are supported. CLI spec-kit normalizes to config workflow.specs: spec_kit. Explicit selection wins; otherwise preserve configured or unambiguously detected local tooling. Both tools without selection is an error. None and switching preserve all existing specifications. Setup preflights pinned Specify 1.0.0/OpenSpec 1.12.0 and file collisions. Missing prerequisites produce instructions, not a successful setup claim. Inspect interrupted upstream initialization and creation journals before retrying. Detection is scoped to the consuming app; examples cannot inherit monorepo tooling.

See [native contexts](native-contexts.md), [native AI](native-ai.md) and [the implementation program](implementation-program.md) for detailed contracts and delivery status.

## After setup

Install the existing catalog with `bin/rails generate foundry:skills`. Choose `foundry-plan`
for unclear ownership, `foundry-add-feature` for implementation and `foundry-verify`
for behavioral evidence. Inspect the selected workflow and installed context intent before
changing code. Follow [the first feature](first-feature.md); direct upstream packs commands
and ordinary Rails code are sufficient. Foundry component generators remain optional.

For human-reviewed AI features, continue with [the installed AI journey](first-ai-feature.md).
Its offline PostgreSQL exercise is optional and preserves ordinary CRUD as the simpler path.

## Updating installed guidance

Use the explicit [skill upgrade workflow](skill-upgrades.md) to assess and accept current
catalog changes. Ordinary generation still preserves customized guidance. Pending review
is not completion, and updating skills does not change application behavior or CI policy.

For a repeatable application-owned command including pack tests, follow
[package-aware everyday verification](package-aware-verification.md). Preserve existing
commands and adopt helper changes with [reviewed skill upgrades](skill-upgrades.md).

For an existing Rails screen, the [delivery extraction guide](delivery-pack-extraction.md)
provides staged, copy-and-adapt instructions and explicit native asset wiring. Characterize
behavior before moving files; retain locked dependencies and application authentication.
