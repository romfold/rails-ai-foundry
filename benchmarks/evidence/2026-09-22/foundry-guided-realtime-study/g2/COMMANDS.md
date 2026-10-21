# Fresh retest of shipped realtime guidance

The user authorized evidence-driven fixes and fresh retests within the existing $7
cycle-wide stopping budget. This attempt follows the preserved first guided failure.
Prior cycle spend is $0.16441974. The trial threshold remains $0.75, with no automatic
retry, model substitution or provider substitution. The original ten-trial score is unchanged.

```sh
export PATH=$HOME/.asdf/installs/ruby/3.4.10/bin:$HOME/.asdf/installs/nodejs/20.19.0/bin:$PATH
export BUNDLE_GEMFILE=$PWD/benchmarks/Gemfile RUBYOPT=-EUTF-8 DOCKER_CONTEXT=desktop-linux
GUIDED=/private/tmp/foundry-realtime-guided-20260922-g2
PRIOR=/private/tmp/foundry-realtime-guided-20260922-g1-prepared
SOURCE=/private/tmp/foundry-openrouter-luna-20260922-r6
CYCLE=/private/tmp/foundry-fix-retest-cycle-20260922
```

Prepare only into a new destination. Source snapshots are retained as `.rb.source`
evidence; the original executable helpers remain in the task-owned external workspace.
The updated gem is built from committed revision b545b6d0c483bb63442f5bea40e14e53489e6e2f.

```sh
bundle exec ruby /private/tmp/prepare_guided_retest.rb "$SOURCE" "$GUIDED" /private/tmp/foundry-guided-realtime-b545b6d.json "$PRIOR"
bundle exec ruby /private/tmp/verify_foundry_guided_inputs.rb "$GUIDED"
benchmarks/suite dependencies "$GUIDED/suite" "$GUIDED/dependencies"
benchmarks/suite isolation "$GUIDED/suite" "$GUIDED/isolation"
bundle exec lemans run --bench "$GUIDED/suite" --task ft-comment-reaction-live-echo --agent oracle --attempts 1 --concurrency 1 --runs-dir "$GUIDED/controls/oracle"
bundle exec lemans run --bench "$GUIDED/suite" --task ft-comment-reaction-live-echo --agent nop --attempts 1 --concurrency 1 --runs-dir "$GUIDED/controls/nop"
benchmarks/suite replay "$GUIDED/suite" "$GUIDED/controls/oracle" "$GUIDED/control-verification/oracle"
benchmarks/suite replay "$GUIDED/suite" "$GUIDED/controls/nop" "$GUIDED/control-verification/nop"
```

The paid command runs only after controls and sanitized live accounting pass. The
host key is supplied by the authorized literal-key loader; it is never copied to a
candidate or grader. The native profile is ten minutes, 50 steps, 4,096 output tokens
per response and a 60-second shell timeout, with network-disabled app containers.

```sh
ruby /private/tmp/foundry-openrouter-env-20260921.rb bundle exec ruby /private/tmp/preflight_guided_retest.rb "$GUIDED" "$CYCLE" &&
ruby /private/tmp/foundry-openrouter-env-20260921.rb bundle exec lemans run --bench "$GUIDED/suite" --task ft-comment-reaction-live-echo --attempts 1 --concurrency 1 --runs-dir "$GUIDED/results"
benchmarks/suite replay "$GUIDED/suite" "$GUIDED/results" "$GUIDED/verification"
ruby /private/tmp/foundry-openrouter-env-20260921.rb bundle exec ruby /private/tmp/report_guided_realtime.rb "$GUIDED" "$GUIDED/reports/final"
```

The preflight includes the earlier guided attempt's independently verified cost in
addition to the ten-trial cohort, validates its artifact hash and requires confirmed
accounting. Fresh verification and any later accounting snapshot use new output paths.
