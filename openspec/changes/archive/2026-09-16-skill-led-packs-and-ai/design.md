## Context

See proposal.md for motivation. Existing core uses upstream packs staging, boot-free sidecars, receipt-based safe scaffolds and native RubyLLM 1.16 agents. Skills and the core guide are short; prompts currently live under root app/prompts; source checking detects only explicit Foundry references. The RAG app already has SQL retrieval and provider calls outside transactions but lacks a document-revision check during re-embedding.

## Goals / Non-Goals

Goals: teach working application development, validate concrete risks without booting Rails, and preserve application ownership. Non-goals: CLI wrappers, capability generators, scored plans, production runtimes, hosted CI without a destination, paid evaluations and a thirteenth catalog app.

## Decisions

- Use direct locked packs commands, documented against 0.3.0. Upstream create owns topology; application authors add foundry.yml. Explain all mutation/debt implications and review moves explicitly.
- Extend the existing eight skills using shared references. Replay labeled Markdown shell/file snippets from the installed gem in disposable archive acceptance; assert persistence and boundary behavior independently.
- Generate pack-relative plain text prompts and use File.read with a path expanded from __dir__. Avoid RubyLLM ERB locals and automatic root search. Keep root model aliases. Treat existing complete receipt paths as preservation evidence; do not silently move files.
- Validate explicit prompt YAML contracts and references using existing safe file/YAML helpers. Add an opt-in CLI check with stable diagnostics; constant names are declarations, never loaded. Extend JSON report schemas additively in the unpublished candidate.
- Parse Ruby with Ripper. Restrict errors to documented syntax in configured layers; treat inferred transaction/callback concerns as warnings. Avoid lexical-resolution claims, template execution and baseline mutation.
- Keep SQL retrieval available; add Neighbor inside the RAG bundle and exercise both through shared tests. Compare document revision under lock after external embedding work. Add bounded exact/ANN evidence and payload-safe instrumentation.
- Keep FlowNodes and Langchainrb in independent experimental bundles, using native APIs and deterministic fake boundaries. Record pins after resolving and testing; no core dependency additions.

## Risks / Trade-offs

- Prompt placement changes a documented default → apply the user-authorized unpublished-candidate change, document manual relocation and preserve complete old receipts.
- Static Ruby evidence misses dynamic calls → explicit scope, stable rules and severity/certainty separation.
- Upstream package moves cannot update all application references → require diff review, receipt/prompt reconciliation and fresh loading/behavior checks.
- Optional libraries and services can be unavailable locally → report actual failures and retain unfinished acceptance tasks; never claim evidence from schema checks alone.

## Migration Plan

Land focused verified changes. Preserve research originals and historical archives. Add a decision/gap register; keep all remaining work visible. Reconcile current specifications only after the matching behavior passes. Roll back through reviewed commits; application files and accepted debt are never automatically converted.
