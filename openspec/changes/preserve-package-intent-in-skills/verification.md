# Product guidance verification — 2026-09-22

The shipped package reference now resolves context intent before sidecar creation and compares the discovered values with that selection afterward. The existing package/adoption entrypoints route to that decision. The optional generator example uses application defaults unless explicitly overridden. No submitted candidate, historical grade, benchmark task or grader changed.

## Observed cause

The September 22 paid study at `benchmarks/evidence/2026-09-22/openrouter-luna-realtime-guidance-study` records a boundary candidate with patch SHA-256 `58f0e44c60d33a64946406bdc1733fd3e6eeacf49bd12017fddb3cbba6b8cd92`. Its trajectory reads root defaults and the package reference, copies the reference's `rails_native` example despite the explicit `modular` requirement, then reads the report without reconciling that discrepancy. This supports fixing the manual guidance. It does not establish a generator defect: core coverage verifies application defaults and explicit overrides with independent patterns.

## Commands and results

Managed Ruby 3.4.10 and Node 20.19.0; built-gem acceptance uses local dependencies and blocks external requests.

| Command | Result |
| --- | --- |
| `bundle exec rake test` | 147 tests, 1,135 assertions, no failures/errors/skips |
| `bundle exec ruby -Itest test_packaging/first_feature_test.rb` | 2 tests, 226 assertions; default/custom roots, installed catalog bytes, customized skills, workflow and debt preservation |
| `bundle exec ruby -Itest test_packaging/native_workflow_test.rb` | 1 test, 71 assertions; installed native generation, loading and assessment |
| `RUBOCOP_CACHE_ROOT=/private/tmp/foundry-rubocop-cache bundle exec rubocop` | 714 files, no offenses |
| `ruby script/validate_skills` | 6 development skills and 8 product skills validated |
| `ruby script/validate_examples.rb` | 12 examples validated |
| `npm run contracts:validate` | 10 tests, 142 assertions; 8 schemas and 73 cases |
| `npm run spec:validate` | 32 items passed |

The initial RuboCop command could not write its default cache under the sandbox; the temporary-cache rerun passed. An initial catalog invocation omitted the `.rb` suffix and failed before execution; the correct command passed. Tutorial output retains the pre-existing Packwerk 3.1.0 `StringIO` subprocess warning during upstream dependency editing; subsequent explicit Foundry boundary checks preload StringIO and pass. Intentional privacy and faulty-delivery controls fail as expected before the overall acceptance passes.

## Measurement boundary

The user authorized a $7 total stopping budget for the fresh cohort and evidence-driven fixes/retests. Ten serial attempts at the committed product revision are complete: nine native passes and one failure, with nine independent passes and one infrastructure error. All six Foundry comparison cells pass. The remaining upstream candidate discarded its generated schema; fresh grading stopped on a pending migration before browser execution.

The [separate paid report](../../../benchmarks/evidence/2026-09-22/openrouter-luna-package-intent-study/REPORT.md) records every outcome, exact inputs, commands, raw patches and provider-confirmed cost of $0.13146371. All 2,189 prior evidence/repair files remain unchanged. No candidate was repaired and no attempt was retried. The revised package reference was read by the successful Foundry boundary agent, which selected the required modular profile.

The ten-trial matrix contains only two Foundry-treated cells; unchanged upstream tasks do not load this gem or its skills. Their outcomes measure the agent on that upstream task, not the effect of this product fix. The user subsequently selected a separately labeled Foundry-guided realtime treatment within the already authorized cycle budget. Its result does not replace the original cohort score. The active change remains unarchived until the remaining measurement task is resolved.

After adding the paid evidence, `npm run spec:validate` passed all 32 items. Artifact/history validation passed for 192 copied files and all 2,189 historical files, report links resolved, and `git diff --check` passed. No additional executable code changed during this evidence addition; the core and packaged checks above apply to the measured product revision.

## First guided attempt and shipped follow-up

The first skills-only realtime treatment at `/private/tmp/foundry-realtime-guided-20260922-g1-prepared` uses the same measured gem, all eight installed skills, unchanged dependencies and unchanged upstream task files. Image inventory verifies 1,763 original application files unchanged; AGENTS.md is appended and 90 treatment files are added. Native and fresh oracle controls pass all six browser checks; no-op controls pass the baseline then fail the missing interactive requirements. Both isolation probes pass.

Paid attempt `ft-comment-reaction-live-echo__uCGty1B` costs $0.03295603, confirmed by provider accounting. Cumulative cycle spend is $0.16441974. Both graders record the same four browser passes and two errors, with passing 1,517-test / 5,708-assertion baselines and two pinned Vips skips. The original candidate patch is unchanged, SHA-256 `eca488fea2fddb865f75c599971437e6007b0c428d2cebd76cb8a51624eac985`.

