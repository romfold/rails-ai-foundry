## Context

See proposal.md. Existing receipts contain template hashes, not original text. Same-receipt repeats already preserve arbitrary application edits. Filesystem updates need process-crash recovery as well as exception handling.

## Goals / Non-Goals

**Goals:** explicit current-catalog upgrades, pending review, exact provenance and conditional rollback.
**Non-Goals:** text merging, legacy catalog migration, runtime changes, skill effectiveness claims or automatic CI enforcement.

## Decisions

- Reuse the Rails generator with upgrade/apply/resolve/rollback options. No standalone CLI command or configuration key.
- Assess old template hashes, installed snapshots and incoming bytes. The deterministic SHA-256 review ID includes modes and receipt bytes as well as actions.
- Keep immutable plans with base64 original/proposed snapshots and a separate atomic progress journal under .foundry/skill-upgrades/TARGET/ID. Only relative validated owned paths are actionable. Directories are private; contents never enter normal output.
- Lock the application directory with a nonblocking POSIX flock for all skill writers. This conservatively serializes different targets too without adding lock artifacts to ordinary installations or changing their receipts.
- Persist each operation's before/after state before replacement; fsync files and parent directories. Recovery accepts only recorded before/after states. Completed receipts remain template provenance, while resolved choices and actual accepted hashes are retained separately.
- Resolution JSON names session and every pending path with decision and current sha256. Merged content is read from the installed file. Keeping a retired customized file removes ownership at final receipt publication.
- Validate rollback across every affected path before writing. Retain journals/backups after completion; do not implement cleanup in this scope.

## Risks / Trade-offs

- Multiple files are not atomically visible: use the generator while agents/editors are idle; a pending journal blocks ordinary generation.
- Filesystem safety is cooperative and POSIX-local, not protection from a malicious same-user process racing directory replacement. Safe-path checks and checked preimages reject observable changes.
- Receipt hashes cannot reconstruct old template text: review copies show local and incoming content, without claiming a three-way diff.
- Review backups may contain private local guidance: use private modes, exclude from sharing, and restore through checked rollback.

## Migration Plan

Ordinary installs remain unchanged. Only explicit application changes receipt provenance. Preserve the old receipt and backups; recover or roll back an interrupted session before changing tool versions. No business data migration or provider access.
