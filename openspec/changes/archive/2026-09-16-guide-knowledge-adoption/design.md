## Context

See proposal.md. Assessment already inventories upstream packages, manifests, workflow and
debt. Its recommendation strings are generic. Refactor already parses selected-context
Ruby including tests, but only invokes FoundryReferences; SourceCheck additionally invokes
ArchitectureSourceRules. The complete knowledge composition is a separate advanced recipe.

## Goals / Non-Goals

Keep the existing command/report envelope and schema. Add contextual prose and shared rule
coverage without executing application code. The walkthrough is contributor-owned application
code, not a general automatic migration facility. No packs wrapper or ninth skill.

## Decisions

- Build recommendations from the existing validated context/package inventory. Separate
  unconfigured packages, configured contexts and workflow initialization; preserve custom paths.
- Reuse ArchitectureSourceRules and source-declared model discovery for the selected context.
  Retain syntax failure semantics and advisory migration completion. Do not parse other contexts
  merely to discover models: document the limited symbol inventory.
- Keep a frozen ordinary Rails starting application with characterization tests and explicit
  replay steps in an independently bundled adoption recipe. Materialize checkpoints in disposable
  directories. Use existing tables and Active Record for extraction, then separately introduce
  the application-specific ROM persistence implementation, then integrated features.
- Use the installed gem for assessment/checks and upstream packs/packs-rails for package layout.
  Preserve initialized OpenSpec history and exercise an alternate custom-root replay. Compare
  accepted debt identities and bytes; resolve debt only at the reviewed caller repair checkpoint.
- Extend bundled references of the four existing relevant skills, preserving installed receipt
  ownership and all eight identities. Behavioral evidence remains separate from workflow validation.

## Risks / Trade-offs

- Fixture drift → shared characterization requirements at each checkpoint plus final composition acceptance.
- Static inference → explicit limitations, certainty and selected-context scope; Packwerk is authoritative.
- Data transition errors → seeded existing records and reversible code checkpoints; no automatic production data rollback claim.

## Migration Plan

No consuming application is modified by the CLI changes. The replay uses disposable named
applications/databases, records each checkpoint, and retains evidence on failure. Existing
skill installations keep their ownership rules; users review changed guidance explicitly.
