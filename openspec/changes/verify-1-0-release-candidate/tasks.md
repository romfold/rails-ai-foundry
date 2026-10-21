## 1. Final candidate verification

- [x] 1.1 Verify commit/gem provenance and run all twelve applications' setup, behavior, loading, boundaries, workflow checks and RuboCop with locked dependencies; record results and cleanup.
- [x] 1.2 Resolve demonstrated failures and rerun affected acceptance; preserve locks and baseline identities and record any candidate changes.
- [ ] 1.3 Historical hosted-CI gate: deferred outside the user-authorized October local candidate; no hosted runs are claimed. Run only under a separately authorized future scope with a repository destination.
- [x] 1.4 Commit evidence and a release decision, keeping unverified gates visible and publication separate.

## 2. Current candidate after broader verification and populated adoption

- [x] 2.1 Freeze the committed revision after both implementation changes pass; build from a clean Git archive and record gem/resource/dependency hashes.
- [x] 2.2 Run the declared Ruby/Rails compatibility matrix (including Ruby 4), core/package/AI/workflow/journey/upgrades/RSpec and structural/privacy/archive checks.
- [x] 2.3 Run all twelve independently bundled applications, advanced and experimental recipes, adoption and knowledge recovery, and offline benchmark controls; preserve locks and debt.
- [x] 2.4 Record failures/corrections and attributable current results, reconcile the two implementation changes, and retain hosted CI as pending.

## 3. October local candidate after verified audit capture

- [x] 3.1 Complete audit capture acceptance, freeze a committed candidate and build from a clean Git archive; verify packaged resources and dependency-lock hashes against that commit.
- [x] 3.2 Run release-critical local compatibility, packaged, workflow, AI, installed-guidance and structural/privacy checks; identify unchanged dated application/recipe evidence explicitly instead of relabeling it as a fresh full-corpus run.
- [x] 3.3 Correct current changelog and release/installation guidance, record known limitations and exact artifact provenance, and verify installed distribution links. Keep destination metadata pending unless supplied; do not invent URLs.
- [x] 3.4 Record the local release decision and remaining public-distribution prerequisites; explicitly exclude hosted CI and leave tagging/publication unexecuted. Verify the artifact and all required evidence are available locally.

## 4. Supplied repository metadata

- [x] 4.1 Add the supplied repository URL and skills-focused summary to gem metadata and current release guidance without changing dependencies or publishing source.
- [x] 4.2 Rebuild from a committed archive, verify metadata, packaged resources, installed links and local installation, and record the new artifact hash separately from prior evidence. Retain the publication hold and deferred hosted-CI gate.
