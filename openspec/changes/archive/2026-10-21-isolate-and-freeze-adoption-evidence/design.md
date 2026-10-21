## Context

The package-aware source, prompt and refactoring work is verified. Adoption evidence is the next concrete trust gap: audit copies include `.claude` and private skill-upgrade sessions, accepted debt scans directories that audit copies exclude, and parity independently captures live inputs for each backend. Disposable synthetic fixtures reproduced the first two inconsistencies; separate backend captures were confirmed by code inspection. A false resolved-debt report or concurrent parity divergence has not yet been reproduced end to end.

Current snapshots compare source inventories before and after copying but do not compare copied bytes with the captured hashes. A transient source edit can therefore evade that comparison. These are input-integrity problems, not reasons to add another architecture abstraction.

## Goals / Non-Goals

**Goals:** keep private guidance/backups outside audit inputs; align accepted and regenerated debt eligibility; give both analyzers identical captured inputs; reject detected inconsistency; preserve installed behavior and record executable evidence.

**Non-goals:** dependency upgrades, hosted CI, new commands/options/report fields/configuration, package discovery changes, application execution changes, a security sandbox, automatic baseline regeneration in the source application, Campfire test-harness repair, new studies, deployment or publication. Keep eight skills, twelve applications and all existing dependency locks.

## Decisions

### 1. Share input eligibility without inventing topology

Reuse the existing snapshot exclusion policy for debt-input enumeration. Add `.claude` metadata and the application-root `.foundry/skill-upgrades` subtree. Do not exclude all `.foundry`: normal receipts and architecture inputs remain eligible. Exclude private content before reading, hashing, parsing or copying it. Retain current treatment of other caches, secrets and runtime data.

Read-only adoption enumerates eligible baseline files without booting Rails or materializing an application copy. It retains full upstream violation identities and existing eligible-file semantics, including baseline files outside configured packs. Packwerk's discovery remains authoritative; this change does not equate its package configuration with packs-specification. Boundary checking retains its separate conservative source-baseline preservation guard.

Read each baseline once for parsing. Missing, unreadable or malformed eligible inputs fail safely with relative locations, without raw content. Newly generated eligible baselines must be collected even if absent from the initial inventory.

### 2. Capture once, analyze independent derivatives

Capture one inventory and one pristine temporary snapshot per audit operation. Verify destination bytes against the captured inventory and recheck eligible source inputs. Derive accepted debt from that verified snapshot before removing any baselines. Create a separate working copy for each backend from the pristine snapshot, never from live source or another backend's modified copy.

Only working copies undergo baseline removal and upstream regeneration. Verify their initial inputs against the captured snapshot. Preserve existing locked-bundle execution and test-environment settings. Recheck eligible source inputs before success; detected changes or incomplete capture fail through existing error/report semantics. Do not silently retry against different inputs.

This is a verified capture, not a claim of filesystem-level atomicity or protection against hostile concurrent mutation. Destination hash checks specifically reject changed bytes copied during a transient edit even when the source is subsequently restored.

### 3. Version opaque fingerprints

Include an internal input-policy revision in the fingerprint calculation. Keep report schema 1 and existing fields/exit semantics. Older parity evidence requires regeneration, including applications with no newly excluded files. Preserve historical evidence unchanged. Changes confined to excluded private metadata do not invalidate a current fingerprint; eligible source or receipt changes do.

### 4. Keep temporary material private and bounded in lifetime

Create temporary roots with owner-only access and clean pristine/working copies on normal success and exceptions, including backend failures. Do not log copied content, credentials or absolute workstation paths. Test with synthetic canaries. Document that process termination may leave temporary files, and that disposable copies do not isolate network access, the environment, external bundle paths or arbitrary application boot behavior. Add no cleanup daemon or sandbox interface.

### 5. Deliver through existing installed guidance

Update only relevant adoption, architecture-review and verification references. Replay their delivery through the existing reviewed skill-upgrade acceptance for all three targets and both `packs/` and `components/`, preserving customized files, workflows, receipts and accepted debt. Ship any new resources through the explicit packaging inventory.

## Verification

Use focused fixtures for private exclusions, normal receipts, eligible and excluded baselines, single-read failures, source/destination mismatch, independent backend copies, policy-version fingerprints and cleanup. Use synchronization points for deterministic mutation tests; no timing-only races. Faulty controls must detect copying private content, counting excluded debt, recapturing live inputs for the second backend and trusting source hashes without verifying copied bytes.

Run built-gem adoption/audit acceptance without checkout access, real locked Packwerk regeneration, and the existing pinned pks parity lane. Missing prerequisites are recorded as blocked acceptance, never resolved by upgrading dependencies. Verify both new and resolved full violation identities and byte-for-byte source baseline preservation. Run affected core, packaged, AI/workflow and installed guidance lanes, RuboCop, contracts, skills/catalog, privacy, archive-content and strict OpenSpec checks using existing locked environments. Record commands, actual outcomes, candidate/gem hashes and unchanged dependency-lock hashes.

## Risks / Trade-offs

- An additional pristine snapshot and verified backend copies increase temporary storage and hashing work. Measure representative inventory/copy overhead; do not claim a performance improvement.
- Excluded paths may contain application-specific analysis inputs. Document the unsupported arrangement and fail when upstream analysis needs them; do not silently include private data or invent an override.
- Old parity evidence becomes stale by design. Regeneration is explicit and preserves the historical record.
- External files and custom analyzer behavior remain outside the captured-input guarantee. Keep these limits visible rather than claiming hermetic analysis.

## Migration Plan

No application migrations or dependency changes. Install the verified gem, assess/upgrade installed guidance through the existing review flow, then regenerate parity evidence when needed. Rollback reinstalls the previous gem and restores guidance through its existing rollback workflow; source application data and accepted baselines are never changed. Archive only after executable acceptance; existing study and hosted-release gates remain untouched.
