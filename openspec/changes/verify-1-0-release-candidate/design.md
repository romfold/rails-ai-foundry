## Context

The checkout has no Git remote. Core and packaged acceptance already pass at 1.0; application/service acceptance is dated before the stable-contract release.

## Goals / Non-Goals

Verify final application behavior without changing the user's checkout or existing services. Hosted CI remains an explicit pending gate until the repository is identified. Do not publish, spend on live providers or call offline results model-quality evidence.

## Decisions

Use a disposable archive of commit 71cfd0c and compare gem-owned files with the built 1.0 archive. Run each owning bundle and Compose definition sequentially under a unique project name. Retain complete command logs plus concise machine-readable results outside the consuming apps. Stop only task-owned services in finally cleanup. Preserve source locks and accepted debt. Reuse installed dependencies without updating their versions.

## Risks / Trade-offs

Local macOS execution does not establish hosted Linux success. Cached packages or service readiness may require corrective setup; record failures and retries. Missing remote blocks hosted CI, not local acceptance. A newly found code defect requires a revised candidate and repeat affected acceptance.

## Verified compatibility finding

Ruby 4 core and offline AI acceptance passed, but packaged boundary acceptance failed before Packwerk: Bundler 4 generated empty CHECKSUMS entries during local-only fixture resolution, then rejected them under frozen mode. Configure only disposable test hosts to omit generated checksum entries; retain network blocking and frozen boundary execution. This does not change consumer defaults, production code, existing locks or accepted debt. Re-run packaged Ruby 4 acceptance and the managed-Ruby boundary regression.

## September 24 current-candidate verification

The earlier 71cfd0c evidence remains historical. Freeze a new committed candidate after
RSpec and populated adoption acceptance; use a clean Git archive, exact resource/gem hashes,
independent locks and disposable services. Execute all current declared local compatibility,
application, offline recipe and benchmark-control lanes. No agent execution, live providers,
hosted configuration, tagging or publication is included. A product correction requires a
new candidate and affected reruns, with unchanged evidence explicitly attributed.

The first revised candidate was `017ac49453a5776115831a03155b415d64abe5c6`; its distributed
resources and gem are byte-identical to the first sweep candidate `73c13b4`. The only
correction changes the missing-generator assertion for native Rails 7.1 behavior,
verified again on every declared Ruby/Rails lane. Current command/provenance evidence
is [recorded separately](../../../docs/evidence/2026-09-24/release-candidate/README.md);
the older candidate's results remain historical. Hosted CI remains an independent pending gate.

Final attribution correction: `c5172fd` binds shared RSpec examples exclusively to their
including file. A reproduced negative control failed against the old formatter before
the fix. This creates a new final gem and reruns affected RSpec and distribution lanes.
Unchanged Minitest, application, recipe, compatibility and benchmark evidence remains
explicitly attributed to its original candidate and original gem digest.

The final source candidate is `10d4d9b357fba462c86fea568286b4fb4216ba8b`. Its only
change after `c5172fd` makes the advanced-composition PostgreSQL health check use TCP,
preventing the temporary initialization server from satisfying readiness. The documented
startup and seven-test lane pass against that committed change. All 159 packaged resources
and the built gem remain byte-identical to the previously verified formatter candidate.

Local acceptance completed September 28 after recovering interrupted offline controls.
All 84 upstream, 45 Foundry and 14 reviewed-AI controls are accepted. Original host-sleep
and Docker failures remain separately recorded with explicit retry selection and hashes.
All declared local compatibility, application and recipe lanes pass with the documented
candidate attribution; 34 dependency-lock and accepted-debt files remain unchanged.
Both implementation changes are archived. Only hosted-CI task 1.3 remains open.

## October supplied repository metadata

The user supplied `https://github.com/romfold/rails-ai-foundry`. Candidate `7a484c6`
adds release metadata and updates current guidance without changing dependencies.
The repository responds publicly, but main-branch README/changelog files returned 404;
source publication and rechecking these links remain required before registry release.
See the [metadata follow-up evidence](../../../docs/evidence/2026-10-21/repository-metadata/README.md).
No remote, push, hosted run, tag or RubyGems upload is included. Publication still requires
explicit readiness. Earlier evidence remains attributed to its original artifact.
