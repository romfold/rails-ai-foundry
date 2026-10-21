## Why

Audit snapshots currently copy `.claude` instructions and private `.foundry/skill-upgrades` backups, contrary to the documented metadata isolation. Accepted debt is read from a wider filesystem scan than the analyzed copy, while parity builds each backend's copy independently; these gaps weaken the trustworthiness of adoption evidence.

## What Changes

- Exclude Claude metadata and application-root private skill-upgrade sessions from audit inventory, copies and fingerprints while preserving normal Foundry receipts and architecture inputs.
- Use the same documented input eligibility policy for read-only adoption debt inventory and disposable audit debt collection; excluded baseline files cannot appear as resolved application debt.
- Capture and verify one private snapshot per audit/parity operation, derive accepted debt from it, and give each backend a separate working copy of those same captured inputs.
- Verify copied bytes against the captured inventory, reject detected source changes and incomplete reads, and clean temporary copies on normal success/failure.
- Bind opaque parity fingerprints to the input-policy revision so previously generated parity evidence requires regeneration without changing report schema 1.
- Verify installed-gem behavior with real locked Packwerk acceptance and the existing pinned pks parity lane, plus deterministic faulty controls and guidance upgrades.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `adoption-evidence`: Private metadata exclusion, consistent input/debt scope, shared captured parity inputs, and stale-evidence handling.

## Impact

Private snapshot/debt/audit helpers, adoption guidance and focused core/packaged/parity acceptance change. Existing commands, options, report fields and exit semantics remain intact. Boundary checks retain their existing conservative baseline-preservation guard; this scope does not add package discovery or change Packwerk's authority.

Keep Rails, Minitest and all existing dependency versions and locks unchanged. Preserve eight product skills, twelve applications, current compatibility floors, accepted baselines and historical evidence. Hosted CI, publication, deployment, providers, agent trials, Campfire harness repair, a new sandbox, and a generic migration framework are excluded.
