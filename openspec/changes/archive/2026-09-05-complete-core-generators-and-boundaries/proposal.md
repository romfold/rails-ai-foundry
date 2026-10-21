## Why

Foundry has installation and package loading but no complete non-AI feature workflow. Restore gem-first delivery before expanding examples or RubyLLM.

## What Changes

- Add conservative package-owned operation generation with plain Ruby call objects and executable tests.
- Add a separate static dependency and privacy check using Packwerk and its privacy extension, with explicit load paths rather than Rails initialization.
- Generate privacy metadata for new packages and diagnose missing enforcement on existing packages.
- Reorder guidance around the core workflow and defer the unfinished support desk change without altering its code or task edits.

## Capabilities

### New Capabilities

- `operation-generation`: Package-owned operation scaffolds with explicit public visibility.
- `package-boundaries`: Static constant dependency and privacy checks independent of structural validation.

### Modified Capabilities

None. Structural checks, manifest schema, existing commands, and loading defaults retain their contracts.

## Impact

Adds `foundry:operation NAME --package=PACKAGE [--public]` and `foundry:architecture:boundaries`. Adds lazily loaded Packwerk 3.1 and packwerk-extensions 0.3 dependencies compatible with the Ruby 3.0 floor. Existing package metadata needs explicit privacy fields before the new boundary command passes. No AI or example runtime changes.
