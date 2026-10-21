# Implementation plan

Read config/foundry.yml and packs/voice/foundry.yml for installed architecture.

PostgreSQL owns sessions, monotonically increasing epochs, publication intent, receipts and bounded media frames. Bunny uses persistent messages, confirms, manual acknowledgments and dead-letter routing. Connection recreation is explicit. PCM travels over a separate HTTP endpoint in this small demo; replace that transport with WebRTC for production audio while retaining the durable control fence.

Use the independently locked bundle and compose.yml services. Keep Foundry out of production execution. Reconcile this plan with acceptance evidence when requirements change.
