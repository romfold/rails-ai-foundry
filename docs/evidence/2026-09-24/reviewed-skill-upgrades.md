# Reviewed skill upgrades: local acceptance

Verified with managed Ruby 3.4.10, Node 20.19.0, macOS arm64 and a disposable
PostgreSQL 17 loopback service. No providers, coding-agent trials, deployment,
publication or hosted CI ran. Historical study outcomes and release gates are unchanged.

## Behavior and recovery

The existing generator now supports explicit assessment, digest-bound apply, recorded
review and conditional rollback. Ordinary generation remains preserving. Current
catalog receipts are template provenance; accepted customized bytes are recorded
separately. Eight skills and three targets remain unchanged.

Unit acceptance covers each classification, all targets, same-version changes, stale
reviews, original modes, added/retired files, unowned additions, unsafe paths, malformed
receipts/decisions, private review files and two successive upgrades. A rollback followed
by a new upgrade receives a fresh review identity without replacing historical evidence.

Process tests exit immediately at explicit synchronization points after destination
persistence, before/after receipt publication, during resolution and during rollback.
They also exercise a separately running writer holding the lock, disk-write failure,
changed modes, a changed immutable plan, an edit during temporary-file persistence and
conditional restoration of manually edited content before its upstream replacement.
Pretend recovery also rejects changed inputs. This is process-crash evidence, not a
claim of filesystem-wide atomicity or resistance to malicious same-user racing processes.

Commands, with managed Ruby on PATH:

```sh
TMPDIR=/private/tmp bundle exec rake test
bundle exec ruby -Itest -e 'ARGV.each { |path| require_relative path }' test/skill_upgrade_test.rb test/skill_upgrade_recovery_test.rb test/skill_upgrade_edges_test.rb
BUNDLE_GEMFILE=gemfiles/rails_7_1.gemfile bundle exec ruby -Itest -e 'ARGV.each { |path| require_relative path }' test/skill_installer_test.rb test/skill_upgrade_test.rb test/skill_upgrade_recovery_test.rb test/skill_upgrade_edges_test.rb
TMPDIR=/private/tmp bundle exec rake test:package
TMPDIR=/private/tmp BUNDLE_GEMFILE=gemfiles/ai_rails_8_1.gemfile bundle exec rake test:ai
TMPDIR=/private/tmp bundle exec rake test:workflows
TMPDIR=/private/tmp PGPORT=55544 BUNDLE_VERSION=2.6.9 bundle exec rake test:journey
bundle exec rubocop
npm run contracts:validate
ruby script/validate_skills
ruby script/validate_examples.rb
ruby script/privacy_check.rb
npm run spec:validate
```

Workflow acceptance additionally selected the disposable pinned Specify 1.0.0 environment
and repository-local OpenSpec 1.12.0 on PATH. Provider traffic remained disabled.

## Installed consumers

The existing installed tutorial replay constructs independent applications using shipped
snippets, then invokes the installed Rails generator in `packs/` and `components/`
consumers. Prior-catalog fixtures deliberately alter template bytes and their matching
receipt hashes; they are synthetic current-catalog fixtures, not claimed historical releases.
The tests subsequently customize instructions while leaving the old executable helper
unchanged, requiring a safe script update and an explicit keep-local decision.

Acceptance exercises assessment, pretend, pending status, blocked ordinary generation,
resolution, preserving repeat, exact rollback and a fresh upgrade. Selected workflows,
accepted debt, project instructions, unrelated skills and customized guidance remain.
Both consumers execute the upgraded helper through HTTP and a real Chrome browser.
Each valid helper phase executes one test / two assertions. A broken HTTP controller
is rejected as a command failure; a disabled browser interaction is rejected by an
assertion failure. These are intended controls, not passing application behavior.
The underlying reviewed-ticket behavior, real queue/process recovery, Rails loading,
Packwerk, prompt/source checks, RuboCop and native production loading are replayed too.

## Corrections and limits

Early unit runs caught an assessment-label mismatch and two test-double/helper-namespace
errors; these were corrected. The first full installed replay failed its final catalog
count because it included the deliberately preserved unrelated skill. The assertion now
counts only `foundry-*`; the extra skill remains preserved. Subsequent recovery review
added coverage for a manually edited pre-replacement state and stale pretend recovery.
Final ownership review corrected historical-plan inspection so an explicitly kept retired
file really becomes unmanaged for later generation; rollback still checks it before writing.
RuboCop complexity findings were resolved by extracting focused helpers, without relaxing
repository rules. Expected negative-control failures remain visible in command output.

New private backup roots include Git ignore rules, but forced additions or other sharing
mechanisms can expose application guidance. Journals are retained locally; automatic
cleanup is not implemented. The upgraded helper still requires meaningful tests and
application-owned CI enforcement. Reproducible upgrades do not establish skill efficacy.

## Recorded results

- Full core suite: 196 tests / 2,120 assertions, all passed.
- Final focused installer/upgrade suite after the unmanaged-file correction: 40 / 363, all passed.
- Rails 7.1 installer plus upgrade lane, including that assertion: 39 / 360, all passed.
- Packaged acceptance: 6 / 486; optional AI: 8 / 60; real workflow integrations: 3 / 39.
- Installed journey with both roots: 2 / 227 in 225 seconds, all passed.
- Archive contamination and installed-link controls: 2 / 649, all passed.
- Contracts: 10 / 142 plus eight schemas / 73 configuration/report cases.
- Six development skills, eight product skills and twelve catalog applications validated.
- RuboCop: 782 files, no offenses. Privacy scan: zero findings.

The original installed replay (2 / 209 with one catalog-count assertion failure) is
not counted as passing; the complete replay above supersedes that test-fixture result.
No benchmark grades or historical study hashes were modified.

Strict OpenSpec validation passed all 36 items after archive reconciliation. The archived delta requirements match the current baselines.
