# 0010: Optional architecture planning and resumable application

- Status: Accepted
- Date: 2026-09-08

## Context

Foundry already provides profiles, generators and structural checks. Ownership and complexity choices benefit from a reviewable interview without replacing ordinary Rails development or making plans mandatory. Existing installers publish one package at a time.

## Decision

Add optional questionnaire/proposal, read-only validation and digest-reviewed application. Application manifests remain authoritative for installed constraints; plans contain only additions and rationale. Application OpenSpec describes business behavior and ADRs explain decisions.

Use one ordered advisory table for both package types. Deliberate overrides remain valid, while event-sourced selection requires explicit authoritative-history acknowledgement. Adoption requires confirmed ownership rather than inferred source candidates.

Bind review to exact bytes and canonical application root. A digest is not identity verification or authorization; the planning skill obtains approval of the concrete proposal. Do not invent an approved YAML status.

Preflight the entire combined graph, then use existing package installers with resumable partial success. Preserve completed packages and concurrent edits. Revalidation and exact-match repeat replace a second applied-state ledger. Manifest v1 migration remains separate.

## Alternatives considered

Mandatory scoring would turn guidance into unsupported architectural certainty. Restricting platform profiles would remove existing valid choices. A new atomic batch installer would expand filesystem transaction machinery beyond the needed workflow. Making a plan the installed registry would duplicate the existing manifest.

## Consequences

Eight shipped skills replace the previous seven-skill catalog only through conservative manual review. Existing generation remains available without planning. Partial failure is explicit, and a digest cannot establish historical approval, behavior correctness or transaction safety in consumer code. No models, migration automation or runtime profile changes are introduced.
