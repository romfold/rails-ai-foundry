## Context

See proposal.md. Existing adoption retains tenant_id from the start and later introduces ROM/integrations. Keep its default replay intact; add --scenario=tenant-backfill in the same contributor recipe.

## Goals / Non-Goals

Demonstrate useful extraction before an application-specific online data migration. No general migration facility, ownership transfers, destructive rollback or new catalog application.

## Decisions

An earlier fixture derives document ownership through trusted legacy collections, with at least 1,200 rows across three tenants and unresolved imports. Extract Knowledge and repair public callers first. Expand with nullable tenant_id and progress state. Compatible writers derive ownership from collections; stop old writers explicitly before migration. Backfill keyset batches <=250, committing changes and progress atomically under a worker lock. Record unresolved IDs and reasons, never guess ownership.

Use validated presence and collection/tenant consistency constraints. Perform validation outside the writer gate. All compatible mutations cooperate with a shared transaction advisory lock; final cutover takes it exclusively with five-second acquisition and ten-second checked overall budgets. Switch only validated state, without backfill or corpus scans under the gate. Retain legacy reads on failure. Runtime statements have bounded timeouts; document possible in-flight overshoot.

Recipe tasks expose status, backfill/resume, validation and cutover. Replay both roots from an installed gem, retaining workflow/debt/skills/instructions. Recovery and faulty controls run on disposable PostgreSQL with no advanced integrations.

## Risks / Trade-offs

The gate assumes all writers run the compatible release; record this operational precondition. Unmapped ownership blocks completion and remains concealed. Validation can take time outside the pause; do not claim production throughput from fixtures.

## Migration Plan

Characterize, extract, repair callers, expand, deploy compatible writers, stop old workers, backfill, explicitly repair ownership, validate and cut over. Rollback selects compatible legacy reads while retaining all additive state. Verify fresh schema preparation separately from populated migration.
