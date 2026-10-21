# Package-aware feature verification — local acceptance

Implementation: `847c3fd5c97673f7dea93b73e93406bd3b75ce6a`.
[Resource, lock and archive hashes](package-verification-hashes.json) identify the
implementation build. The gem was built from a clean disposable `git archive` of
that commit. No historical release evidence, agent study or accepted debt was changed.
The follow-up documentation commit reconciles this record and the OpenSpec change.

## Environment and commands

Managed Ruby 3.4.10 and Node 20.19.0 on macOS arm64. Verification bundles retain
Rails 7.1.6 / RSpec Rails 6.1.5 and Rails 8.1.3.1 / RSpec Rails 8.0.4, both with
RSpec Core 3.13.6, Minitest 5.27.0, packs-specification 0.0.11, Capybara 3.40.0,
Selenium 4.49.0 and Puma 6.6.1. No dependency lock was changed.
The journey used a task-owned PostgreSQL 17 container on loopback port 55549,
removed afterward; pre-existing databases were untouched. All providers were offline.

Commands were executed with managed binaries on PATH, `TMPDIR=/private/tmp` for
consumer lanes and `RUBOCOP_CACHE_ROOT=/private/tmp/foundry-rubocop` for style.
The workflow lane also placed the pinned local OpenSpec executable and temporary
Specify 1.0.0 installation on PATH.

```sh
bundle exec rake test
bundle exec ruby -Itest test/package_verification_test.rb
bundle exec ruby -Itest test/package_evidence_integrity_test.rb
BUNDLE_GEMFILE=test_rspec/bundles/rails_7_1/Gemfile bundle exec rake test:rspec
BUNDLE_GEMFILE=test_rspec/bundles/rails_8_1/Gemfile bundle exec rake test:rspec
BUNDLE_GEMFILE=test_rspec/bundles/rails_7_1/Gemfile bundle exec ruby -Itest test_rspec/package_evidence_test.rb
BUNDLE_GEMFILE=test_rspec/bundles/rails_8_1/Gemfile bundle exec ruby -Itest test_rspec/package_evidence_test.rb
bundle exec rake test:package
PGPORT=55549 bundle exec rake test:journey
BUNDLE_GEMFILE=gemfiles/ai_rails_8_1.gemfile bundle exec rake test:ai
bundle exec rake test:workflows
bundle exec ruby -Itest test/distribution_integrity_test.rb
bundle exec rubocop
npm run contracts:validate
ruby script/validate_skills
bundle exec ruby script/validate_examples.rb
ruby script/privacy_check.rb
npm run spec:validate
```

## Results and coverage

- Core: 210 tests / 2,265 assertions passed. Focused final discovery cases: 11 / 96;
  malformed discovery/loading evidence: 2 / 16. The final empty-baseline reporting
  assertion was replayed separately after the full core run.
- Both locked framework lanes: initial full matrix 21 / 748 each passed. Final
  ownership/addition replays also passed 21 / 748 each. The later package-only RSpec
  case passed separately in both lanes: 4 / 22 each.
- Packaged regression: 6 / 498 passed; includes native loading, public HTTP delivery,
  Packwerk, preservation, and built-gem provenance. Final committed-code replay also passed 6 / 498.
- Installed AI journey: 2 / 227 passed across both roots, with native queue/process
  recovery, HTTP/browser behavior, faulty controls and production loading. Final committed-code
  replay also passed 2 / 227.
- Offline AI: 8 / 60 passed. Pinned workflow setup/preservation: 3 / 39 passed.
- Archive contamination and installed local links: 2 / 677 passed; final roadmap-link
  reconciliation replay passed 2 / 679.
- RuboCop: 838 files, no offenses. Contracts: 8 schema assets / 73 actual cases,
  associated tests 10 / 142. Skills: 6 development / 8 product. Catalog: 12 applications.
  Privacy: zero findings. Strict OpenSpec validation passed before reconciliation; the synchronized baseline also passed
  all 37 specifications, and post-archive strict validation passed all 39 active items.

The installed matrix covers all six target/root pairs: agents, claude and cursor,
each with packs and components. Consumers execute the installed helper, not a checkout
path. A prior catalog lacks the four new helper files; assessment and application add
them, customized skill guidance requires explicit keep-local resolution, repeated
generation preserves decisions, and rollback restores the original receipt/files.
Project instructions, unrelated skills, workflow selection and accepted debt remain exact.
The mixed-framework wrapper requires both native invocations. Correct HTTP/browser
behavior passes; broken root behavior, authorization and JavaScript interaction fail
in each framework. Browser checks prove visible status updates and preserved input.

Discovery coverage includes custom/nested/overlapping roots, root packages, packages
without Foundry sidecars, package-only applications, additive explicit files, duplicate
paths, absent tests, exclusions, unsafe symlinks and missing discovery dependencies.
Root/pack failure assertions detect discovery implementations that omit a package or
replace root coverage. Omitted-argument controls independently prove that passing other
tests cannot hide a planned file that never loaded. Shared definitions load without
receiving the including file's execution credit; inherited Minitest tests retain their
including-class ownership in opt-in mode. Missing/malformed reports, forged stdout,
filters, wrong types, timeout and interrupted execution fail. Existing non-opt-in
Minitest and RSpec cases remain in the core/framework suites.

## Corrections and limitations

Early failures were retained in the task transcript: an empty-baseline fixture selected
its former filename; Minitest fixture filenames were inadvertently included by the
contributor Rake test glob; installer count still expected 104 rather than 108 files;
and a direct inventory fixture needed a canonical temporary root. These fixtures and
expectations were corrected and rerun. Style corrections were applied before final
acceptance. Review also tightened opt-in Minitest ownership so shared method definitions
cannot claim execution from an including class; a specific regression verifies refusal.

Workflow acceptance first found the removed temporary Specify installation, then a
missing OpenSpec PATH entry. Specify was restored from pinned tag v1.0.0 (commit
`1ecccc04a0fd163c889ef034b909d4d3c49dc2b9`) into a temporary Python 3.13 environment;
the existing repository OpenSpec 1.12.0 was placed on PATH. No consumer fallback or
pin change was introduced. The corrected lane passed. An evidence-hash preparation
attempt referenced a non-versioned AI lock; the final manifest lists only the committed
core and framework locks. Runtime output contains expected upstream deprecation,
parser-version and gem-metadata warnings, plus deliberately failing controls.

These are local reproducibility and behavioral results, not independent usability or
agent-effectiveness measurements. RSpec expectation counts remain unavailable; loading
files does not prove adequate assertions, complete requirements coverage or resistance
to malicious test code. Tests require trusted application configuration and a prepared
disposable environment. Hosted CI, publication, provider evaluations, additional trials
and replay of unrelated advanced integrations were not performed. The existing hosted
release gate remains open.
