## Context

See proposal.md for scope. ADR 0011 delegates package discovery to upstream tools and keeps refactoring as development-time evidence. The completed source and prompt changes already separate package topology from optional Foundry intent. This change applies that decision to the remaining planning path; it does not introduce another architecture policy.

`Refactor#context_sources` currently uses `Dir.glob('**/*.rb', base: files.path(pack))`. It includes descendant packages and feeds their model declarations into the selected context's rule index. `Contexts#find` only selects configured contexts, which remains intentional. `PackageFiles` already validates upstream paths and resolves deepest ownership, but its current selection API enumerates app-relative trees rather than a complete selected package. `Files#path` intentionally refuses the application root itself.

Disposable reproduction at revision 431b590 showed:

- A sidecar-free nested package containing malformed test Ruby makes its parent's assessment `complete: false`, with the child's path in the findings.
- With `.` explicitly discovered upstream and a root foundry.yml, selecting the root namespace fails with `Paths must stay within the consuming application.`

An earlier probe did not exercise the intended domain rule path and omitted `.` from discovery; it did not establish root handling. The corrected probes above establish these defects. No consumer or implementation files were changed.

## Goals / Non-Goals

**Goals:** Make assessment scope correspond to the selected package, support a configured root package, retain useful non-app Ruby evidence, and prove installed behavior and preservation.

**Non-Goals:** Selecting unconfigured packages as profile-refactoring contexts; whole-application migration plans; automatic code or data conversion; new diagnostic rules or model-resolution capabilities; dynamic Ruby resolution; a new public crawler/report/configuration API; changes to source/prompt checking scope; dependency upgrades or Campfire harness repair.

## Decisions

### One upstream inventory per assessment

Resolve configured context selection and ownership from one validated inventory returned by the existing locked packs-specification integration. Preserve selection by namespace, exact package path or unambiguous basename, including existing ambiguity failures. Packages without foundry.yml still establish ownership boundaries. Do not rediscover by folder names or treat intent as the topology inventory.

Reuse or narrowly extend private package enumeration helpers. Do not call the app-only source checker as the refactor input: that would silently omit tests, lib and other previously inspected Ruby. Avoid a standalone traversal framework. Keep source/prompt callers' existing selection and safety behavior unchanged and regression-test them if shared code changes.

### Selected ownership before parsing

For non-root contexts, retain the current eligible set of non-hidden `*.rb` descendants, except prune every independently discovered descendant package before enumeration/parsing. Apply deepest package ownership to each selected path; sibling prefixes such as billing/billing_extra are distinct. Resolve findings deterministically using application-relative paths without leading `./`. Build model evidence only from the selected files. Pass the selected installed intent explicitly to shared rules, including for root paths.

Nested packages are excluded whether configured or not, even beneath app/domain or test. Assess them separately if configured; use existing source checks for general checks on unconfigured packages. Parent scans must neither inherit their models nor report their malformed Ruby. Do not silently broaden model discovery to the rest of the application.

### Root package traversal is explicit

A root context requires an upstream-discovered `.` package plus adjacent root foundry.yml; root config/foundry.yml remains application configuration. Enumerate root children with the already validated application root, then validate each relative child through existing path safeguards. Do not weaken Files#path globally to permit arbitrary root access.

Root scope includes non-hidden Ruby descendants such as app, lib, test, spec, config, db and script, as well as top-level Ruby files. Exclude independently discovered packages and these application-root non-source trees: vendor, node_modules, tmp, log, storage and coverage. Hidden entries remain excluded as with the previous glob. These root-only exclusions prevent dependency caches and generated data becoming shell code; retain existing non-root selection semantics. Document this bounded inspection in the existing limitations string and guidance. If upstream explicitly discovers a package in an excluded tree, it can still be selected individually; root selection does not inspect it.

### Controlled incomplete inspection

Reject unsafe package paths and symlinked entries encountered in the eligible traversal, including directory links that a glob might silently skip. Reject unreadable, disappeared or non-regular selected sources with relative-path diagnostics and nonzero status. Prune known excluded trees before inspecting their contents. Invalid upstream discovery fails with no root-only fallback. Do not print source bodies or raw content in errors.

The assessment remains boot-free: parsing does not execute Ruby, Gemfiles, initializers or tests. Preserve existing stderr failure behavior for operational errors and JSON `complete: false` for malformed selected Ruby. Findings alone still do not make an otherwise completed assessment fail. Empty owned source remains a completed empty assessment with stated limitations, not proof of migration success.

### Installed guidance follows verified behavior

Update the existing planning/profile-promotion/adoption references to explain selection, descendant exclusions, root scope and assessment-versus-migration evidence. Keep eight skills and use existing reviewed upgrades for changed references. Add resources to packaging/files.txt only if necessary; prefer existing shipped references. Reconcile stable contracts, adoption/source guidance and roadmap after acceptance. Existing ADR 0011 and package-ownership rationale suffice; do not add an ADR merely for this defect correction.

## Risks / Trade-offs

- Shared traversal changes could regress source/prompt checking → preserve their API behavior and rerun focused and installed checks.
- Excluding a child removes findings users previously saw → document separate assessment and unchanged full source checks; test both child configurations.
- Root inspection can be large → prune known dependency/generated trees and packages before walking; no claim of bounded execution time or filesystem snapshot isolation.
- Filesystem changes during assessment can invalidate evidence → fail on detected disappearance/read errors, avoid claiming atomic snapshot or protection against malicious concurrent mutation.
- AST model recognition remains incomplete → retain existing limitations; package ownership is not Ruby constant resolution or dependency verification.

## Migration Plan

No consumer data, manifests, dependencies or code migration is required. Install the reviewed gem, run the same refactor command and review corrected scope. Upgrade changed skill references through assessment/apply/explicit conflict resolution, preserving customized files and receipts. Roll back tooling and guidance through their existing reviewed mechanisms. No automatic changes to accepted debt or workflow selection occur.

Verify core and built-gem consumers first, followed by installed guidance for both package roots and all three skill targets. Record commands, outcomes, implementation commit, gem/resource hashes and unchanged dependency-lock hashes. Keep prior evidence attributable to its tested revision. Archive only after executable acceptance; leave unrelated open gates unchanged.
