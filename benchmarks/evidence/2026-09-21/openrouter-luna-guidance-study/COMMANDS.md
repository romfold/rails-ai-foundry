# Ordered native commands

Run in the shell holding OPENROUTER_API_KEY. Stop on any preflight failure. Run each block once; no automatic retries.

## 00-hello-world
```sh
benchmarks/suite study-preflight /private/tmp/foundry-openrouter-luna-20260921-r4 hello-world /private/tmp/foundry-openrouter-luna-20260921-r4/preflight-output/00-hello-world &&
LEMANS_PROVIDER_ORDER=openai bundle exec lemans run --bench /private/tmp/foundry-openrouter-luna-20260921-r4/smoke --task hello-world --attempts 1 --concurrency 1 --runs-dir /private/tmp/foundry-openrouter-luna-20260921-r4/results/00-hello-world
benchmarks/suite replay /private/tmp/foundry-openrouter-luna-20260921-r4/smoke /private/tmp/foundry-openrouter-luna-20260921-r4/results/00-hello-world /private/tmp/foundry-openrouter-luna-20260921-r4/verification/00-hello-world
benchmarks/suite study-report /private/tmp/foundry-openrouter-luna-20260921-r4 /private/tmp/foundry-openrouter-luna-20260921-r4/reports/00-hello-world
```

## 01-boundary-extraction-rails
```sh
benchmarks/suite study-preflight /private/tmp/foundry-openrouter-luna-20260921-r4 boundary-extraction-rails /private/tmp/foundry-openrouter-luna-20260921-r4/preflight-output/01-boundary-extraction-rails &&
LEMANS_PROVIDER_ORDER=openai bundle exec lemans run --bench /private/tmp/foundry-openrouter-luna-20260921-r4/foundry --task boundary-extraction-rails --attempts 1 --concurrency 1 --runs-dir /private/tmp/foundry-openrouter-luna-20260921-r4/results/01-boundary-extraction-rails
benchmarks/suite replay /private/tmp/foundry-openrouter-luna-20260921-r4/foundry /private/tmp/foundry-openrouter-luna-20260921-r4/results/01-boundary-extraction-rails /private/tmp/foundry-openrouter-luna-20260921-r4/verification/01-boundary-extraction-rails
benchmarks/suite study-report /private/tmp/foundry-openrouter-luna-20260921-r4 /private/tmp/foundry-openrouter-luna-20260921-r4/reports/01-boundary-extraction-rails
```

## 02-boundary-extraction-packs
```sh
benchmarks/suite study-preflight /private/tmp/foundry-openrouter-luna-20260921-r4 boundary-extraction-packs /private/tmp/foundry-openrouter-luna-20260921-r4/preflight-output/02-boundary-extraction-packs &&
LEMANS_PROVIDER_ORDER=openai bundle exec lemans run --bench /private/tmp/foundry-openrouter-luna-20260921-r4/foundry --task boundary-extraction-packs --attempts 1 --concurrency 1 --runs-dir /private/tmp/foundry-openrouter-luna-20260921-r4/results/02-boundary-extraction-packs
benchmarks/suite replay /private/tmp/foundry-openrouter-luna-20260921-r4/foundry /private/tmp/foundry-openrouter-luna-20260921-r4/results/02-boundary-extraction-packs /private/tmp/foundry-openrouter-luna-20260921-r4/verification/02-boundary-extraction-packs
benchmarks/suite study-report /private/tmp/foundry-openrouter-luna-20260921-r4 /private/tmp/foundry-openrouter-luna-20260921-r4/reports/02-boundary-extraction-packs
```

