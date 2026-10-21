# Authorized voice control and bounded media

Status: implemented and locally verified; see reconciliation.md.

## Behavioral requirements

- Tenant authorization applies to sessions and every media/control operation. Forged tenant parameters never grant access.
- Control state and publication intent commit atomically; persistent RabbitMQ publication requires a broker confirmation and routable destination.
- Consumer receipts make duplicate effects idempotent. Poison envelopes are dead-lettered; transient errors remain replayable after reconnect.
- Interrupt and reconnect advance a durable epoch, invalidate old media and clear buffered frames. Stale control deliveries cannot resume an interrupted turn.
- Media is separate from broker control: at most 32 frames of at most 4096 bytes per session, bounded across Rails instances. Browser playout discards stale epochs.
- Normal tests use loopback services and no speech or model provider.

## Acceptance

Run `bin/verify` with the disposable services defined in compose.yml. The tests and reconciliation.md identify evidence; prerequisite checks only establish artifact presence.