The trace reads both skill entrypoints but omits their linked realtime reference and supplies no browser test for the new behavior. The follow-up moves essential actor/viewer browser evidence into those entrypoints and clarifies nested ownership visibility and parent update paths in the shared reference. It introduces no candidate answer, runtime, CLI change or evaluator change. Installed-gem acceptance for default/custom roots passes again: 2 tests / 226 assertions, preserving customized guidance, workflow selection and debt. Six development and eight product skills validate; strict OpenSpec validation passes all 32 items. The new guidance awaits a fresh paid retest with its own frozen gem and preserved prior spend.

Before freezing this follow-up, `bundle exec rake test` passes 147 tests / 1,137 assertions, full RuboCop passes for 714 files, and `npm run contracts:validate` passes 10 tests / 142 assertions with eight schemas and 73 cases. Packaged acceptance retains the intentional private-access and faulty-endpoint negative controls and pre-existing parser/Packwerk warnings. A mistaken read-only lookup for a repository-local skill-creator file failed; the actual system skill was then read from its installed location.

## Second guided attempt and unresolved acceptance

The fresh treatment at `/private/tmp/foundry-realtime-guided-20260922-g2` freezes product commit `b545b6d0c483bb63442f5bea40e14e53489e6e2f`, gem SHA-256 `1c7b603ffef3ac7f66582eb78904311339ddf8ec4026ad1eab6220074443d643` and image `sha256:accbff1f937b059e304a585f7f2019871891a2909ad4f4efb1039441428a3fdd`. Native/fresh oracle and no-op controls, isolation probes, unchanged application/dependency inventories and five mocked preflight cases pass. The generic agent entrypoint and upstream requirements remain byte-identical to the first treatment.

Paid attempt `ft-comment-reaction-live-echo__lRdYefy` fails in both graders: the 1,517-test baseline reports 5,685 assertions, nine errors and two pinned Vips skips. Browser grading does not run. At step 5 the agent receives both revised skills in full. At step 17 an attempted duplicate-association cleanup removes both copies; five existing model tests then pass without exercising the new caller. No browser verification or behavioral-reference read occurs. The submitted patch reconstructs with SHA-256 `7bcf6d4b1d5f96e446d41a0b8f98a0074f453629ddf360bbee36d9a087923cfd`; its missing association breaks existing endpoint rendering. There are no protocol violations or grader disagreement.

The [separate guided report](../../../benchmarks/evidence/2026-09-22/foundry-guided-realtime-study/REPORT.md) preserves both paid failures, offline controls, exact inputs, original trajectories and independent outcomes. The second attempt costs $0.03315418. Provider-confirmed aggregate spend is $0.19757392, leaving $6.80242608 of the existing $7 stopping budget. No third attempt or candidate repair ran. The original cohort remains nine native passes and one failure.

Correct installation and delivery of the revised instructions are demonstrated; agent compliance and successful feature delivery are not. This evidence does not support another specific library defect or a guaranteed fix through further instruction edits. Task 2.3 remains open and the change is not archived. Future work must establish a justified intervention before further paid execution; the reported result is not replaced by repeated sampling.

Final contributor tests pass 77 tests / 621 assertions with no failures/errors/skips; strict OpenSpec validation passes all 32 items. The report-link check rejected an incorrect G2 browser-log link (that phase never ran), which was corrected to its baseline log. Product source is unchanged since the tested and measured commit.

The full evidence commit whitespace check reports trailing spaces in byte-preserved patch context and Selenium logs (exit 2). Those original artifacts are not normalized. Authored documentation and source snapshots are checked separately; native/derived artifact hashes remain unchanged.

## Executable verification support

The existing verification skill now ships a Rails/Minitest helper, structured reporter
and local usage reference. It runs the existing baseline and explicit HTTP/system
test selections in separate processes. Failed commands, missing reports, empty or
wrong-type selections, assertion-free selected tests, unreviewed skips and timeouts
reject completion. Reviewed baseline skips remain visible. It uses ordinary Rails
test execution and installs through existing receipts; no Foundry runtime, CLI command,
schema key, dependency or ninth skill was added.

The feature/verification entrypoints direct users to wire the invocation into required
application CI. The helper cannot force agent compliance or prove semantic completeness
of assertions, and is not an adversarial sandbox. These limits are explicit in the
installed reference. Non-HTTP/RSpec work keeps its equivalent native verification.

### Offline commands and outcomes

Host commands use managed Ruby 3.4.10 and Node 20.19.0. Normal tests use local
dependencies; no agent or application-provider request ran for this intervention.

