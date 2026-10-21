## Context

See proposal.md. Gem files currently include lib, README, and LICENSE. Existing runtime tests copy a minimal host but resolve Foundry from the repository bundle.

## Goals / Non-Goals

Ship a small self-contained skill catalog and prove installed-archive consumption. No application templates, provider integrations, skill marketplace publishing, or gem publication.

## Decisions

- Canonical product skills live in root `skills/`, separately from upstream `.agents/skills`. Four short skills need no additional resource tree. Package `docs/core-workflow.md` with the gem as the end-to-end guide.
- Install the full catalog using ScaffoldInstaller's exclusive writes and rollback. Targets are explicit known application-relative directories. A receipt records gem version and source digests. Repeat installs preserve edits; new catalog versions require manual reconciliation. Never rewrite AGENTS.md or other skills.
- Add `test:package` separately from the fast core suite. Build from a temporary copy of the gemspec and its file list; install with RubyGems into a temporary home, resolve a fresh host bundle locally, and execute subprocesses with Bundler's inherited checkout settings removed. Assert installed path provenance and archive content before workflow checks.
- Use the repository's minimal host as a Rails boot fixture, with independent Gemfile and explicit package-loading opt-in after installation. This proves Rails consumption without creating another reference application.

## Risks / Trade-offs

- Installed dependencies are prerequisites for offline testing; missing gems cause visible failure rather than network fallback.
- Skill installation is deliberately conservative: partial copies and upgrades require review. Include actionable guidance and preservation tests.
- Skill frontmatter validation does not prove agent behavior; keep guidance short, exercise its commands in the archive workflow, and manually review scope and references.
