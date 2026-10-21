# Pipeline principles

Acknowledge only committed effects or durably quarantined poison. Ordering and event identity are explicit.
Use native Karafka and NATS JetStream clients with application-owned handlers, never a Foundry event runtime.
Architecture belongs in [config](../../config/foundry.yml) and [pipeline](../../packs/pipeline/foundry.yml).
Maintain living contracts and reconcile plans/tasks as requirements change. Use only loopback test services.