## 03-boundary-extraction-foundry
```sh
benchmarks/suite study-preflight /private/tmp/foundry-openrouter-luna-20260921-r4 boundary-extraction-foundry /private/tmp/foundry-openrouter-luna-20260921-r4/preflight-output/03-boundary-extraction-foundry &&
LEMANS_PROVIDER_ORDER=openai bundle exec lemans run --bench /private/tmp/foundry-openrouter-luna-20260921-r4/foundry --task boundary-extraction-foundry --attempts 1 --concurrency 1 --runs-dir /private/tmp/foundry-openrouter-luna-20260921-r4/results/03-boundary-extraction-foundry
benchmarks/suite replay /private/tmp/foundry-openrouter-luna-20260921-r4/foundry /private/tmp/foundry-openrouter-luna-20260921-r4/results/03-boundary-extraction-foundry /private/tmp/foundry-openrouter-luna-20260921-r4/verification/03-boundary-extraction-foundry
benchmarks/suite study-report /private/tmp/foundry-openrouter-luna-20260921-r4 /private/tmp/foundry-openrouter-luna-20260921-r4/reports/03-boundary-extraction-foundry
```

## 04-stale-embedding-rails
```sh
benchmarks/suite study-preflight /private/tmp/foundry-openrouter-luna-20260921-r4 stale-embedding-rails /private/tmp/foundry-openrouter-luna-20260921-r4/preflight-output/04-stale-embedding-rails &&
LEMANS_PROVIDER_ORDER=openai bundle exec lemans run --bench /private/tmp/foundry-openrouter-luna-20260921-r4/foundry --task stale-embedding-rails --attempts 1 --concurrency 1 --runs-dir /private/tmp/foundry-openrouter-luna-20260921-r4/results/04-stale-embedding-rails
benchmarks/suite replay /private/tmp/foundry-openrouter-luna-20260921-r4/foundry /private/tmp/foundry-openrouter-luna-20260921-r4/results/04-stale-embedding-rails /private/tmp/foundry-openrouter-luna-20260921-r4/verification/04-stale-embedding-rails
benchmarks/suite study-report /private/tmp/foundry-openrouter-luna-20260921-r4 /private/tmp/foundry-openrouter-luna-20260921-r4/reports/04-stale-embedding-rails
```

## 05-stale-embedding-packs
```sh
benchmarks/suite study-preflight /private/tmp/foundry-openrouter-luna-20260921-r4 stale-embedding-packs /private/tmp/foundry-openrouter-luna-20260921-r4/preflight-output/05-stale-embedding-packs &&
LEMANS_PROVIDER_ORDER=openai bundle exec lemans run --bench /private/tmp/foundry-openrouter-luna-20260921-r4/foundry --task stale-embedding-packs --attempts 1 --concurrency 1 --runs-dir /private/tmp/foundry-openrouter-luna-20260921-r4/results/05-stale-embedding-packs
benchmarks/suite replay /private/tmp/foundry-openrouter-luna-20260921-r4/foundry /private/tmp/foundry-openrouter-luna-20260921-r4/results/05-stale-embedding-packs /private/tmp/foundry-openrouter-luna-20260921-r4/verification/05-stale-embedding-packs
benchmarks/suite study-report /private/tmp/foundry-openrouter-luna-20260921-r4 /private/tmp/foundry-openrouter-luna-20260921-r4/reports/05-stale-embedding-packs
```

## 06-stale-embedding-foundry
```sh
benchmarks/suite study-preflight /private/tmp/foundry-openrouter-luna-20260921-r4 stale-embedding-foundry /private/tmp/foundry-openrouter-luna-20260921-r4/preflight-output/06-stale-embedding-foundry &&
LEMANS_PROVIDER_ORDER=openai bundle exec lemans run --bench /private/tmp/foundry-openrouter-luna-20260921-r4/foundry --task stale-embedding-foundry --attempts 1 --concurrency 1 --runs-dir /private/tmp/foundry-openrouter-luna-20260921-r4/results/06-stale-embedding-foundry
benchmarks/suite replay /private/tmp/foundry-openrouter-luna-20260921-r4/foundry /private/tmp/foundry-openrouter-luna-20260921-r4/results/06-stale-embedding-foundry /private/tmp/foundry-openrouter-luna-20260921-r4/verification/06-stale-embedding-foundry
benchmarks/suite study-report /private/tmp/foundry-openrouter-luna-20260921-r4 /private/tmp/foundry-openrouter-luna-20260921-r4/reports/06-stale-embedding-foundry
```

