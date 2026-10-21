# Installed delivery extraction — local evidence

This record covers `guide-existing-delivery-pack-extraction`. The fixture is contributor-only,
not a thirteenth application. Campfire, its lockfile and its test harness were not changed.
The existing Campfire adoption change remains open with blocked native-test acceptance.

Implementation commit: `47674fd223780dcbaccfc4f34ca874899b02d1f0`.
[Resource and lock hashes](delivery-extraction-hashes.json) identify a gem built from
a clean disposable Git archive of that revision. Test results before documentation reconciliation
were run against matching implementation and executable snippets; the final archive
was inspected separately: all 168 entries match the reviewed inventory. This is not
an additional full release-candidate replay.

## Environment and scope

Managed Ruby 3.4.10 and Node 20.19.0 on macOS arm64. The new independently locked lane
uses Rails 8.1.3.1, Minitest 5.27.0, JSON 2.21.2, packs 0.3.0, packs-rails 0.1.0,
packs-specification 0.0.11, Packwerk 3.1.0, importmap-rails 2.2.3, Propshaft 1.3.2,
Stimulus Rails 1.3.4, Turbo Rails 2.0.23, SQLite3 2.9.6, Puma 6.6.1,
Capybara 3.40.0 and Selenium 4.49.0. The complete resolution is in
`test_delivery/bundle/Gemfile.lock`; existing lockfiles are unchanged.
Consumer replay converts only the lane's checkout gem source to the installed archive,
then enables Bundler frozen mode. Application code and guide snippets use that archive.

A preinstalled local browser/driver serves no external application assets or providers.
The existing AI journey uses a task-owned PostgreSQL 17 container on loopback port 55559;
existing database containers are untouched. The task-owned container was removed after acceptance. Workflow acceptance uses Specify CLI 1.0.0
from tag object `1ecccc04a0fd163c889ef034b909d4d3c49dc2b9`, resolving to commit
`bca679051abb80d6cf0cd909f2539a28a10eb7eb`, and repository OpenSpec 1.12.0.
Tool installation occurs in a temporary Python 3.13 environment, outside application bundles.

## Commands

Use the managed Ruby/Node binaries on PATH. Workflow acceptance additionally puts the
temporary Specify environment and repository `node_modules/.bin` on PATH.
Commands print executed subprocess arguments and outcomes; expected negative controls
produce nonzero child commands that the enclosing acceptance requires.

```sh
BUNDLE_GEMFILE=test_delivery/bundle/Gemfile bundle exec rake test:delivery
bundle exec rake test
bundle exec rake test:package
PGPORT=55559 bundle exec rake test:journey
BUNDLE_GEMFILE=gemfiles/ai_rails_8_1.gemfile bundle exec rake test:ai
bundle exec rake test:workflows
bundle exec ruby -Itest test/distribution_integrity_test.rb
bundle exec rubocop --cache false
npm run contracts:validate
ruby script/validate_skills
bundle exec ruby script/validate_examples.rb
ruby script/privacy_check.rb
npm run spec:validate
```

## Results

| Lane | Actual result |
| --- | --- |
| Installed delivery matrix | 2 replays / 360 assertions, no failures or skips |
| Core | 210 tests / 2,295 assertions, no failures or skips |
| Packaged acceptance | 6 tests / 498 assertions, no failures or skips |
| Existing installed AI journey | 2 replays / 227 assertions, no failures or skips |
| Offline AI | 8 tests / 60 assertions, no failures or skips |
| Workflow integration | 3 tests / 39 assertions after restoring Specify |
| Archive contamination and local links | 2 tests / 711 assertions |
| RuboCop | 844 files, no offenses; final new-lane check also clean |
| Contracts | 8 schemas / 73 actual cases; 10 tests / 142 assertions |
| Skills and catalog | 6 development skills, 8 product skills, 12 applications |
| Privacy | Zero findings |
| Strict OpenSpec | 41 items passed before and after archive; 38 synchronized baseline specs passed |

The installed extraction matrix initially passed 350 assertions; the final run adds
exact package-intent assertions and production HTTP/compiled-asset verification, and
uses the sorted frozen-lock conversion. Subsequent guide edits clarify prose only;
executable snippets are unchanged. No new full release-candidate claim is made.

## Behavioral coverage

Both roots first exercise the shell feature, then the namespaced pack. Each healthy
helper invocation runs a four-test/twelve-assertion baseline, three-request-test/ten-assertion
caller phase, and one-browser-test/eight-assertion system phase. Root model and pack request
files both appear in the baseline inventory; the system file remains explicitly selected.
The browser proves real Turbo frame updates, preserved unsaved input, Stimulus connection
and button behavior, correct Rails DOM identifiers and absence of another owner's document.

Loading, development reloading, asset compilation and Packwerk pass independently.
A fresh production process excludes development/test dependencies, rejects loaded Foundry,
serves the login and compiled feature JavaScript, and redirects unauthenticated search.
Exact context namespace/profile/patterns and package enforcement are asserted. Gemfile,
lockfile, schema, model/base/authentication code, shared layout and test harness remain
byte-identical through extraction. Persisted documents and search history retain IDs,
contents, ownership and timestamps.

Seven fault categories are exercised per root: missing routes, absent helper, missing
partial, cross-owner visibility, missing importmap pin, private root-to-pack reference,
and a runner silently omitting an inventoried pack test. Specific failure evidence is
required and restored behavior is verified. Root-declared routes and a native pack route
file with `draw :search` both pass. No accepted debt is regenerated.

All six target/root pairs assess, apply, resolve a customized skill with `keep_local`,
repeat generation and execute the installed helper. Original receipts remain during
pending review; finalized template provenance stays distinct from accepted custom bytes.
Project instructions, unrelated skills, selected workflows, lockfile and accepted debt
remain exact. The synthetic predecessor is a complete current-format eight-skill catalog,
not support for retired catalog migrations.

## Corrections and limits

Initial fixture attempts exposed missing CSRF tokens and a missing executable shebang.
Native token submission and the ordinary Rails binstub corrected these. Local resolution
also selected JSON 3, incompatible with the demonstrated Rails cookie decoding; the new
bundle now fixes JSON to the repository's verified 2.21.2. No existing bundle was altered.
Packwerk requires StringIO to be loaded before its CLI in this combination; the documented
native binstub does so. A negative route control initially expected a routing exception,
but removing routes instead removes named helpers; its expected evidence was corrected.

Core initially rejected a stale installer file-count expectation and an overly broad lint
configuration edit affecting an existing tutorial's canonical snippet. The count now includes
the eight added reference copies; the lint setting is local to the new acceptance lane.
Frozen-lock preparation initially inserted the gem specification inside a dependency entry;
anchoring the specification insertion corrected the contributor fixture. Workflow acceptance
first failed for missing Specify, then restored the pinned temporary tool. The first RuboCop
attempt could not write its default cache under sandboxing; `--cache false` completed the check.

This verifies local reproducibility for the stated combination. It does not establish
independent-user usability, agent improvement, all asset-pipeline compatibility or completion
of Campfire's framework tests. No application provider, agent trial, hosted CI, deployment,
publication or historical evidence rewrite is included. Raw temporary logs are not shipped;
this record omits workstation paths and contains only synthetic application identities.
