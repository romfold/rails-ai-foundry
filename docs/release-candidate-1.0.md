# Foundry 1.0 release-candidate verification

This is the historical September report. See [current local candidate evidence](evidence/2026-10-21/release-candidate/README.md "Repository-only reference; not installed")
and [release preparation](release-preparation.md) for the October artifact and explicitly
skipped hosted CI. Historical hashes and results below are unchanged.

Verification date: 2026-09-10. This report predates the retired-support cleanup; its results apply only to the candidate identified below. Local application acceptance passed for all twelve standalone examples. Hosted Linux CI remains pending; this is not publication approval.

## Candidate and scope

The tested source is commit `71cfd0c4a251553ec70a95b65f1d5f8886d97500`, extracted with `git archive` into a disposable directory. All 117 packaged files matched the built `rails_ai_foundry-1.0.0.gem` byte-for-byte. Its SHA256 is `83c2268d28e748db567dc5ca5d84f6b7f155a3fce7588e4a3a230955ecb5653b`.

Application bundles used the matching source from that archive. They did not install the packaged gem; separate packaged acceptance exercises installation. Subsequent author/license changes (recorded in amended commit `7568cd5`) are outside this application candidate. Rebuild the final artifact and record its new digest after accepting such changes.

## Application acceptance

Environment: macOS arm64, Ruby 3.4.10, Bundler 2.6.9, Node 20.19.0, Docker Compose 2.15.1. Each application used its own frozen bundle and checked-in Compose services. Runs were sequential with independent `foundry-rc-*` project names.

| Application | Tests | Assertions |
|---|---:|---:|
| domain-event-sourced-ledger-rails-event-store | 5 | 21 |
| modular-event-pipeline-kafka-karafka | 5 | 27 |
| modular-graphql-async-dataloader | 5 | 24 |
| modular-legacy-adoption-packwerk | 3 + 3 extracted | 18 + 18 extracted |
| modular-multi-tenant-rag-qdrant | 4 | 24 |
| modular-opensearch-cqrs | 8 | 43 |
| modular-realtime-voice-rabbitmq | 8 | 81 |
| modular-transactional-outbox-postgresql-sidekiq | 5 | 30 |
| rails-native-agent-tools-structured-output-rubyllm | 6 | 29 |
| rails-native-ai-chat-rubyllm-hotwire | 5 | 38 |
| rails-native-nextjs-graphql | 2 | 5 |
| rails-native-rag-pgvector | 6 | 38 |

All reported zero failures, errors and skips. For each owning application, the commands were:

```sh
docker compose --project-name foundry-rc-N up -d --wait
bundle check
bin/setup
bin/verify
bundle exec rubocop
docker compose --project-name foundry-rc-N down -v
```

The adoption application needs no Compose services and additionally ran `npm run spec:validate`. Each `bin/verify` exercised its checked-in behavioral, loading, boundary and selected-workflow checks. Scenario-specific checks include the Kafka retry/restart path, actual Falcon HTTP requests, adoption debt rejection, and the Next.js production build. AI/speech provider calls remained offline.

All Gemfile locks and accepted Packwerk debt files retained their original hashes. Every task-owned Compose cleanup succeeded. Final Docker container and network queries found no `foundry-rc-*` resources. Existing services were left running.

The first harness attempt used `--wait-timeout`, which Compose 2.15.1 does not support. Eleven service-backed applications stopped before setup; the adoption application passed. Removing that harness-only flag and rerunning those eleven applications produced the successful results above. No application source fix was required. A separate Ruby 4 test-fixture correction is described below.

[Machine-readable commands, exit statuses, timings and test summaries](evidence/release-candidate-1.0-applications.json "Repository-only reference; not installed") accompany this report. Full local application logs remain in `/private/tmp/foundry-rc-4kDMet/rc-evidence`; initial failed harness logs are in the sibling `rc-evidence-attempt1` directory. These temporary paths are not durable hosted artifacts.

## Ruby 4 compatibility acceptance

The disposable candidate also passed the local Ruby 4.0.6 / Rails 8.1.3.1 / Bundler 4.0.10 core suite (111 tests, 862 assertions) and provider-blocked AI suite (6 tests, 58 assertions). The declared `gemfiles/ci_core.gemfile` and `gemfiles/ci_ai.gemfile` were resolved separately; the AI lane retained its JSON < 3 constraint. Generated-consumer dependencies were prepared with `script/prepare_acceptance` before offline acceptance. This is macOS evidence for the declared runtime combination, not the hosted Linux lane.

Packaged acceptance initially failed with 4 tests / 195 assertions / 1 failure: an empty Bundler 4 CHECKSUMS entry prevented frozen Packwerk execution. The test-only fix in `test_packaging/archive_helper.rb` configures disposable offline hosts with `BUNDLE_LOCKFILE_CHECKSUMS: false`. It does not alter application setup defaults, existing lockfiles, frozen execution or network guards.

Re-running `bundle _4.0.10_ exec rake test:package` against the amended checkout plus this fixture fix passed **4 tests / 220 assertions**. The managed Ruby 3.4 boundary regression (`bundle _2.6.9_ exec ruby -Itest -Ilib test_packaging/native_boundary_test.rb`) passed **1 test / 72 assertions**. RuboCop passed for the changed helper, and strict OpenSpec validation passed all 25 items. The complete Ruby 4 package retry log is `/private/tmp/foundry-rc-ruby4-package-fixed.log`; the preceding failed run is `/private/tmp/foundry-rc-ruby4-package.log`.

## Remaining release gates

- Run the declared GitHub Actions compatibility, managed, application and advanced-recipe jobs on the final candidate and retain their URLs. This checkout has no Git remote; the repository destination has been requested. GitHub authentication is available.
- Rebuild and verify provenance for any final packaging changes after the tested commit.
- Keep live model/speech/vector-provider evaluations and matched agent/onboarding experiments distinct from offline acceptance. This pass neither ran nor established those results.
- Publish only as a separate release action after the required evidence is reviewed.

The release decision is to retain the candidate for hosted verification. Local success does not establish Linux compatibility or live provider quality. The OpenSpec verification change remains active while hosted CI is outstanding.
