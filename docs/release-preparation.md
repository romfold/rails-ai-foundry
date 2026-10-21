# Local release candidate

Foundry is an unpublished `1.0.0` candidate. Identify an artifact by its source commit,
SHA-256 and packaged-resource inventory. A passing local candidate is not a published
version, Git tag, hosted-CI result or live-provider evaluation.

## Install and inspect

Use the supplied archive and checksum from the release evidence. Verify the checksum
before installation, then install locally with the application's existing dependency
constraints. Do not run a broad dependency update to install Foundry. Review any required
lock additions; if an existing version cannot satisfy the requirements, report the conflict.

```sh
shasum -a 256 rails_ai_foundry-1.0.0.gem
gem install --local ./rails_ai_foundry-1.0.0.gem
foundry --version
foundry contracts
```

`--local` requires dependencies already available locally. Follow [setup](setup.md) for
workflow prerequisites and application installation. Put Foundry in development/test;
applications use Rails and upstream libraries in production. Follow [the first feature](first-feature.md)
or [the installed AI journey](first-ai-feature.md), then run application-owned verification.

## Existing installations

The gem update does not rewrite application code or installed guidance. Assess and apply
the [reviewed skill upgrade](skill-upgrades.md), resolve local conflicts explicitly, and
run the installed verification helper with the application's reviewed caller/browser files.
Preserve selected workflows, custom package roots, accepted debt and customizations.
Regenerate old parity evidence after this candidate's input-policy change; see
[audit capture](adoption.md#verified-audit-inputs). Never edit fingerprints to force acceptance.

Rollback reinstalls the previously reviewed gem and uses the skill-upgrade rollback
procedure where applicable. There are no application migrations in this release scope.
Do not discard later local edits or alter business data to roll back development tooling.

## Release decision and limits

The October scope intentionally skips hosted CI and does not tag or publish. Existing
local compatibility evidence is attributable to its exact tested commit and platform;
unchanged example/recipe evidence remains dated rather than being relabeled as a new run.
The current evidence record must distinguish passing checks, failed attempts and retained
evidence. Campfire native-test limitations and unfinished agent studies remain open and
are not proof against the core gem, nor grounds for broader productivity claims.

RubyGems.org is the intended future registry. The repository is
[romfold/rails-ai-foundry](https://github.com/romfold/rails-ai-foundry); gem metadata links
to its source, README, changelog and issue tracker. Those files must be available in the
repository before public distribution. Review the release decision and wait for the user's
explicit readiness before tagging or publication. Local metadata preparation does not push
source, configure hosted CI or upload the gem. The existing open-ended railties floor is
intentional and unchanged.

Contributor evidence is [repository-only](evidence/2026-10-21/release-candidate/README.md "Repository-only reference; not installed").
