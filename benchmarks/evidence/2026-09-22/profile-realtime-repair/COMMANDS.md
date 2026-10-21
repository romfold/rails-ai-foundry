# Offline repair reproduction

Use managed Ruby 3.4.10 and Node 20.19.0 from the Foundry checkout. Choose fresh
output paths. No provider credentials or model calls are needed.

```sh
export PATH=$HOME/.asdf/installs/ruby/3.4.10/bin:$HOME/.asdf/installs/nodejs/20.19.0/bin:$PATH
export BUNDLE_GEMFILE=$PWD/benchmarks/Gemfile DOCKER_CONTEXT=desktop-linux RUBYOPT=-EUTF-8
STUDY=/private/tmp/foundry-openrouter-luna-20260922-r5
WORK=/private/tmp/foundry-profile-realtime-repair-20260922
REPAIRS=$WORK/prepared-accepted
bundle exec ruby benchmarks/repairs/prepare.rb "$STUDY" "$REPAIRS" profile-realtime-2026-09-22
bundle exec ruby benchmarks/suite verify "$REPAIRS/foundry" boundary-extraction-foundry "$REPAIRS/boundary-original.patch" "$WORK/evidence/boundary-original"
bundle exec ruby benchmarks/suite verify "$REPAIRS/foundry" boundary-extraction-foundry "$REPAIRS/boundary-complete.patch" "$WORK/evidence/boundary-repaired"
bundle exec ruby benchmarks/suite verify "$REPAIRS/upstream" ft-comment-reaction-live-echo "$REPAIRS/original.patch" "$WORK/evidence/realtime-original"
bundle exec ruby benchmarks/suite verify "$STUDY/upstream" ft-comment-reaction-live-echo "$REPAIRS/schema-only-complete.patch" "$WORK/evidence/schema-only"
for repetition in 1 2 3; do
  bundle exec ruby benchmarks/suite verify "$REPAIRS/upstream" ft-comment-reaction-live-echo "$REPAIRS/realtime-complete.patch" "$WORK/evidence/accepted-$repetition"
done
for variant in callback-collision zero-size-controls composer-replacement guarded-composer-replacement; do
  bundle exec ruby benchmarks/suite verify "$REPAIRS/upstream" ft-comment-reaction-live-echo "$REPAIRS/$variant-complete.patch" "$WORK/evidence/$variant"
done
```

The three faults must fail assertions after a successful application baseline. The
original realtime candidate is expected to stop before baseline reporting. The
schema-only candidate reaches browser checks but cannot use its zero-size buttons.
The guarded replacement is expected to pass. Negative outcomes intentionally exit 1.

The affected upstream reference/no-op controls use the unchanged pinned solution
and an empty patch in fresh independent graders. No native agent run is needed for
this repair; neither execution nor grading infrastructure changed.

```sh
cp -R "$STUDY/sources/upstream" "$WORK/upstream-controls"
cp "$STUDY/upstream/images.json" "$WORK/upstream-controls/images.json"
: > "$WORK/noop.patch"
bundle exec ruby benchmarks/suite verify "$WORK/upstream-controls" ft-comment-reaction-live-echo "$WORK/upstream-controls/tasks/ft-comment-reaction-live-echo/solution.patch" "$WORK/controls/oracle"
bundle exec ruby benchmarks/suite verify "$WORK/upstream-controls" ft-comment-reaction-live-echo "$WORK/noop.patch" "$WORK/controls/nop"
```

Preparation retains the offline profile and network-disabled containers. Replays
use fresh containers with trusted tests mounted read-only and no credentials.

Repository checks:

```sh
bundle exec ruby -Ibenchmarks/test_lemans -e 'Dir["benchmarks/test_lemans/*_test.rb"].sort.each { |path| require_relative path }'
unset BUNDLE_GEMFILE
bundle exec rake test
BUNDLE_VERSION=2.6.9 bundle _2.6.9_ exec rake test:package
BUNDLE_VERSION=2.6.9 bundle _2.6.9_ exec ruby -Itest -Ilib test_packaging/first_feature_test.rb
RUBOCOP_CACHE_ROOT=/private/tmp/foundry-profile-repair-rubocop bundle exec rubocop
ruby script/validate_skills
bundle exec ruby script/validate_examples.rb
npm run contracts:validate
npm run spec:validate
```

Migration diagnosis used `bin/rails db:migrate:primary db:schema:dump:primary` in a
disposable pinned application. Its SQLite schema format and UUID identifiers are
application-specific. Fresh verification independently reconstructs the delivered
schema rather than relying on that database. No MySQL runtime claim is made.
The application style check uses its own locked bundle:

```sh
bundle exec rubocop app/models/reaction.rb app/controllers/cards/reactions_controller.rb db/migrate/20260921000000_create_reactions.rb
```

The report retains earlier schema-only and first repair failures as development
evidence. Input snapshots record their distinct patch/test hashes. Patch equivalence
uses separate temporary Git indices loaded from the sealed baseline, then compares
original-plus-incremental against complete `git write-tree` results.
