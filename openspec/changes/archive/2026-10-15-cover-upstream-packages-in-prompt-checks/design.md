## Context

See proposal.md for motivation. `Assessment` already returns upstream package paths separately from configured contexts. `AssessmentCommand#verify_prompts` passes only contexts to `PromptCheck`. That checker globs shell/configured prompt roots, while `PromptContract` accepts shell ownership by prefix and package ownership only when a matching context exists.

Two disposable direct-checker probes at revision be89aec reproduced the gap: unconfigured `packs/plain` instructions without a contract yielded success with zero checks; a contract beneath `app/prompts/nested/app/prompts/answer` with owner `.` yielded success despite a nested package marker. These establish checker behavior, not end-to-end discovery acceptance. Implementation must promote both probes to CLI tests with actual upstream discovery.

The previous source change supplies a tested deepest-package ownership and safe traversal policy. Current specs intentionally describe configured-only prompt scope, so this is a deliberate contract extension, not a claim that the old implementation violated that specification. ADR 0011 and the current architecture distinguish topology from optional intent.

## Goals / Non-Goals

**Goals:** Make explicit AI artifact verification usable during incremental pack adoption, with exact ownership, truthful coverage and installed evidence.

**Non-Goals:** Resolve Ruby constants or models; interpret/evaluate templates or evaluation YAML; infer AI capabilities; generate configuration; relocate prompts; change agent-generation eligibility or receipts; make security, model-quality or behavioral claims from static validation.

## Decisions

### 1. Reuse upstream inventory and private ownership policy

Pass the assessment's discovered package paths into prompt selection and validation, alongside contexts. Do not rediscover by looking for directory names, sidecars or package markers outside the upstream result. Normalize relative paths, deduplicate and determine ownership by the deepest package boundary with a path-segment match; `.` is the root owner if discovered.

Share only the small private ownership/traversal primitives needed by Ruby source and prompt checks. Keep selectors specific to their artifact types and retain all prior source tests. A generic provider, configurable crawler or public extension API would enlarge the product without helping this scope.

### 2. Preserve recognition rules while fixing coverage

Inspect the shell `app/prompts` plus each discovered package's `app/prompts`. Select explicit `contract.yml` and conventional `instructions.txt` / `instructions.txt.erb`; the latter require an adjacent contract. Deduplicate by normalized contract path, including missing contracts inferred from instructions. `files_checked` continues to count attempted contract validations, not individual templates or evaluation files.

Stop a parent's traversal at nested package boundaries and visit each package through its own prompt root. Packages nested within an ancestor prompt tree are not ancestor-owned. A package located exactly at a proposed prompt root must be handled by its own `app/prompts`, not by treating its whole subtree as prompts. A root package does not double-count shell artifacts. Arbitrarily named templates require an explicit contract; other app directories, tests and lib remain outside selection. Zero contracts remains a truthful successful structural result, with limitations that avoid implying AI acceptance.

### 3. Validate actual ownership before optional namespace intent

Require a contract's owner to equal the normalized owning package path, or `.` for the shell/root package, and require placement under that owner's prompt root. A parent or sibling cannot claim a nested package's contract even if a string prefix matches.

For configured owners retain the existing agent namespace restriction. For unconfigured owners validate constant syntax but infer no namespace from directory names, ancestors or application defaults. This admits hand-written upstream AI code without requiring a sidecar. Do not add namespace restrictions to tools/output schemas beyond current behavior. The optional `foundry:agent` generator still requires its explicit configured context and RubyLLM capability.

Template/evaluation references stay within their contract directory and must also remain within the same package owner. This prevents a reference from crossing into a nested package even if it contains no `..`. Retain current rejection of absolute paths, traversal, symlinks, missing files, malformed shapes, duplicate YAML keys and unsupported schema versions.

### 4. Fail visibly without evaluating application artifacts

Enumerate directories explicitly so unreadable directories or disappearing entries cannot silently become an empty successful glob. Absent prompt roots are legitimate; wrong-type roots, invalid inventory and encountered symlinks fail without following external targets. Recheck selected contract/reference paths before inspection. Keep this a local filesystem check, not a guarantee against hostile concurrent filesystem replacement.

Preserve the existing command/report envelope and `prompt.contract` diagnostic fields. Contract validation failures use existing diagnostics; inventory/enumeration failure uses the existing command error channel and nonzero status, without a successful partial report. Do not include template/evaluation bodies or credential values in evidence. Do not boot Rails, evaluate ERB, resolve declared constants, parse evaluation bodies or call providers.

### 5. Deliver through existing guides and verification lanes

Update prompt contracts, stable contracts, architecture rationale and the existing AI/native/verification references where relevant. Add no new skill or application. Use installed AI journey upgrade acceptance for both `packs/` and `components/` and all three targets to prove updated references arrive while local customizations, receipts, selected workflows and accepted debt survive. Keep behavior tests separate from prompt declarations.

## Risks / Trade-offs

- Broader coverage exposes invalid prompts formerly skipped -> document the expansion, provide location-based corrections, and never automatically add sidecars or rewrite contracts.
- Shared ownership helpers could regress Ruby coverage -> rerun all package-source ownership, omission and safety controls, plus both locked core lanes.
- Root/nested layouts can double-count or bypass ownership -> exact-inventory tests, real upstream discovery fixtures and faulty controls are acceptance gates.
- Existing configured-only tests do not prove incremental adoption -> require sidecar-free installed consumers and a repaired valid equivalent for each negative control.
- Static contract validity can be mistaken for safe AI execution -> retain direct offline agent, authorization and missing-prompt tests; document that evaluation presence proves no outcomes.

## Migration Plan

Implement discovery and ownership first, then safety/error handling, installed acceptance and guidance. Existing CLI invocations, schema 1 and locked dependencies remain unchanged. Users review newly exposed findings explicitly; no migration command or compatibility runtime is necessary. Reviewed skill upgrades distribute guidance only, leaving prompts and application code untouched. Rollback of tooling does not rewrite consumer artifacts or receipts.

Record the implementation revision, built-gem digest, packaged resources, dependency hashes, commands and corrected failures. Synchronize requirements and archive only after acceptance. Preserve the existing release evidence and unfinished Campfire, study and hosted-CI gates.

## Acceptance-driven refinement

The required malformed-discovery regression exposed an uncaught JSON parsing error before prompt selection. Validate and normalize upstream output at the existing Contexts handoff using the same private package inventory, and translate invalid JSON into a controlled configuration error. This retains the discovery provider and report schema while preventing a partial assessment. Source fault controls freeze selected files when mutating ownership, so they continue to isolate the intended architectural error.
