# Broader verification and populated adoption: implementation evidence

Environment: macOS arm64, Ruby 3.4.10, Node 20.19.0, offline application providers,
disposable loopback PostgreSQL 17 and real Chrome. This records implementation acceptance;
the current committed release candidate and complete lane results are recorded separately.

## RSpec

Independent locked combinations: Rails 7.1.6 / rspec-rails 6.1.5 and Rails 8.1.3.1 /
rspec-rails 8.0.4, both rspec-core 3.13.6, expectations 3.13.5, mocks 3.13.8 and support
3.13.7. Capybara 3.40.0 and Selenium 4.49.0 drive real browser acceptance. These are tested
combinations, not a claim covering all upstream versions. RSpec remains outside production
and the core bundle.

```sh
BUNDLE_GEMFILE=test_rspec/bundles/rails_7_1/Gemfile bundle exec rake test:rspec
BUNDLE_GEMFILE=test_rspec/bundles/rails_8_1/Gemfile bundle exec rake test:rspec
```

Both lanes passed 14 tests / 377 assertions before the additional custom-pattern refusal
control. Selected request and browser evidence runs after assessment, apply, explicit
resolution and repeated generation, with rollback/re-upgrade tested. Default `packs/`,
custom `components/`, and agents/claude/cursor targets pass. Deliberately broken tenant
concealment and browser interaction fail assertions. A later focused run passed 11 / 96 with custom-pattern refusal; frozen-candidate evidence includes the final version.

Native evidence tests include shared example attribution, pending/skip IDs, wrong types,
empty selections, filtering, dry runs, suite errors, forged success stdout, missing/malformed
reports, timeout and interruption. RSpec's first SIGINT can finish the last example and
exit successfully: acceptance exposed this, so completion also rejects native early shutdown.
Expectation counts remain unavailable; a passing expectation-free example is deliberately
accepted to document that limitation. Existing Minitest evidence acceptance passed 18 / 107.

## Populated ownership

```sh
PGPORT=55545 bundle exec ruby recipes/knowledge-adoption/bin/replay --scenario=tenant-backfill
```

Both roots passed the 13-test / 67-assertion populated recovery suite, plus repeated
characterization checkpoints (2 / 14 each), continuity checks for all 1,201 original
records, installed-gem assessments, real failing/repaired Packwerk boundaries, and four
expected behavioral fault failures per root. Fresh schema preparation is replayed separately
from populated migration. Final replay passed in both roots using the committed SQL schema, fresh compatible
writes/isolation and source/boundary checks after the rollout. The unchanged default
extraction/ROM/integration journey also passed both roots after dependency preparation.

The concurrency control holds a batch transaction open while another process creates,
edits and deletes unrelated documents. It exposed a real legacy-join lock defect: a generic
`FOR UPDATE` also locked collections. Restricting that lock to documents resolved it.
Crash checks kill a synchronized child before/after commit. The parent explicitly clears
its Rails query cache before observing another process's committed state.

Harness corrections included an explicit seed require, converting ActiveRecord::Result to
rows, and running focused commands from the actual extracted public facade/application.
Initial attempts remain failed attempts; neither Rails help nor stale cached reads count
as successful recovery evidence. Unresolved ownership never receives a fallback tenant.

## Supporting checks and limits

Core acceptance passed 197 / 2,127. Optional AI passed 8 / 60 using its independent bundle;
an initial root-bundle invocation failed because WebMock was unavailable. Native workflow
acceptance passed 3 / 39 after putting the existing Specify 1.0.0 environment on PATH.
The missing-prerequisite run failed explicitly. Original adoption first stopped because
ROM dependencies were absent from local cache; its pinned recipe bundle was prepared
without changing locks before replaying it.

Root RuboCop passed 828 files at the first full pass; subsequent changed paths were checked.
Skills (six development/eight product), twelve-example catalog, eight schemas / 73 actual
contract cases, privacy (zero findings), and strict OpenSpec (38 items) passed. Full current
candidate checks supersede these intermediate counts where source changes followed them.

No hosted CI, publication, agent trial, live provider or production migration ran. Demo
authentication, application-specific ownership rules, operator confirmation of old-writer
shutdown and possible in-flight timeout overshoot remain explicit limits. Historical trial
and release evidence is unchanged.

## Final attribution regression

Release review found that listing both a shared definition and including file as owners
could credit an unselected includer. Commit `c5172fd` records only the including file.
The new regression fails against the original formatter and passes against the fix.
Both final locked RSpec lanes pass 15 tests / 385 assertions, including installed
upgrades and HTTP/browser controls. See the [current candidate ledger](release-candidate/README.md)
for changed resource identities, affected reruns and separately attributed unchanged lanes.
