## Why

Executable packages need a small, optional convention for model interactions that keeps business operations in application code. A tested workflow can establish those boundaries without introducing a second AI runtime or raising the core Ruby floor.

## What Changes

- Add an explicit optional RubyLLM entry point and package-owned agent generator.
- Generate agents, delegated tools, schemas, plain-text prompts, and offline tests.
- Add an executable support-triage example with bounded tool use and deterministic provider responses.
- Document deployment configuration, operational boundaries, and manual live evaluation.

## Capabilities

### New Capabilities
- `rubyllm-integration`: Optional dependency activation and compatibility errors.
- `agent-generation`: Safe generation of package-owned RubyLLM scaffolds.
- `offline-ai-workflow`: Structured support triage and deterministic verification.

### Modified Capabilities
None. Existing package loading and structural validation retain their contracts.

## Impact

Adds generator/runtime files, separate AI development Gemfiles, tests, and an example. Core dependencies, manifest version, package metadata, opt-in loading, MIT licensing, and local version 0.1.0 remain unchanged. AI use requires Ruby >= 3.1.3 and RubyLLM ~> 1.16.0; ordinary Foundry retains Ruby >= 3.0 and railties >= 7.1.
