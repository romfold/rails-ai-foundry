# Campfire Search extraction: implementation with incomplete behavioral acceptance

Date: 2026-10-10. Continuation of [the original baseline diagnosis](campfire-adoption.md).
The user explicitly authorized extraction while preserving Rails, Minitest, all other existing
dependency versions and the original test harness. No compatibility adapter was introduced.

## Attributable implementation

- Campfire base: `d2155e85a01b8439c32a3604ebb7f39fea1ace0f`.
- Branch: `codex/foundry-search-adoption` in an isolated clone; original checkout unchanged.
- Implementation: `5925c10` — Search extraction, pinned tooling, installed skills, tests and controls.
- Application evidence: `e9b63a2f138f41592e999b0fae5fcbca3b2eb2a4` — limitations and rollback.
- Foundry product: built from `9748edd`, version 1.0.0, SHA-256
  `d40de1afe07536fe78dcc03b838d56ab46d92bdebc767ccebe598f8027e11516`.
- Resulting Campfire Gemfile.lock SHA-256:
  `f831ab48643b42df7de656f6c2776f0d8b824457cd76fc24402f4eba924a607e`.

A Bundler lock-parser comparison of every original `(name, platform)` identity confirms
**153 existing specifications retain their versions and Git revisions**. There are 23 additions.
Rails stays at 8.2.0.alpha / `1a02651ac37fb64b4de2a2b73461d86acf9c98fb`; Minitest stays at
6.0.6. Ruby 3.4.10 and Bundler 4.0.13 were used. New platform-specific dependencies were
verified on arm64-darwin only; other platforms in the old lock are not newly verified.

The Search controller/helper use SearchExperience; their view, JavaScript and delivery tests
live under packs/search. The HTML view and JavaScript are byte-identical moves. Root-owned
models, database/schema, test helpers, boot/application configuration and bin/rails are unchanged.
The three existing Search URLs and named helpers remain; routes select the namespaced controller.

The pack declares its dependency on the root with privacy/dependency enforcement. There is no
reverse dependency, broad public API, accepted-debt file, repository wrapper or execution runtime.
Explicit Rails asset/importmap paths load the pack frontend. Foundry remains development/test
only; packs-rails remains an application dependency. Native OpenSpec 1.12.0 initialized six
development skills alongside the eight installed product skills and their receipt.

## Commands and outcomes

Commands run inside the isolated Campfire root with its dedicated bundle and managed Ruby.
Use disposable test state. Full command output was returned during execution; this record
omits personal execution paths rather than committing raw machine-specific logs.

| Command or probe | Actual outcome |
| --- | --- |
| `bundle _4.0.13_ install --local` after exact cached gem installation | 38 dependencies, 163 installed gems; original locked identities unchanged |
| `bundle exec packs create packs/search --enforce-dependencies --enforce-privacy --no-enforce-layers` | Created upstream package; no debt regeneration performed |
| `bin/rails generate foundry:skills --target=agents` | Installed eight skills and receipt from built gem |
| `bundle exec foundry setup --specs=openspec --agent=codex` | Pinned native initialization succeeded in application scope |
| `bundle exec foundry check --sources --format=json` | One context, rails_native / SearchExperience / none / none; 127 Ruby sources, no diagnostics |
| `RAILS_ENV=test bin/rails zeitwerk:check` | Passed; existing warning that test/test_helpers is not eager loaded |
| Search route/view/asset inspection through Rails runner | GET/POST /searches and DELETE /searches/clear retained; pack view and JavaScript resolved |
| `RAILS_ENV=test bin/rails assets:precompile` | Passed; asset manifest produced |
| Development Rails reloader probe | Controller constant replaced after reload; passed |
| `BUNDLE_WITHOUT=development:test SECRET_KEY_BASE_DUMMY=1 RAILS_ENV=production bin/rails runner ...` | Eager loading succeeds; Search controller resolves; Foundry absent from activated gems |
| `RAILS_ENV=test bin/packwerk validate` and `check` | Passed with no offenses/stale debt |
| `bundle exec ruby script/search_adoption_controls.rb` | Boundary healthy/fault/recovery passes; behavioral preflight fails; overall exit 1, remaining controls blocked |
| `bin/verify-feature` | Discovers root plus pack tests and deferred browser files; exit 1 because planned files did not load |
| `bin/rails test packs/search/test/system/search_experience/search_test.rb` | Exit 0 with **zero tests**, not browser acceptance |
| `bundle exec ruby -Itest packs/search/test/controllers/search_experience/searches_controller_test.rb` | Exit 1 on unchanged test/test_helper.rb requiring minitest/unit |
| RuboCop on 10 affected Ruby files | Passed after fixing array-bracket spacing in the control script |
| `npm run spec:validate` | Application Search contract passes strict validation |
| Staged-content privacy scan and `git diff --check` | Passed |

