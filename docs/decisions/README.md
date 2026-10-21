# Architecture decision records

Decision records explain why an architectural choice was made. Requirements belong in OpenSpec, and implementation details belong in the relevant change design or code.

| Decision | Status | Subject |
| --- | --- | --- |
| [0001](0001-framework-monorepo.md) | Accepted; initial deferrals resolved | Framework monorepo and spec-driven foundation |
| [0002](0002-architecture-core.md) | Accepted; Ruby floor superseded by 0007 | Architecture core, compatibility, and MIT licensing |
| [0003](0003-executable-packages.md) | Accepted | Package generation and opt-in Rails loading |
| [0004](0004-optional-rubyllm-conventions.md) | Accepted; Ruby floor superseded by 0007 | Optional integration and package-owned prompts |
| [0005](0005-offline-support-desk.md) | Accepted | Offline support desk reference consumer |
| [0006](0006-gem-first-core-workflow.md) | Accepted; delivery deferrals completed | Gem-first core workflow |
| [0007](0007-progressive-package-profiles.md) | Accepted; delivery notes updated | Progressive profiles and Ruby >= 3.3 |
| [0008](0008-setup-and-guided-adoption.md) | Accepted | Setup and guided adoption |

Records 0001–0010 describe the historical foundation. ADR 0011 supersedes their
Foundry-owned runtime, old manifest/profile and mandatory planning choices; current
specifications govern supported behavior. Accepted historical status is not a current
implementation requirement. ADR 0012 extends the application-owned execution direction.

Use sequential filenames and record context, decision, and consequences. An accepted direction is not proof of implementation. Preserve original decisions; dated notes identify superseded portions and the Git evidence establishing the replacement.

- [0009: Read-time event contract upcasting](0009-read-time-event-upcasting.md) — accepted.

- [0010: Optional architecture planning](0010-optional-architecture-planning.md) — accepted.

- [0011: Native conventions cutover](0011-native-conventions-cutover.md) supersedes the 0.1 runtime choices for the 0.2 release. Earlier records remain historical.

- [0012: Application-owned reviewed AI work](0012-application-owned-reviewed-ai-work.md) — accepted; explicit human approval with native Rails durability.

- [0013: Reviewed skill upgrades](0013-reviewed-skill-upgrades.md) — explicit template updates, retained customizations and conditional filesystem recovery.

- [0014: Native verification and data adoption](0014-native-verification-and-data-adoption.md) — explicit framework evidence and application-owned populated-data checkpoints.

- [0015: Package-aware verification](0015-package-aware-verification.md) — opt-in upstream package discovery, independent loaded-file evidence and application-owned commands.

- [0016: Installed delivery extraction](0016-installed-delivery-extraction.md) — staged native delivery moves, explicit asset wiring and separate behavioral evidence.

- [0017: Verified adoption capture](0017-verified-adoption-capture.md) — private input exclusions, consistent debt scope and independent analyses from one verified capture.
