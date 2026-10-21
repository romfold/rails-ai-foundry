# 0004: Optional RubyLLM conventions

Status: Accepted for the RubyLLM conventions milestone.

## Context

Core supports Ruby >= 3.0; RubyLLM 1.16.0 requires Ruby >= 3.1.3. Existing executable packages already provide Rails-managed loading and application ownership. The framework should not create a second agent runtime.

## Decision

Keep RubyLLM an application-selected dependency, activated by `require "rails_ai_foundry/ruby_llm"`. Guard its supported 1.16 patch series and Ruby floor explicitly. Core generators/checks remain available without it. Use separate AI Gemfiles for compatibility evidence.

Generate direct RubyLLM agent, tool, and schema subclasses in existing package roots. Tools accept application operations, which own authorization and business behavior. Deployment configuration chooses models and providers.

Keep plain-text instructions in package-local prompts directories outside app. Read them at chat construction through the public instructions API. RubyLLM's default application-root prompt lookup does not express package ownership; overriding its private methods or evaluating ERB would add unnecessary coupling.

Use a generation receipt to distinguish complete customized repeats from unrelated files. It records expected paths, not trusted provenance. Do not change application manifests or package metadata when adding agents.

## Consequences

AI users have a higher Ruby floor, while core users do not. Generated tests need the optional dependency but no credentials. Prompt files are data, not Rails roots. Existing loading/restart rules apply.

The support-triage example demonstrates explicit validation and bounded delegated tools. Deterministic HTTP responses test integration plumbing; manual live evaluation remains necessary for model quality. Persistence, streaming, RAG infrastructure, privacy enforcement, and a live runner are outside this decision.

## Supersession note — 2026-09-08

The historical Ruby floors above were superseded on 2026-09-06 by commit `b2ef134` and [decision 0007](0007-progressive-package-profiles.md): core and optional AI now require Ruby >= 3.3, with railties >= 7.1 unchanged. This note preserves the original milestone rationale; current compatibility evidence belongs in [the compatibility guide](../compatibility.md).
