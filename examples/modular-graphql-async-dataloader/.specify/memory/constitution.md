# Directory principles

Prefer batched reads and explicit tenant/role propagation. Every source scopes and releases its connection.
Use GraphQL AsyncDataloader and upstream Falcon without Foundry execution code. Keep tests on loopback services.
Architecture belongs in [config](../../config/foundry.yml) and [directory](../../packs/directory/foundry.yml).
Reconcile living behavior, plans and tasks after requirement changes.
