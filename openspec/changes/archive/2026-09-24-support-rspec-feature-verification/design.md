## Context

See proposal.md. The existing installed helper owns selection, process isolation and Minitest evidence. RSpec is not a core dependency.

## Goals / Non-Goals

Support native RSpec request/system execution without changing Minitest defaults. Do not count expectations, instrument matchers, introduce a generic plugin registry or execute agent trials.

## Decisions

Add --framework=minitest|rspec (default minitest). Keep common path/timeout/process checks; use framework-specific commands and evidence validators. RSpec uses the application's locked bundle and a shipped formatter registered for native lifecycle events. Validate started/completed IDs, types, inclusion file attribution, suite errors and native outcomes. Refuse dry-run and active narrowing filters. Baseline pending IDs use the existing explicit allow-baseline-skip option; selected pending never passes. No expectation count is fabricated.

Test independent Rails 7.1 and 8.1 bundles, real HTTP/browser consumers, all targets, both roots and reviewed upgrades. Only ship new product resources through packaging/files.txt.

## Risks / Trade-offs

Native outcomes cannot establish meaningful assertions or resist malicious application reporting. Preserve explicit limits and fault controls. Framework filters can hide work; reject narrowing rather than silently rewriting settings. Shared examples require including-file provenance rather than only definition locations.

## Migration Plan

Existing helper invocations remain Minitest. Applications opt in explicitly and retain their own test dependencies. Customized installed helpers use reviewed upgrades. Rollback uses existing upgrade restoration.
