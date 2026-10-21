# 0006: Gem-first core workflow

**Status:** Accepted

## Context

Installation and executable packages existed, but RubyLLM and a support desk advanced before the reusable skill catalog and non-AI feature workflow. The user redirected delivery to the working gem and skills, with examples last.

## Decision

Deliver package-owned plain Ruby operations, static dependency/privacy checks, versioned installable Foundry skills, and installed-archive acceptance. Preserve optional AI and example code; defer expansion and leave the unfinished support desk change unarchived.

Keep structural checking unchanged. A separate boundary command uses Packwerk 3.1 and packwerk-extensions 0.3 through an explicit conventional load-path configuration. Packwerk 3.1 retains the Ruby 3.0 floor; the current 3.3 line requires Ruby 3.3. Constrain dependencies and test upgrades rather than adopting a custom Ruby parser or silently raising compatibility floors. Benchmark is an explicit dependency for newer Ruby runtimes.

Derive package inputs from the validated manifest. Do not load consumer Packwerk configuration or boot Rails for checking. Enforce public paths and reject baseline/ignore mechanisms so the command cannot silently accept recorded violations. Existing package metadata remains unchanged until the application enables the new check deliberately.

Canonical product skills live in root `skills/`, ship in the gem, and install into application-local agent directories. They are separate from upstream OpenSpec development workflows. Preserve customized complete installs; upgrades require reconciliation rather than an overwrite switch.

Use a minimal Rails host and an independent local bundle to verify the built archive. This fixture is validation infrastructure, not another example application.

## Consequences

Static checks cover conventional Ruby constant references, not reflection, runtime flows, custom loader configuration, or authorization. The parser can lag newer Ruby syntax; its warnings and parse errors remain visible. Meaningful runtime tests are still required. Templates, broader architecture profiles, adoption, additional AI capabilities, and example completion remain subsequent decisions. Publishing is not part of local gem acceptance.

## Delivery supersession note — 2026-09-08

The delivery deferral for the support desk above is superseded by its verified completion and archive in commit `6acbc19` on 2026-09-08. The adopted core-first direction remains; broader examples require their own changes. The shipped catalog now has seven Foundry skills following guided adoption (commit `60d024e`, 2026-09-06), distinct from the six development OpenSpec workflows. Original decisions and milestone counts above remain historical records.

Optional AI profile alignment and execution tracking were subsequently verified and archived in commits `3f04ac6` and `53fdeac` on 2026-09-06. Those completed changes supersede the earlier expansion deferral for their specific scope.
