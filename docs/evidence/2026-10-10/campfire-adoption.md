# Campfire adoption prerequisite evidence

Date: 2026-10-10. Status: **incomplete; baseline test prerequisite requires a scope decision**.

No application extraction or Foundry installation into Campfire is claimed. No hosted CI, agent trial, deployment or publication ran.

## Inputs

- Foundry source: `9748edd` (product code unchanged).
- Campfire base and current adoption branch: `d2155e85a01b8439c32a3604ebb7f39fea1ace0f`.
- Isolated local branch: `codex/foundry-search-adoption`; original Campfire checkout untouched.
- Ruby: 3.4.10. Bundler: 4.0.13, matching the application lock.
- Rails: 8.2.0.alpha at `1a02651ac37fb64b4de2a2b73461d86acf9c98fb`.
- Minitest: 6.0.6, as locked by Campfire before adoption.
- Unchanged Campfire lock SHA-256: `c2e23ce4171d0611fa35b8c360b7d409b8d5727cd58bfeb849a0b4a7e72ec976`.
- Built Foundry 1.0.0 gem SHA-256: `d40de1afe07536fe78dcc03b838d56ab46d92bdebc767ccebe598f8027e11516`.

The clone contains committed source only, not the original application's local databases or secrets. SQLite preparation and assets were written only in the disposable clone. Dependency installation used disposable tool/bundle directories. Network access was used for pinned Git sources and locked Ruby gems, not providers.

## Commands and actual outcomes

Run in the isolated Campfire checkout with managed Ruby, the isolated Bundler executable, `GEM_HOME` pointing to its tool directory, `BUNDLE_PATH` pointing to its bundle directory, and `BUNDLE_FROZEN=true`. Those directory locations are local execution details, not required workstation paths.

| Command | Outcome |
| --- | --- |
| `bundle check` before preparation | Missing dependencies |
| `gem install bundler -v 4.0.13 --no-document` | Installed into isolated tools |
| `bundle _4.0.13_ install` | 36 dependencies, 140 gems; existing lock unchanged |
| `RAILS_ENV=test bundle _4.0.13_ exec rails db:prepare` | Exit 0 |
| `PARALLEL_WORKERS=1 bundle _4.0.13_ exec rails test` | Exit 0, **0 tests / 0 assertions**; not accepted |
| `PARALLEL_WORKERS=1 bundle _4.0.13_ exec ruby bin/rails test test/controllers/searches_controller_test.rb test/models/message/searchable_test.rb` | Exit 0, **0 tests / 0 assertions**; not accepted |
| `PARALLEL_WORKERS=1 bundle _4.0.13_ exec rails test:system` | Exit 0, **0 tests / 0 assertions**; browser never exercised |
| `RAILS_ENV=test bundle _4.0.13_ exec rails zeitwerk:check assets:precompile` | Exit 0; asset manifest produced. Zeitwerk warns that test/test_helpers is not eager loaded |
| `bundle _4.0.13_ exec ruby -Itest test/controllers/searches_controller_test.rb` | Exit 1: cannot load `minitest/unit` from test/test_helper.rb:5 |
| `git diff --exit-code d2155e85a01b8439c32a3604ebb7f39fea1ace0f` | Exit 0 after checks |

The first sandboxed dependency fetch could not resolve GitHub. Retrying with authorized network access completed the unchanged bundle. This infrastructure retry is distinct from the baseline test incompatibility.

## Diagnostic reproduction

The installed Minitest 6 source does not automatically discover plugins in `Minitest.run`. The pinned Rails runner expects the Rails plugin to load selected tests. Explicitly registering that plugin reaches a separate application test-helper failure:

```sh
RAILS_ENV=test bundle _4.0.13_ exec ruby -rminitest -e \
  'Minitest.load :rails; ARGV.replace(["test", "test/controllers/searches_controller_test.rb"]); load "bin/rails"'
```

Result: exit 1, `LoadError: cannot load such file -- minitest/unit` at `test/test_helper.rb:5`. The diagnostic changes no files. It proves a pre-existing failure; it does not establish that these are the only Minitest 6 incompatibilities.

## Remaining acceptance and recovery

Baseline behavior, installed Foundry/upstream dependency compatibility, extraction, production independence, browser acceptance and faulty controls remain unverified. Do not treat passing boot/assets or zero-test commands as acceptance.

The pending scope decision is whether to repair the application test harness while retaining locked versions, authorize a minimal test dependency correction, or leave adoption blocked. No substitute runner, dependency downgrade or compatibility shim has been installed.

The isolated branch still matches the base revision, so no application rollback is necessary. The original checkout is unchanged. Retain the OpenSpec change as active; do not archive or advance release evidence on these results.

## Foundry record verification

- `npm run spec:validate`: 40 items passed, zero failed; existing informational length notices remain.
- `ruby script/validate_skills`: six upstream development skills and eight product skills validated.
- `npm run contracts:validate`: 10 tests / 142 assertions passed; eight schemas and 73 configuration/report cases validated.
- `git diff --check`: passed.
- Changed-content scan using `PrivacyCheck.findings`: zero findings across the new change artifacts and this evidence file. Untracked historical research was not modified.

These checks validate the planning/evidence record and existing contracts, not Campfire behavior. No Foundry Ruby implementation or distributed resource changed, so broader implementation acceptance remains pending rather than being represented as rerun.
