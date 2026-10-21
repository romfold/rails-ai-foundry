## Context

See proposal.md. Installer and SkillInstaller already provide safe preview and receipts; loading must be configured before Rails initializes load paths.

## Goals / Non-Goals

Compose existing capabilities, preserving ordinary install semantics. Do not infer contexts, choose an application stack, or migrate databases.

## Decisions

Ship a small standalone executable and Rails template. Use the installed version and after_bundle callback. Setup preflights both existing installers and conventional application class configuration, then writes new artifacts through the existing rollback machinery. Replace application configuration atomically last, verifying original identity and content. Reject complex configuration instead of evaluating it or guessing insertion points.

## Risks / Trade-offs

Filesystem changes are not a multi-file transaction. Preserve concurrent edits and report leftovers. A failed Rails bundle is owned by Rails; leave the application available for explicit setup retry. Rails stack dependencies must already be available for offline archive acceptance.
