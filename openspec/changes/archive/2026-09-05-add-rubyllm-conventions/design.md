## Context

See proposal.md. Core already has safe file journals, structural validation, and Rails-managed package roots. RubyLLM 1.16.0 has public agent/tool/schema APIs but its built-in prompt lookup assumes top-level app/prompts.

## Goals / Non-Goals

Goals: optional activation, ordinary package namespaces, file-owned prompts, and offline evidence against the actual library.
Non-goals: another agent runtime, persistence, streaming, RAG infrastructure, automatic routing, privacy enforcement, live runner, or publishing.

## Decisions

- Keep one gem and an explicit optional require with version guards. A mandatory dependency would raise the core Ruby floor; a companion gem is unnecessary for this small integration.
- Generate RubyLLM subclasses directly. Accept an injected operation in the tool and agent. Pass model/provider through normal chat options; never bake deployment choices into templates.
- Keep plain text in package prompts/<agent>/instructions.txt. Generated classes derive an absolute path from __dir__ and read lazily in an instructions block. This avoids ERB evaluation, private prompt overrides, and Rails root changes.
- Reuse the installer file identity/content journal. Publish a deterministic JSON generation receipt under package .foundry/agents last, containing generator version, name, package, and expected paths. Require a matching receipt and all artifacts for repeats, preserving customized bytes. Without a receipt any occupied destination conflicts. Shared Ruby roots can contain other agents. Validate all paths including receipt before writing; no manifest mutation.
- Put Support::Triage in an example package mounted by the existing bootable host. Its schema and explicit result validation enforce enums/types. Use before_tool_call to raise before call four. Let dependency exceptions propagate; normalize malformed JSON/shape to InvalidOutput.
- Use WebMock only in a separate AI test suite, with all network disabled and an OpenAI-compatible deterministic transport fixture. This verifies integration plumbing, not provider quality or universal provider behavior.
- Keep the seven core combinations. Add six AI combinations, using Ruby 3.1.7 for Rails 7.2 in place of core's 3.1.1. Pin RubyLLM 1.16.0 in AI Gemfiles and record resolved test dependencies.

## Risks / Trade-offs

- Offline responses do not establish model quality -> document manual live evaluation without shipping a runner.
- A receipt is bookkeeping, not security provenance -> preserve customizations only for matching complete scaffolds and reject unsafe paths.
- Dependency API changes -> restrict RubyLLM to the 1.16 patch series and test its public API.
- Authorized lookup depends on application policy -> inject an already-scoped operation, with no generated authorization bypass or external adapter.

## Migration Plan

Existing applications need no changes. AI consumers add the optional dependency, explicitly require the integration before eager loading, generate into an existing package, and enable package loading. Remove application references and generated files through reviewed edits to roll back; no automatic reversal or manifest migration occurs.
