# Evaluation and benchmark evidence

Use this independent development bundle. Nothing here runs in a generated application's production process.

```sh
cd recipes/evidence
bundle _2.6.9_ install
bundle exec ruby test/evaluation_test.rb
bundle exec ruby test/benchmark_test.rb
bundle exec ruby bin/offline
bundle exec ruby bin/benchmark
bundle exec rubocop
```

The offline scorer checks exact answer correctness, citation precision/recall and unsupported citations. bin/offline is a deterministic scorer calibration, not a model-quality evaluation. The RAG, Qdrant and authorized-tool applications provide executable retrieval, tenant isolation, citation and revocation evaluations against application behavior. Keep held-out domain cases, permitted document IDs, reference answers and refusal expectations separate from prompts or tuning data. Add domain-specific semantic judges explicitly; do not replace authorization tests with an LLM judge or treat a completion report as evidence.

## Explicit live evaluation

bin/live is an opt-in RubyLLM/OpenAI recipe using the public synthetic cases.json. It will not run unless FOUNDRY_LIVE_EVAL=1 and all of these inputs are present:

| Variable | Meaning |
| --- | --- |
| EVAL_API_KEY | Provider credential, passed in environment and never written into the report |
| EVAL_MODEL | Explicit model ID; no implicit model selection |
| EVAL_MAX_REQUESTS | Total requests, 1–100 |
| EVAL_MAX_TOKENS | Total reported input plus output tokens, at most 1,000,000 |
| EVAL_MAX_OUTPUT_TOKENS | Per-request completion cap, at most 4096 |
| EVAL_MAX_SECONDS | Whole-run deadline, at most 300 seconds |
| EVAL_MAX_USD | Spend reservation, at most USD 10 |
| EVAL_INPUT_USD_PER_MILLION | Explicit current input pricing |
| EVAL_OUTPUT_USD_PER_MILLION | Explicit current output pricing |

After deliberately supplying these settings, run `bundle exec ruby bin/live`. Use provider-side project quotas as well. No live evaluation is run by CI or normal tests. No credentials or external model request were needed for local milestone verification.

Requests are serial, each chat is fresh, and automatic transport retries are disabled. Prompt bytes plus an overhead allowance and the completion cap reserve tokens before each call. Conservative spend reservations use the supplied rates. The remaining deadline wraps the request, and the same timeout/output cap reaches RubyLLM. Unknown usage, provider errors, malformed answers, exceeded output/total/spend limits or an exhausted next-request reservation stop the run. Actual provider token usage is retained separately from cost estimates; rates, caching, reasoning tokens, provider behavior and already accepted requests can differ from estimates. This is not a guaranteed billing cap. No agent tools or side effects are available to this evaluation chat. Verify model support for max_completion_tokens before using another model family.

## Controlled runtime benchmark

bin/benchmark compares the same Rails persistence behavior using a plain transaction script and the generated native-operation convention. Both have the same implementation author, no agent/model invocation during measurement and workflow none. It checks held-out valid/invalid inputs, warms both paths, alternates order for nine paired trials, and records elapsed time and Ruby allocations for 200 writes per sample. Every measured sample must produce the expected count and sum. The database is isolated in-memory SQLite; no production database is touched.

[Raw results](results/runtime.json) retain conditions, versions, lock digest and samples. They are a narrow persistence/operation microbenchmark, not an HTTP load test, a model-productivity study or a full onboarding comparison. Small timing differences are noise-sensitive; use the distributions and allocation counts rather than a universal speed claim. Foundry has no runtime loader in either subject. For PostgreSQL/high-load claims, rerun matched request/DB workloads with concurrency, pool wait, query counts, p95/p99 latency, memory and GC measurements.

## Separate agent/onboarding protocol

For an agent experiment, freeze the task, hidden behavioral tests, Rails/dependency versions, hardware, initial git tree and network policy. Pair vanilla and Foundry runs with the exact same agent build, model, reasoning settings, token/time limits, selected upstream workflow and prompt. Randomize pair order and use multiple independent repetitions. Record tool logs, total tokens/cost/time, human interventions, held-out failures, final diff and commit IDs; score failures as failures rather than discarding them. Do not supply hidden tests to the implementation agent. First isolate architecture while equalizing workflow setup; measure the complete onboarding experience in a separate cohort with its own setup costs. No agent or onboarding measurements are fabricated here: the checked-in result is the runtime benchmark described above.