The private-access control copies versioned/unignored source into a disposable directory,
checks a healthy application, adds a root reference to SearchExperience::SearchesController,
requires a privacy violation and nonzero exit, removes the probe, and checks recovery. Both
privacy and dependency violations appeared. The source branch remains clean afterward.

Behavioral controls deliberately require a healthy baseline before evaluating authorization
bypass or root/pack failure sentinels. They do not credit arbitrary nonzero exits as evidence
when the baseline itself is broken. No authorization/browser/negative behavioral claim is made.

## Failed attempts and corrections

- The offline resolver initially lacked packs-rails. Network resolution then could not find
  the required packwerk-extensions 0.3.x. Exact archives from Foundry's existing local cache
  resolved the bundle without version substitutions. Fresh network-only reproduction is not claimed.
- A local archive-install loop initially inherited Bundler/RDoc environment and attempted to
  locate an unnecessary older Bundler archive. It was corrected to preserve original locked
  names, skip Bundler and install missing dependencies outside the inherited bundle environment.
- Offline npm lacked metadata; pinned online development-tool installation succeeded.
- Packwerk's native executable initially raised an unloaded StringIO constant under Bundler 4.
  An application binstub now explicitly requires standard-library stringio before executing
  Packwerk. No gem source or version was modified.
- Reload probes in the test environment failed because test configuration disables reloading;
  the normal development reloading probe passed. Test configuration remains untouched.
- RuboCop's first invocation lacked permission for its default user cache; a disposable
  RUBOCOP_CACHE_ROOT allowed normal execution.
- The first control script compared UTF-8 tool output under an ASCII locale and failed after
  the expected boundary rejection. Binary-safe comparison fixed the script; healthy/fault/recovery
  was rerun successfully before reaching the separately blocked behavioral preflight.

## Local recovery artifacts

Foundry's ignored `tmp/campfire-adoption/` contains `search-adoption.bundle` and a `gems/`
directory containing the 23 exact new gem archives plus `manifest.json` SHA-256 fingerprints.
These are local handoff artifacts, not committed application copies, catalog entries or gem
resources. The Git bundle was verified and requires the original Campfire base commit.
Bundle SHA-256: `a6a7bb301cefd9177e7382582f6de7e75b069178b9452d253101107d22828edd`.
Gem-manifest SHA-256: `330a5595cbc1786e81480ff513cecfc848930de1e83c88894ea88e768828d928`.

Given a Campfire repository containing that base and an absolute path in `CAMPFIRE_BUNDLE`:

```sh
git bundle verify "$CAMPFIRE_BUNDLE"
git fetch "$CAMPFIRE_BUNDLE" refs/heads/codex/foundry-search-adoption
git switch --create codex/review-campfire-search FETCH_HEAD
```

Install the archived required gems into the intended development bundle before offline resolution.
Existing base dependencies and Git sources are still prerequisites. Restore by reverting the
implementation commit and its application evidence commit; no database reversal is necessary.
Preserve any subsequent skill edits. Do not deploy this as verified behavior.

## Remaining acceptance

HTTP/browser behavior and behavioral fault controls remain blocked by the unchanged test
baseline. The installed helper correctly fails; no skip, alternate test runner, dependency
correction or Minitest adapter was added. The OpenSpec change remains active. No new Foundry
product defect was demonstrated, so no core Ruby or shipped skill/template changed.

Historical release evidence, the twelve-app catalog, hosted-CI gate and agent studies are unchanged.

## Foundry reconciliation checks

- `bundle exec rake test`: 210 tests / 2,269 assertions, no failures, errors or skips. This includes archive-content/contamination/link checks and privacy scanner controls.
- `bundle exec rubocop --cache false`: 838 files, no offenses.
- `ruby script/validate_skills`: six upstream and eight product skills validated.
- `npm run contracts:validate`: 10 tests / 142 assertions; eight schema assets and 73 configuration/report cases pass.
- `npm run spec:validate`: 40 items pass strict validation.
- Changed-content privacy scan: zero findings; `git diff --check` passes.

No Foundry Ruby, skill template, public schema or package inventory changed. Broader AI,
workflow matrix and twelve-app integration lanes were not rerun for the documentation-only
Foundry reconciliation. Native workflow initialization, installed skills and verification were
exercised in Campfire as recorded above. Passing Foundry checks do not close Campfire's two
remaining behavioral-acceptance tasks. The change remains unarchived at 7/9 tasks.
