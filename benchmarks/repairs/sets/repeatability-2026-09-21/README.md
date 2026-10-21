# Repeatability study candidate repairs

These are human-assisted offline regression fixtures for the stopped study at
`b40528965c0360bd15f2702652f731fa29d1baec`. They do not change its native grades.
`provenance.json` records the frozen task/image identities, original candidate hashes,
repair hashes and reconstructed trees. Incremental and complete patches reconstruct
the same trees, verified in disposable network-disabled containers.

- Boundary extraction: add `enforce_privacy: true` to the existing Knowledge package.
  Preserve the original delivery, sidecar and public API.
- Stale embedding: restore protected `test/visible_test.rb` and relocate its two added
  tests into `test/embedding_regression_test.rb` with a separate class. Preserve the
  original implementation. The relocated tests were executed before trusted grading.

With the original external study available, use the independently bundled verifier:

```sh
export BUNDLE_GEMFILE="$PWD/benchmarks/Gemfile"
bundle exec ruby benchmarks/suite verify "$STUDY/foundry" boundary-extraction-foundry \
  benchmarks/repairs/sets/repeatability-2026-09-21/boundary-extraction-foundry-complete.patch \
  "$NEW_EVIDENCE/boundary"
bundle exec ruby benchmarks/suite verify "$STUDY/foundry" stale-embedding-foundry \
  benchmarks/repairs/sets/repeatability-2026-09-21/stale-embedding-foundry-complete.patch \
  "$NEW_EVIDENCE/embedding"
```

Use a new external evidence directory each time. Verify original patch SHA-256 values
against provenance before applying incremental repairs. The original candidates remain
negative controls: missing privacy must fail architecture acceptance and protected-file
edits must remain invalid even when restored behavioral tests pass. These fixtures are
not part of the realtime-only named repair preparer and are never supplied to agents.
