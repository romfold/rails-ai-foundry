## Context

See proposal.md for the reproduced omission. At `46a0cf4`, `Assessment` already publishes both upstream `packages` and configured `contexts`, but `AssessmentCommand#verify_sources` passes only contexts to `SourceCheck`. Its source roots are shell app plus context app. `ArchitectureSourceRules` then chooses the longest configured context prefix, without knowing about intervening packages that have no sidecar.

The source report already provides success, file count, diagnostics and limitations. The existing test and package acceptance infrastructure can exercise this change without a new bundle or runner. The source architecture task delegates to the same assessment command. The refactor planner shares architecture rules but intentionally examines only one configured context, including tests.

ADRs 0011 and 0016 keep execution and loading upstream and application-owned. ADR 0015 establishes the related distinction between package discovery and test coverage. The research's reusable lesson is to demonstrate what a check actually covers; this change makes no claim about agent effectiveness.

## Goals / Non-Goals

**Goals:** Separate physical package ownership from optional Foundry intent, cover all eligible Ruby sources and preserve trustworthy static-check limitations. Make source selection testable independently of architecture findings.

**Non-Goals:** New diagnostics, inferred profiles, Ruby constant resolution, ERB/asset checking, prompt-check expansion, automatic extraction or new public configuration/report fields. Do not widen the refactor planner or change application locks and native test harnesses.

## Decisions

### 1. Reuse discovered packages instead of rediscovering context paths

Pass the existing assessment's package list alongside configured contexts to source checking. Do not add filesystem pack-name heuristics or a parallel topology registry. Source collection is a private implementation detail, with small focused code rather than a general discovery framework. If a private helper is extracted, ship it through the explicit packaging inventory.

Alternative: require sidecars on every package. Rejected because ordinary upstream packages are supported and adding architectural intent solely to obtain source coverage is misleading. Alternative: introduce another option. Rejected because --sources is already an explicit check and should cover known application packages.

### 2. Normalize ownership before selecting context-specific rules

Treat `.` as the root package and normalize shell paths to app/... without a leading ./ segment. Deduplicate paths and sort deterministically. Resolve ownership using the deepest discovered package boundary, not a string prefix lacking a separator. A child package without a sidecar has no Foundry context; it must not inherit its parent's namespace/profile. Match domain placement against the owning context's normalized app/domain path.

Select Ruby files in shell app and each package app, then retain only files eligible under their actual owner's app tree. This prevents an overlapping parent scan from inspecting a nested package's non-app files. Root/default/custom/nested layouts need fixtures, including a configured root and an unconfigured nested package.

Keep the existing model-recognition limitations: use source-declared Active Record classes and explicit constants, plus a namespace only when that owning context actually supplies one. Do not add variable type inference or infer namespaces from directory names. Exercise shared-rule callers so the selected-context refactor behavior remains unchanged.

### 3. Reject unsafe partial coverage without loading Rails


Use existing safe-file access for reads and preflight discovered roots. Walk selected source trees without following symlinks; a symlinked directory must not disappear silently through glob behavior. Fail on invalid paths, link encounters, unreadable/disappeared selected files or upstream discovery failure. Do not print source contents in these errors. Preserve current handling of legitimately absent app directories: they contribute zero files.

The check remains a point-in-time static assessment, not a transactional filesystem snapshot. No watch service, persisted inventory, cache or concurrent-edit locking is introduced. Tests prove that initializers, classes and selected source are not evaluated. Explicit Packwerk checks retain their separate test-environment behavior.

### 4. Keep the public surface and failure meanings

Use existing sources.files_checked, diagnostics and limitations, and existing exit statuses. Keep ordinary checks without --sources unchanged. A package with no sidecar stays out of contexts; adding source coverage must not imply architecture configuration validation for it.

The behavior expansion is intentional: existing explicit checks may now fail because more code is inspected. Update stable-contract and source-diagnostic prose, with an example showing a discovered unconfigured package and its actual count/finding. Zero files remains an honest static result, never behavioral acceptance. Do not introduce fallback flags or amend accepted debt to restore a green check.

### 5. Acceptance uses omission controls and installed behavior

Extend existing source/rule tests and `test_packaging` consumers rather than creating another application lane. Reproduce the current omission first. Require equivalent healthy applications to pass with and without sidecars; adding or removing a sidecar must not hide profile-independent faults. Test every existing global rule in newly selected packages, while preserving warnings and configured-only domain enforcement.

Use temporary faulty variants that omit unconfigured packages, replace shell roots with package roots or inherit parent intent incorrectly. Acceptance must reject these variants through exact findings/counts or incorrect-finding assertions, not merely command crashes. Keep these controls outside distributable resources. Build the gem and run check/adopt/task acceptance without checkout access with both package roots. Reuse the existing reviewed-upgrade tests for changed references across all three skill targets; do not create another upgrade mechanism.

Run the existing frozen Rails 7.1 and managed Rails 8.1 core lanes, package/source acceptance, the installed delivery replay, relevant AI/workflow checks and repository quality checks. Record dependency lock hashes before and after. No full twelve-app or release-candidate re-certification is implied by this bounded change.

## Risks / Trade-offs

- More files can expose old failures and increase check time → document the expanded scope, retain app-only selection and verify distinct counts; no speed claim.
- Broader model declarations can expose lexical-resolution ambiguities → retain documented syntactic limitations and use explicit-constant controls, including same leaf names in different namespaces.
- Nested/root ownership changes can regress shared rules → test those layouts and preserve refactor planner behavior explicitly.
- A static pass can still miss dynamic coupling, templates and missing authorization → retain Packwerk and HTTP/browser acceptance as independent evidence.
- Contributor service/tool prerequisites can be unavailable → record the lane as blocked rather than changing locks or claiming acceptance.

## Migration Plan

1. Implement and verify source coverage in the existing gem; no application file or data migration occurs.
2. Update existing installed guidance through reviewed skill upgrades, preserving local edits, receipts, workflows and accepted debt.
3. Record commands, implementation commit and built-gem hash. Reconcile current specifications only after acceptance; archive this change then.
4. Rollback selects the prior gem and uses the existing conditional skill rollback only if guidance was upgraded. No source/debt rewrite is performed. Explicitly acknowledge that the prior gem restores the old coverage limitation.

Campfire native tests, hosted CI and unfinished agent-study acceptance remain separate open records. Historical evidence and research originals remain unchanged.

## Acceptance-driven correction

The installed replay exposed text-mode I/O in reviewed skill upgrades when replacing
existing non-ASCII references under Rails' default internal encoding. The required
guidance delivery therefore includes binary snapshot reads and temporary-file writes
within the existing upgrade store. A focused regression verifies exact bytes through
upgrade and rollback with UTF-8 internal encoding. This restores the already specified
byte-preservation behavior; it adds no upgrade action or application compatibility layer.
