# Offline repair commands

Run from the Foundry checkout. No credentials or model calls are needed.

```sh
export PATH=$HOME/.asdf/installs/ruby/3.4.10/bin:$HOME/.asdf/installs/nodejs/20.19.0/bin:$PATH
export DOCKER_CONTEXT=desktop-linux RUBYOPT=-EUTF-8
STUDY=/private/tmp/foundry-openrouter-luna-20260921
WORK=/private/tmp/foundry-realtime-repair-20260921
REPAIRS=$WORK/prepared-v4
ruby -EUTF-8 benchmarks/repairs/prepare.rb "$STUDY" "$REPAIRS" realtime-2026-09-21
```

`prepared`, `prepared-v2`, `prepared-v3` and `prepared-v4` are separate immutable input generations;
`input-snapshots.json` preserves their exact task/test contents and hashes. Reproduction
must choose a new output name when these already exist.

The original candidate was reconstructed by the existing verifier from the pinned
image and original task setup, then diagnosed before applying the incremental patch.
The captured original patch is `verification/original/agent.patch`. Its fresh run was:

```sh
ruby benchmarks/suite verify "$STUDY/upstream" ft-comment-reaction-live-echo \
  "$WORK/prepared/original.patch" "$WORK/evidence/original"
```

Final acceptance used separate fresh containers for each call:

```sh
for repetition in 1 2 3; do
  ruby benchmarks/suite verify "$REPAIRS/upstream" ft-comment-reaction-live-echo \
    "$REPAIRS/realtime-complete.patch" "$WORK/evidence/final-v4-$repetition"
done
for variant in composer-replacement wrong-record-deletion guarded-composer-replacement; do
  ruby benchmarks/suite verify "$REPAIRS/upstream" ft-comment-reaction-live-echo \
    "$REPAIRS/$variant-complete.patch" "$WORK/evidence/$variant-v4"
done
```

Missing-delivery and duplicate-echo controls used `prepared-v3` and their unsuffixed
evidence directories. Its only difference from the final verifier is the absence
of the explicit open-composer assertion before reading the field after refresh.
Both already failed explicit unchanged upstream assertions. Their input hashes
remain separately recorded. The three repaired repetitions and guarded alternative
were repeated after adding that assertion.

The four deliberately faulty variants must exit 1 with a successful application
baseline and an assertion failure in the task checks. The guarded alternative must
exit 0. The actual execution used two serial batches alongside independent controls;
these offline results are not latency or throughput comparisons.

Native controls used the existing offline source profile, explicitly overriding the
agent to `oracle` and `nop`. Their model was `offline-controls`, not a provider model:

```sh
BUNDLE_GEMFILE=$PWD/benchmarks/Gemfile bundle exec lemans run \
  --bench "$STUDY/sources/upstream" --task ft-comment-reaction-live-echo \
  --agent oracle --attempts 1 --concurrency 1 --runs-dir "$WORK/controls/oracle"
BUNDLE_GEMFILE=$PWD/benchmarks/Gemfile bundle exec lemans run \
  --bench "$STUDY/sources/upstream" --task ft-comment-reaction-live-echo \
  --agent nop --attempts 1 --concurrency 1 --runs-dir "$WORK/controls/nop"
cp -R "$STUDY/sources/upstream" "$WORK/upstream-controls"
cp "$STUDY/upstream/images.json" "$WORK/upstream-controls/images.json"
ruby benchmarks/suite replay "$WORK/upstream-controls" "$WORK/controls/oracle" "$WORK/controls/oracle-verified"
ruby benchmarks/suite replay "$WORK/upstream-controls" "$WORK/controls/nop" "$WORK/controls/nop-verified"
```

The earlier oracle replay against `sources/upstream` failed because that source-only
workspace had no `images.json`. Its separate `oracle-verification` directory is retained.
The correction adds the pinned image mapping to a new copy, not historical source files.
Replay summaries list the other 41 corpus tasks as missing because only this affected
task was selected; this scope does not claim another complete-corpus run.

Repository checks:

```sh
BUNDLE_GEMFILE=$PWD/benchmarks/Gemfile bundle exec ruby -Ibenchmarks/test_lemans \
  -e 'Dir["benchmarks/test_lemans/**/*_test.rb"].sort.each { |file| require_relative file }'
bundle exec rake test
RUBOCOP_CACHE_ROOT=/private/tmp/foundry-repair-rubocop bundle exec rubocop
ruby script/validate_skills
bundle exec ruby script/validate_examples.rb
npm run contracts:validate
npm run spec:validate
```

Application style was checked inside the repaired diagnostic container using its own
locked bundle and Rails Omakase configuration:

```sh
bundle exec rubocop app/models/reaction.rb app/controllers/cards/comments/reactions_controller.rb
```

The two-argument compatibility check used the completed first study:

```sh
ruby benchmarks/repairs/prepare.rb /private/tmp/foundry-openrouter-luna-20260919-v3 \
  "$WORK/legacy-default-v3"
```

An initial invocation against the incomplete `...20260919` workspace correctly rejected
its missing boundary candidate; no historical evidence was modified.

Patch-tree equivalence used a disposable downloaded baseline/candidate Git checkout
and separate temporary index files (`git read-tree`, `git apply --cached --binary`,
`git write-tree`). The exact Ruby proof program is retained as the `equivalence.rb`
entry in `input-snapshots.json`, alongside the historical integrity checker:

```sh
ruby "$WORK/equivalence.rb" "$WORK/candidate" \
  benchmarks/repairs/sets/realtime-2026-09-21 "$REPAIRS" "$WORK/equivalence.json"
ruby "$WORK/history_check.rb" "$WORK/history-integrity.json"
```

These commands emit tree identities and the unchanged-file count. The recorded
results correspond to the original execution, not a new or changed native grade.
