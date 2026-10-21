# Separately labeled Foundry-guided realtime trial

This treatment uses the shipped skills from the gem measured by the preceding
ten-trial study. It does not replace an upstream score. Only this one paid attempt
is enumerated here; every evidence-driven follow-up must be recorded separately
and subtract prior cycle spend from the same authorized $7 total stopping budget.

```sh
export PATH=$HOME/.asdf/installs/ruby/3.4.10/bin:$HOME/.asdf/installs/nodejs/20.19.0/bin:$PATH
export BUNDLE_GEMFILE=$PWD/benchmarks/Gemfile RUBYOPT=-EUTF-8 DOCKER_CONTEXT=desktop-linux
GUIDED=/private/tmp/foundry-realtime-guided-20260922-g1-prepared
CYCLE=/private/tmp/foundry-fix-retest-cycle-20260922
SOURCE=/private/tmp/foundry-openrouter-luna-20260922-r6
```

## Preparation and offline gates

The first preparation-only build used an invalid Docker `FROM sha256:...` reference.
The corrected preparation verified a local tag against the exact pinned image ID.
The failed workspace remains at `/private/tmp/foundry-realtime-guided-20260922-g1`;
it contains no paid attempt. The checked-in preparation helper is the style-normalized
equivalent of the successful helper; its executed-source hash is in authorization.json.
Use a new output path for preparation, controls, replay and reports. Existing outputs
are immutable.

```sh
bundle exec ruby preparation-scripts/prepare_foundry_guided_realtime.rb "$SOURCE" "$GUIDED"
benchmarks/suite isolation "$GUIDED/suite" "$GUIDED/isolation"
benchmarks/suite dependencies "$GUIDED/suite" "$GUIDED/dependencies"
bundle exec ruby preparation-scripts/verify_foundry_guided_inputs.rb "$GUIDED"
bundle exec lemans run --bench "$GUIDED/suite" --task ft-comment-reaction-live-echo --agent oracle --attempts 1 --concurrency 1 --runs-dir "$GUIDED/controls/oracle"
benchmarks/suite replay "$GUIDED/suite" "$GUIDED/controls/oracle" "$GUIDED/control-verification/oracle"
bundle exec lemans run --bench "$GUIDED/suite" --task ft-comment-reaction-live-echo --agent nop --attempts 1 --concurrency 1 --runs-dir "$GUIDED/controls/nop"
benchmarks/suite replay "$GUIDED/suite" "$GUIDED/controls/nop" "$GUIDED/control-verification/nop"
```

Both offline agents make no model requests. Native Le Mans may refresh host model
registry metadata. The reference must pass both graders; the no-op must reach the
browser requirements after a passing application baseline and fail the missing feature.
Its browser `ElementNotFound` errors are retained; they are not claimed as assertion failures.

## Authorized paid attempt

Set OPENROUTER_API_KEY only in the host shell or through the authorized literal-key
loader. The actual invocation used `/private/tmp/foundry-openrouter-env-20260921.rb`
to read the existing literal assignment without sourcing shell configuration. Never
write credentials into this command sheet, arguments, candidate images or evidence.

```sh
bundle exec ruby preparation-scripts/preflight_foundry_guided_realtime.rb "$GUIDED" "$CYCLE" &&
LEMANS_PROVIDER_ORDER=openai bundle exec lemans run --bench "$GUIDED/suite" --task ft-comment-reaction-live-echo --attempts 1 --concurrency 1 --runs-dir "$GUIDED/results"
```

The preflight validates frozen inputs, controls, previous native artifacts, key identity,
allowance, model/provider support and the aggregate budget. It never launches an agent.
The native profile remains ten minutes, 50 steps, 4,096 output tokens, a 60-second shell
timeout and a $0.75 stopping threshold. There are no automatic retries or substitutions.

## Fresh verification and accounting

```sh
benchmarks/suite replay "$GUIDED/suite" "$GUIDED/results" "$GUIDED/verification"
bundle exec ruby preparation-scripts/report_guided_realtime.rb "$GUIDED" "$GUIDED/reports/final"
```

Run the report with the host key available for sanitized provider accounting. A new
report destination is required if a later snapshot is needed to resolve provider lag.
Preserve the original native result even when grading fails or accounting is unavailable.
