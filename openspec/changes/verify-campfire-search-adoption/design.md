## Context

See proposal.md. Campfire pins Rails 8.2.0.alpha at 1a02651ac37fb64b4de2a2b73461d86acf9c98fb and Bundler 4.0.13. Its Search model is recent-search history; Message::Searchable owns SQLite FTS callbacks and efficient pagination. User owns visibility and history lifecycle.

## Goals / Non-Goals

Verify an independently useful delivery extraction and installed guidance. Do not move User/Message/history persistence, convert data, extract another context, or claim complete search-domain isolation. Do not change upstream locked versions to obtain a passing baseline.

## Decisions

- Use an isolated local clone and codex/foundry-search-adoption branch. Keep the source checkout untouched and preserve a portable branch artifact with evidence before completion.
- Install a built Foundry gem in development/test; packs-rails remains available in production. Record exact dependency resolution, including any compatibility failure.
- Preserve every existing locked version and Git revision. Only necessary new dependency entries are allowed. Do not repair the test harness or introduce a Minitest adapter. The user explicitly authorized extraction with the pre-existing test failures retained as incomplete acceptance.
- Configure packs/search, SearchExperience namespace, rails_native profile and independent events/CQRS none. Move controller/helper/view, search-specific JavaScript and delivery tests; leave shared presentation in the shell.
- Declare only the new pack's dependency on the root. Rails routes dispatch into the pack without a root Ruby dependency on private feature constants. Enable pack privacy/dependency enforcement; document transitional root ownership.
- Preserve HTTP route names and frontend identifiers. Explicit importmap/asset paths connect pack JavaScript through Rails, without a custom loader.
- Use application-local OpenSpec and agents skills, preserving any existing instructions. The installed verification helper combines root/pack baselines and explicit HTTP/browser acceptance.
- Keep compatibility and behavioral evidence separate from Packwerk results and productivity claims. Record baseline failures independently; no blanket debt regeneration.

## Risks / Trade-offs

- Edge Rails or locked dependencies may be unavailable/incompatible: record conflicts without updating existing versions. The known zero-test/minitest-unit baseline failure does not block code extraction, but does block verified completion and archive.
- Root-owned AR objects remain coupled: this is an incremental delivery boundary, with no reverse package dependency or mandatory repository wrappers.
- Browser/system setup needs services: use disposable test state, loopback services and deterministic local fixtures; no real providers or production credentials.

## Migration Plan

Baseline -> installed tooling -> delivery extraction -> behavior/boundary controls -> recorded evidence. No schema changes. Rollback reverts the adoption commits and restores the prior bundle/configuration without deleting databases or application content. Preserve original and final revisions, gem/lock hashes and portable local branch recovery instructions.

## Authorized browser review — 2026-10-14

Compare base d2155e8 and extracted e9b63a2 using independent disposable archives, SQLite databases, loopback services and browser sessions. Seed synthetic data through ordinary models, retaining indexing callbacks. Keep all dependency versions, lockfiles, authentication, CSRF and the test harness unchanged. No additional application dependencies are installed.

Review real navigation and authenticated HTTP for query normalization, latest-100 ordering, per-user history, inaccessible rooms, revoked membership and create/edit/delete indexing. Record expected identities as well as visible rendering. Test a deliberate visibility bypass only in a third disposable copy. Agreement alone is not evidence of secure behavior.

Attribute failures to extraction, baseline or environment. Fix only demonstrated extraction regressions. Browser evidence remains separate from installed-helper acceptance and omitted-coverage controls; the original automated tasks stay open and the change remains unarchived. Preserve sanitized commands/results and synthetic screenshots; never publish cookies, credentials or workstation paths.