## 07-ar-tenant-isolation
```sh
benchmarks/suite study-preflight /private/tmp/foundry-openrouter-luna-20260921-r4 ar-tenant-isolation /private/tmp/foundry-openrouter-luna-20260921-r4/preflight-output/07-ar-tenant-isolation &&
LEMANS_PROVIDER_ORDER=openai bundle exec lemans run --bench /private/tmp/foundry-openrouter-luna-20260921-r4/upstream --task ar-tenant-isolation --attempts 1 --concurrency 1 --runs-dir /private/tmp/foundry-openrouter-luna-20260921-r4/results/07-ar-tenant-isolation
benchmarks/suite replay /private/tmp/foundry-openrouter-luna-20260921-r4/upstream /private/tmp/foundry-openrouter-luna-20260921-r4/results/07-ar-tenant-isolation /private/tmp/foundry-openrouter-luna-20260921-r4/verification/07-ar-tenant-isolation
benchmarks/suite study-report /private/tmp/foundry-openrouter-luna-20260921-r4 /private/tmp/foundry-openrouter-luna-20260921-r4/reports/07-ar-tenant-isolation
```

## 08-aj-enqueue-after-commit
```sh
benchmarks/suite study-preflight /private/tmp/foundry-openrouter-luna-20260921-r4 aj-enqueue-after-commit /private/tmp/foundry-openrouter-luna-20260921-r4/preflight-output/08-aj-enqueue-after-commit &&
LEMANS_PROVIDER_ORDER=openai bundle exec lemans run --bench /private/tmp/foundry-openrouter-luna-20260921-r4/upstream --task aj-enqueue-after-commit --attempts 1 --concurrency 1 --runs-dir /private/tmp/foundry-openrouter-luna-20260921-r4/results/08-aj-enqueue-after-commit
benchmarks/suite replay /private/tmp/foundry-openrouter-luna-20260921-r4/upstream /private/tmp/foundry-openrouter-luna-20260921-r4/results/08-aj-enqueue-after-commit /private/tmp/foundry-openrouter-luna-20260921-r4/verification/08-aj-enqueue-after-commit
benchmarks/suite study-report /private/tmp/foundry-openrouter-luna-20260921-r4 /private/tmp/foundry-openrouter-luna-20260921-r4/reports/08-aj-enqueue-after-commit
```

## 09-ft-comment-reaction-live-echo
```sh
benchmarks/suite study-preflight /private/tmp/foundry-openrouter-luna-20260921-r4 ft-comment-reaction-live-echo /private/tmp/foundry-openrouter-luna-20260921-r4/preflight-output/09-ft-comment-reaction-live-echo &&
LEMANS_PROVIDER_ORDER=openai bundle exec lemans run --bench /private/tmp/foundry-openrouter-luna-20260921-r4/upstream --task ft-comment-reaction-live-echo --attempts 1 --concurrency 1 --runs-dir /private/tmp/foundry-openrouter-luna-20260921-r4/results/09-ft-comment-reaction-live-echo
benchmarks/suite replay /private/tmp/foundry-openrouter-luna-20260921-r4/upstream /private/tmp/foundry-openrouter-luna-20260921-r4/results/09-ft-comment-reaction-live-echo /private/tmp/foundry-openrouter-luna-20260921-r4/verification/09-ft-comment-reaction-live-echo
benchmarks/suite study-report /private/tmp/foundry-openrouter-luna-20260921-r4 /private/tmp/foundry-openrouter-luna-20260921-r4/reports/09-ft-comment-reaction-live-echo
```
