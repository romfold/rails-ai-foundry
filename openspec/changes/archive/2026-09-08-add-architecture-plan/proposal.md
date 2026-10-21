## Why

Foundry has package generators and constraints but no optional file-based workflow for reviewing ownership and profile choices before generation. Add deterministic guidance and resumable package application without replacing application specifications or manifests.

## What Changes

- Add versioned questionnaire/plan formats and advisory profile recommendations.
- Add non-booting `foundry plan propose`, `validate`, and digest-reviewed `apply` commands using existing package installers.
- Add an eighth shipped planning skill, preserving direct generation and conservative catalog upgrades.
- Document scope and review limitations in ADR 0010 and consumer guidance.

## Capabilities

### New Capabilities
- `architecture-planning`: Safe proposal, review, validation and resumable package application.

### Modified Capabilities
- `foundry-skills`: Eight shipped skills with optional planning guidance and unchanged conservative installation.

## Impact

Internal Plan components, CLI dispatch, shared generation preflight, packaged skill resources and tests. Ruby >= 3.3, railties >= 7.1, MIT and local version 0.1.0 remain. No automatic migration, Rails boot, event semantics, example changes, publishing or provider calls.
