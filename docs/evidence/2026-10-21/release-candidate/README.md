# October local candidate and audit capture evidence

Status: locally verified, unpublished candidate; publication requires separate explicit readiness.

## Scope and provenance

Implementation commit `f5415da` adds private and consistent adoption capture, behavioral
controls and a demonstrated UTF-8 parity-report reload fix. Documentation candidate
`48649a0ea220b25a1d923eb7c5a2b8c322ee74e4` was extracted with `git archive` and built with
`SOURCE_DATE_EPOCH=315619200`. Its 172 packaged resources match the source byte-for-byte.
[Tested artifact](tested-artifact.json) records the gem and every resource hash.

The final [artifact](artifact.json) is built from commit
`94f310f7fd353e2bf6161cecb497b5fed0be8f3e`, with SHA-256
`426ffa9cc53abbf4dc419ba93f2578440d29ac75ccf8878124213a5921b60b44`.
Only four release-documentation resources differ from the tested source; implementation,
tests, skills and locks are identical. Final archive integrity/link checks pass 2 tests /
767 assertions. The actual final gem was installed outside the checkout and reports
version 1.0.0 and all eight contract schemas. The local handoff is
`pkg/release-candidate-1.0/rails_ai_foundry-1.0.0.gem` with `SHA256SUMS` alongside it.
Later evidence/specification reconciliation does not change these 172 packaged resources.

The user explicitly excluded hosted CI and publication. RubyGems.org is the intended
future registry; the repository URL will be supplied later. No remote, tag, hosted run,
publication, provider call or coding-agent trial is part of this work. Publication requires
the user's separate explicit readiness. Missing homepage metadata remains visible in gem
warnings; no URL was invented. The existing railties lower bound remains unchanged.

[Dependency hashes](dependency-hashes.json) cover 33 tracked dependency locks and ten
pre-existing local compatibility locks. All remain unchanged. Existing consumer acceptance
may resolve a fresh disposable application's local bundle; it does not update repository
locks. The restored pks 0.2.40 binary matches the historical SHA-256 exactly:
`256b831ccccdcbe844ef55fadcc3c93de3cdf73ef6b5949530e6a90f63c9e452`.

## Implemented behavior

- Claude metadata and application-root skill-upgrade backups never enter eligible
  inventory, fingerprints, accepted debt or analyzer copies. Ordinary receipts remain.
- Accepted debt and independent Packwerk/pks working copies derive from one verified
  capture. Copied bytes and detected source changes are checked; missing/unreadable inputs
  fail safely. Newly generated eligible baselines still contribute full identities.
- Fingerprints bind policy revision 2. Older parity evidence requires regeneration even
  when the gem version is unchanged. No baseline or historical evidence is rewritten.
- Temporary roots are owner-private, with normal success/failure cleanup. This is not an
  atomic filesystem snapshot or a sandbox for application boot, services or external bundles.

The focused suite passes 20 tests / 107 assertions. Six separate controls accept the
reference and an equivalent copy-check order, and reject four faults: private copying,
excluded-debt counting, live-source recapture and missing destination-byte verification.
Each faulty control reaches and fails a behavioral assertion. Expected faults are reported
as failures inside the passing control harness, not suppressed or relabeled as valid runs.

## Results

All executed acceptance lanes completed successfully. Counts below are tests / assertions;
expected faulty-fixture failures are asserted by the enclosing successful acceptance suite.

| Frozen-source lane | Core | Installed package |
|---|---|---|
| Ruby 3.3.10 / Rails 7.1 | 273 / 2,724 | 12 / 909 |
| Ruby 3.4.10 / Rails 8.1 | 273 / 2,724 | 12 / 915 |
| Ruby 4.0.6 / Rails 8.1 | 273 / 2,724 | 12 / 909 |

The managed package lane includes the optional real pks assertions. Other completed evidence:

- Installed real Packwerk/pks audit, parity and UTF-8 reload: 1 / 79.
- Installed delivery/upgrades, both roots and three targets: 2 / 396; real HTTP/browser,
  deliberately faulty controls and customized guidance/workflow/debt preservation.
