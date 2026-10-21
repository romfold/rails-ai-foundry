## Context

The approved implementation program replaces the 0.1 runtime. Native consumer acceptance is now available. The user explicitly authorized removing unused legacy runtimes and examples together in the 0.2 cutover; the later twelve-app corpus does not gate this removal. Keep repository development on OpenSpec 1.12.0.

## Goals / Non-Goals

**Goals:** application-local configuration, independent architecture axes, upstream-only package topology and specification initialization, conservative previews and repeat behavior.

**Non-Goals:** no live provider calls during normal tests, no conversion of business data or specification history, no new application execution runtime. This change does not claim completion of the twelve-example program.

## Decisions

- Context intent is adjacent foundry.yml with schema 1; package.yml exclusively owns topology. Validate intent without Rails or constant evaluation. Default rails_native, events none and CQRS none; reject old profile names with corrective diagnostics.
- Root application configuration owns defaults, workload, workflow and checker/adoption policies, not package topology. Workflow selection is explicit option, then configured selection, then unambiguous local detection, then creation/adoption default. Both detected without a selection is an error. None preserves all existing files.
- Use normal Ruby path-to-constant conventions; capability/profile choices determine generation locations rather than runtime loading rules.
- Run upstream CLIs with argument arrays and an explicit working directory. Pin tested released versions; preflight versions and files before mutation. Surface nonzero exits without false completion. Never call upstream force mode over an existing consumer without collision preflight.
- Workflow initialization is setup-only branching, not a generic provider API. Spec Kit agent guidance and OpenSpec validation remain distinct. Read-only detection never walks into parent applications or executes configuration.
- Use transactional file publication for Foundry-owned configuration and preserve unrelated keys. Existing upstream workflows are reused, not regenerated on each setup.
- Remove legacy CLI execution, generators, wrappers, loaders, composition and associated fixtures/dependencies in the breaking cutover. Keep actionable replacement diagnostics without compatibility execution.
- Route every Foundry Rails Rake check to native assessments. Default checks are boot-free; explicit boundary verification delegates to Packwerk. Rails loading belongs to packs-rails.
- Retire both unused examples now. Keep all twelve replacement apps visibly pending in the later delivery program. Native generated consumers verify the core independently.


## Risks / Trade-offs

- Upstream installers can partially write before failure: keep the selected workflow uncommitted until success and report upstream output and remaining artifacts explicitly.
- YAML and filesystem input can be malformed or unsafe: reject symlinks, duplicate keys, unsafe YAML types and invalid field shapes before writes.
- A selected workflow can be incompletely installed: doctor reports incomplete state; selection alone is not proof of initialization.
- Architecture and workflow configuration can drift from guidance: distribute small workflow references that direct agents to read live context files.

## Migration Plan

Implement and verify the new intent/workflow units, add CLI entrypoints and installed-gem tests, then replace generation/loading with upstream packs. Preserve old specs as current behavior until their replacement is verified. Track all remaining milestones in docs/implementation-program.md and do not archive unfinished tasks.