| Command | Result |
| --- | --- |
| `bundle exec rake test` | 166 tests, 1,247 assertions, no failures/errors/skips |
| `bundle exec ruby -Itest test/skill_verification_test.rb` | 18 tests, 107 assertions; includes empty/skipped/forged-output/missing-report/wrong-type/timeout controls, shared methods and custom paths |
| `bundle exec ruby -Itest test/skill_installer_test.rb` | 12 tests, 203 assertions; new resources, customized helper preservation and explicit reconciliation of old catalogs |
| `bundle exec ruby -Itest test_packaging/first_feature_test.rb` | Final rerun: 2 tests, 252 assertions; built gem, Rails 8.1.3.1, default/custom roots, exact installed script bytes, preserved customized guidance/workflow/debt and rejected faulty views |
| `BUNDLE_GEMFILE=gemfiles/rails_7_1.gemfile bundle exec ruby -Itest test_packaging/first_feature_test.rb --name test_installed_tutorial_with_default_roots` | Pass on Rails 7.1.6; valid HTTP verification does not require optional browser dependencies |
| `RUBOCOP_CACHE_ROOT=/private/tmp/foundry-rubocop-cache bundle exec rubocop` | 723 files, no offenses; final targeted rerun passes for all 12 changed Ruby files |
| `BUNDLE_GEMFILE=benchmarks/Gemfile RUBYOPT=-EUTF-8 bundle exec ruby -e 'Dir["benchmarks/test_lemans/*_test.rb"].sort.each { \|file\| require_relative file }'` | 77 tests, 621 assertions, no failures/errors/skips |
| `npm run contracts:validate` | 10 tests, 142 assertions; eight schemas and 73 cases |
| `ruby script/validate_skills` | Six development skills and eight product skills |
| `ruby script/validate_examples.rb` | All twelve catalog applications |
| `npm run spec:validate` | All 32 items pass |

The final `./` prefix on selected test arguments prevents their interpretation as CLI
switches. The helper unit suite, installed-gem acceptance and real browser controls
were rerun after this change. The later Rails 7 negative-control assertion adjustment
accepts either the rendered HTTP 500 or the exception detail; both reject the actual
broken caller, rather than requiring version-specific exception presentation.

### Fresh browser execution

```sh
DOCKER_CONTEXT=desktop-linux ruby script/verify_skill_browser.rb sha256:7a68abbb405addbea91cc7c9ea75c802b63e2603e2f25f51c3c03f92e64b85a0
```

All three controls run in separate fresh containers with network disabled, no
credentials passed, capabilities dropped and only generic fixture/helper mounts.
The prepared pinned Fizzy image contains Ruby 3.4.8, Rails 8.2.0.alpha, Minitest 6.0.6
and Chromium/ChromeDriver 153.0.8010.47. It contains no repaired paid candidate.

| Control | Observed outcome |
| --- | --- |
| Valid HTTP and JavaScript interaction | Exit 0; baseline and caller each execute one test/three assertions; browser executes one test/two assertions |
| Missing application method in endpoint | Exit 1; HTTP baseline loads and reports one error; helper rejects completion |
| Missing JavaScript action | Exit 1; baseline/caller pass, then browser reports one behavioral assertion failure with zero errors |

The controls are now a required step of the checked-in `fizzy-feature-1` offline CI
job, using explicit Bash pipeline failure propagation and uploaded logs. Read-only
configuration loading confirms this shard's nine tasks resolve to the tested Fizzy
image. Hosted execution still awaits a repository destination.

### Defects found during implementation

Initial helper fixtures pointed Bundler at an installed gem directory without a
gemspec; fourteen tests failed before verification. Pinning the locally installed
Minitest version repaired that test setup. Initial packaged HTTP acceptance exposed
an unintended Rails autoload of SystemTestCase/Capybara during test classification;
the reporter now inspects existing ancestor names and a regression test covers it.
The first real-browser invocation used `test:system PATH`, which also selected the
whole system suite; explicit `test PATH` selects just the requested files and passes
the controls. Selenium's initial offline metadata warnings were retained; the final
controls explicitly set its offline mode and disable statistics.

Rails 7 acceptance initially lacked locked Active Record dependencies. The command
`BUNDLE_GEMFILE=gemfiles/rails_7_1.gemfile BUNDLE_FROZEN=true bundle install` installed
them without changing lockfiles. A subsequent test-only mismatch expected exception
text where Rails returned HTTP 500; the repaired expectation passes. Existing parser,
Packwerk StringIO and Rails 7 cache-format warnings remain visible. Read-only lookups
of nonexistent singular `shard.rb` and aggregate `benchmark_suite.rb` paths failed;
the actual files were then inspected. CI review moved browser controls away from the
shard containing the separate i18n image and made pipeline failure propagation explicit.

Git blob verification confirms all 2,493 tracked historical evidence/repair files
remain byte-identical to the prior commit. No benchmark candidate, upstream
requirement, grading asset, historical grade or provider accounting changed. The
original cohort remains nine native passes and one failure; both guided attempts
remain failed. Cycle spend remains $0.19757392. The executable helper has offline
acceptance; its effect on a new paid trial is unmeasured, and task 2.3 remains open.
