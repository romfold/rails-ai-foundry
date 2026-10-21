# Offline repair commands

Run from the Foundry checkout with managed Ruby 3.4.10 and Node 20.19.0.
No provider key, live model, or coding-agent trial is involved.

```sh
export PATH=$HOME/.asdf/installs/ruby/3.4.10/bin:$HOME/.asdf/installs/nodejs/20.19.0/bin:$PATH
export DOCKER_CONTEXT=desktop-linux RUBYOPT=-EUTF-8
export BUNDLE_GEMFILE=$PWD/benchmarks/Gemfile
STUDY=/private/tmp/foundry-openrouter-luna-20260921-r4
WORK=/private/tmp/foundry-guidance-repair-20260921
REPAIRS=$WORK/prepared-scrolled
bundle exec ruby benchmarks/repairs/prepare.rb "$STUDY" "$REPAIRS" realtime-guidance-2026-09-21
```

Choose new output paths when reproducing. Preparation refuses existing output and
validates the study, task, image, original candidate and fixture hashes before output.

```sh
bundle exec ruby benchmarks/suite verify "$STUDY/upstream" ft-comment-reaction-live-echo \
  "$REPAIRS/original.patch" "$WORK/evidence/original"
for repetition in 1 2 3; do
  bundle exec ruby benchmarks/suite verify "$REPAIRS/upstream" ft-comment-reaction-live-echo \
    "$REPAIRS/realtime-complete.patch" "$WORK/evidence/repaired-scrolled-$repetition"
done
for variant in callback-collision malformed-deletion duplicate-echo composer-replacement sender-controls wrong-record-deletion guarded-composer-replacement; do
  bundle exec ruby benchmarks/suite verify "$REPAIRS/upstream" ft-comment-reaction-live-echo \
    "$REPAIRS/$variant-complete.patch" "$WORK/evidence/$variant-final"
done
```

Every call creates a fresh container with no network or credentials, restores trusted
grading files, runs the application baseline and then the task. Faults must exit 1
with an assertion failure after baseline success. Guarded replacement must exit 0.
The actual malformed-form acceptance directory is `malformed-deletion-isolated`;
`malformed-deletion-final` preserves its earlier routing-error control.

The accepted callback fault used `prepared-final-assertions`; the isolated malformed
form used `prepared-control-final`. Those inputs differ only in the malformed-form
patch and its hashes. Repaired repetitions and the remaining controls use
`prepared-scrolled`, which scrolls comments to the viewport center before supplemental
interactions to avoid the application's floating notification control. It does not
change the six upstream tests or application patch. Earlier input generations and
all failed runs are captured separately in `input-snapshots.json` and `verification/`.

The affected native Le Mans controls use the pinned offline source profile:

```sh
cp -R "$STUDY/sources/upstream" "$WORK/upstream-controls"
cp "$STUDY/upstream/images.json" "$WORK/upstream-controls/images.json"
bundle exec lemans run --bench "$WORK/upstream-controls" --task ft-comment-reaction-live-echo \
  --agent oracle --attempts 1 --concurrency 1 --runs-dir "$WORK/controls/oracle"
bundle exec lemans run --bench "$WORK/upstream-controls" --task ft-comment-reaction-live-echo \
  --agent nop --attempts 1 --concurrency 1 --runs-dir "$WORK/controls/nop"
bundle exec ruby benchmarks/suite replay "$WORK/upstream-controls" "$WORK/controls/oracle" "$WORK/controls/oracle-verified"
bundle exec ruby benchmarks/suite replay "$WORK/upstream-controls" "$WORK/controls/oracle" "$WORK/controls/oracle-verified-recheck"
bundle exec ruby benchmarks/suite replay "$WORK/upstream-controls" "$WORK/controls/nop" "$WORK/controls/nop-verified"
```

The offline profile's model label is `offline-controls`; neither control performs
inference. The first oracle replay preserves an intercepted click by the pre-existing
notification overlay. Its separate recheck uses the same native patch and upstream
tests at lower concurrency. The other 41 tasks are intentionally unselected.
Parallel local control execution is not a latency comparison; after observing
contention, remaining verification ran with at most two simultaneous containers.

The causal diagnostic runs only against the original candidate reconstructed by the
existing verifier from its pinned image and task setup, with original tests mounted
at `/tests` and the test database prepared. Its source is in the new fixture set:

```sh
docker exec -i "$DIAGNOSTIC_CONTAINER" ruby -e 'File.binwrite(ARGV.fetch(0), STDIN.read)' \
  /tmp/diagnostics.rb < benchmarks/repairs/sets/realtime-guidance-2026-09-21/diagnostics.rb
docker exec "$DIAGNOSTIC_CONTAINER" ruby -Itest /tmp/diagnostics.rb --include /diagnostic/
```

After repair, application style uses the pinned application's bundle and Omakase rules:

```sh
bundle exec rubocop app/models/reaction.rb app/controllers/cards/comments/reactions_controller.rb
```

Contributor and repository checks:

```sh
bundle exec ruby -Ibenchmarks/test_lemans -e 'Dir["benchmarks/test_lemans/*_test.rb"].sort.each { |path| require_relative path }'
unset BUNDLE_GEMFILE
bundle exec rake test
BUNDLE_VERSION=2.6.9 bundle _2.6.9_ exec rake test:package
BUNDLE_VERSION=2.6.9 bundle _2.6.9_ exec ruby -Itest -Ilib test_packaging/first_feature_test.rb
RUBOCOP_CACHE_ROOT=/private/tmp/foundry-repair-rubocop bundle exec rubocop
ruby script/validate_skills
bundle exec ruby script/validate_examples.rb
npm run contracts:validate
npm run spec:validate
```

The packaged suite includes default/custom roots, shipped skill/reference equality,
customization preservation, workflow `none`, accepted-debt preservation, and deliberately
faulty endpoint controls that must fail even when structural checks pass.

Prior interfaces were also exercised into new output directories:

```sh
ruby -EUTF-8 benchmarks/repairs/prepare.rb /private/tmp/foundry-openrouter-luna-20260919-v3 "$WORK/legacy-default"
ruby -EUTF-8 benchmarks/repairs/prepare.rb /private/tmp/foundry-openrouter-luna-20260921 "$WORK/previous-named" realtime-2026-09-21
```

Patch equivalence uses two temporary Git indices: load the sealed baseline tree,
apply original plus incremental patch to one and the complete patch to the other,
then compare `git write-tree`. The exact helper and historical integrity program
are included in `input-snapshots.json`. They operate on disposable reconstruction
or read-only historical content; they never regrade original studies in place.
