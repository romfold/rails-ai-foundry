## Context

The 0.5 native generators already preserve complete edited scaffolds using receipts and reject partial/colliding writes. Skill catalogs deliberately require manual review across versions. Context intent checks schema 1; root configuration currently ignores unknown fields and unchecked policy mappings. Existing JSON consumers receive evidence without a format discriminator.

## Goals / Non-Goals

Goals: freeze supported CLI/configuration/scaffold surfaces, identify report formats and supply a reproducible upgrade review procedure. Non-goals: public internal Ruby service APIs, a migration runtime, automatic template merges, new checker policies, production dependency changes or publication.

## Decisions

Use draft-07 JSON Schemas as shipped editor/consumer assets. Keep boot-free Ruby validation independent of a production JSON Schema dependency; contributor-only Ajv checks actual Ruby validator decisions, corpus configuration and emitted reports to catch drift. Relative schema references resolve locally without network access.

Root schema defaults to 1; reject unsupported versions and unknown fields. Keep checks/adoption as empty reserved mappings because no policy keys are currently consumed: accepting fake switches is misleading. Workflow selection keeps the existing spec-kit input alias, while setup writes canonical spec_kit. Capability-specific settings remain open because adapters are application-owned.

Use additive report_schema, foundry_version and report_kind metadata; retain existing field meanings and exit statuses. Parity evidence must carry the supported format in addition to its application/input/tool identity. Keep stderr error text human-readable; do not invent equivalent validation for different specification workflows.

Expose a read-only contracts command that derives names from installed generator/skill catalogs and lists local bundled schema files. Internal Ruby classes remain implementation details. Document template edits as manual application changes; version upgrades never infer ownership from a matching file name alone.

## Risks / Trade-offs

Strict unknown-field rejection can reveal previously ignored settings → document exact 0.5-to-1.0 edits and test preservation on failure. JSON Schema cannot express duplicate YAML keys, symlink safety, namespace uniqueness or runtime behavior → keep Ruby checks authoritative and document scope. Additive report fields may break consumers that forbid extras → require tolerant readers in the stable contract and publish metadata examples. A 1.0 label does not promote experimental recipes → retain tiers and concrete evidence.

## Migration Plan

Review configuration with the new version in a branch, preserve locks and baseline hashes, compare skills in a disposable destination, manually merge selected guidance, and run owning behavior plus selected checks. Restore the reviewed commit and lockfiles to roll back development tooling. Regenerate parity evidence rather than converting historical reports. Keep the retired 0.1 migration manual. Publish only through a separately authorized release.
