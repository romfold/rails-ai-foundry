## Context

The current three lanes and separate AI/event bundles are documented and locally verified. Installed-template acceptance requires standard Rails application dependencies to be available before its network guard activates.

## Goals / Non-Goals

**Goals:** Reproduce the verification commands on pull requests and pushes to main, with exact Ruby/Rails/Bundler targets and visible failures.

**Non-Goals:** Deployment, publication, credentials, remote execution claims, new runtime behavior.

## Decisions

- Use Ubuntu runners, read-only contents permission, ordinary pull_request/push events, and checkout without persisted credentials. No pull_request_target or deployment environment.
- Matrix: Ruby 3.3.10 / Rails 7.1.6 / Bundler 2.5.18; Ruby 3.4.10 / Rails 8.1.3.1 / Bundler 2.6.9; Ruby 4.0.6 / Rails 8.1.3.1 / Bundler 4.0.10. Separate CI Gemfiles pin Rails and retain core/AI/event isolation.
- Dependency preparation installs each bundle and standard Rails application dependencies before acceptance. Tests retain existing provider/network guards. No credentials are supplied.
- The managed lane runs lint, six-development/seven-shipped skill checks, strict OpenSpec with Node 20.19.0, the independently locked support desk, and disposable PostgreSQL 17 tests. Inventory verification will extend this job when that milestone lands.
- The optional AI CI bundle constrains JSON to < 3: local fresh resolution exposed Faraday 2.14.3 passing positional options to JSON 3.0.1, which accepts keyword options. Core/event bundles retain JSON 3 coverage. This is a test-bundle compatibility boundary, not a core runtime dependency.
- CHANGELOG has an Unreleased section and references verified Git milestones; no invented published version/date.

## Risks / Trade-offs

Local macOS execution cannot prove an Ubuntu-hosted GitHub Actions run. Validate workflow syntax and commands locally and explicitly report remote jobs as unexecuted. Dependency resolution is separate from provider-blocked acceptance and transitive versions remain visible in logs.