- Installed RSpec/browser: Rails 7.1 and 8.1 each 22 / 775, including all targets and roots.
- Offline AI: Ruby 3.3/Rails 7.1, Ruby 3.4/Rails 8.1 and Ruby 4/Rails 8.1 each 8 / 60.
- Pinned workflow initialization: 3 / 39 against the clean candidate.
- RuboCop: 865 files; skills: six development/eight product; catalog: twelve apps.
- Privacy: zero findings after final evidence; all 172 resources and 43 dependency locks unchanged.
- Contracts: 10 / 142; eight schemas and 73 cases. Strict OpenSpec: 42 passing items before archive and 41 after verified archive.

The installed delivery replay began before candidate freeze. Its implementation, helpers,
guidance and test sources match the frozen revision; later release prose is verified by
archive/link acceptance, not presented as another browser replay.

## Retained evidence

[Retained corpus evidence](retained-evidence.json) verifies zero changes in 3,947 files
under examples, recipes and benchmarks since the September candidate. Their full service,
recovery and offline benchmark sweeps remain attributed to that dated source and its
original gem. This is not a fresh full-corpus run. The October 15 installed AI journey
passed 2 / 466; its application guide, replay and verification adapters are unchanged by
this audit change. New guidance is covered by the current installed delivery-upgrade replay.

No broad productivity, live-provider quality or hosted-Linux compatibility claim follows
from these checks. Campfire's frozen native-test limitation and unfinished studies remain
open separately; they are not represented as completed release acceptance.

## Failed attempts and corrections

- The first four audit regressions failed on the old code: private files were copied,
  excluded debt was read, unchecked destination bytes were yielded and fingerprints lacked
  policy identity. Corrected implementations and faulty controls establish the difference.
- RuboCop initially could not write its default cache under sandbox restrictions. A
  temporary cache allowed checks to run; formatting findings were corrected without rule changes.
- The pinned pks binary had been removed. Sandboxed download failed DNS; restoring the same
  official macOS artifact with network access reproduced its historical binary hash.
- Packwerk printed temporary-home cleanup warnings under the restricted filesystem during
  a successful parity run. Its assertions verified retained/resolved/new identities and
  unchanged source; warnings remain part of the observed output.
- Installed `parity --verify` exposed a UTF-8 report read as ASCII. Explicit UTF-8 decoding
  fixes it; a locale-specific regression and fresh installed parity pass. The new unit
  test's first standalone attempt missed `require 'json'`; that fixture error was corrected.
- Browser acceptance first failed local service access under sandbox restrictions. A fresh
  run with loopback permission, existing ChromeDriver and Selenium offline/statistics flags
  passed. No dependency upgrade or external provider was used.
- The first Ruby 4 command selected a stale local `rails_8_1` compatibility lock and frozen
  Bundler rejected it before tests. That lock was left unchanged; the already-valid root
  lock supplies the Ruby 4 run. This is not a successful run of the stale lock.
- A release-documentation commit attempt was denied filesystem access to the Git index.
  A retry with repository write permission succeeded. The preliminary archive built before
  that retry is superseded and is not the release candidate.

## Capture overhead and operational limits

[Capture sample](capture-sample.json): 1,000 synthetic files, 16,384,000 input bytes;
one pristine capture and two sequential verified backend copies took about 2.315 seconds
on this local Ruby 3.4/macOS ARM64 environment. Maximum simultaneous copy payload was
32,768,000 bytes, excluding the original, metadata and filesystem overhead. This is one
sample with concurrent acceptance activity, not a performance comparison or bound.

Normal cleanup is tested, but a hard kill can leave temporary files. Network access,
environment variables and original external bundle paths remain outside capture isolation.
Custom analysis inputs under excluded locations require application review, not an implicit
private-data override. Keep test-only credentials and services when allowing Rails boot.

## Reproduction

Use managed Ruby 3.4.10/Node 20.19.0 by default, with existing locks and dependencies.
Use `$CANDIDATE` for the extracted committed source and `$TMP` for disposable tooling.
[Executed commands and outcomes](commands.json) retain failures separately above. `$TOOLING`
is the existing pinned contributor tool installation; `$TMP/specify/bin` denotes the
existing pinned Spec Kit executable. Browser lanes used local loopback permission and the
existing ChromeDriver with Selenium network discovery/statistics disabled. Run from the
extracted source unless a lane explicitly identifies a pre-freeze or final-artifact run.

The release decision is **ready for local review and installation, held from publication**.
Hosted CI was skipped by instruction. The repository URL and public metadata are pending;
no remote, tag or registry upload was created. The historical hosted-release task and
unfinished studies remain open. Full-corpus retained evidence is not a new execution claim.
