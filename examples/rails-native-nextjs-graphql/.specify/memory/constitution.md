# Rails-root frontend principles

Rails owns data and authorization. Next.js owns presentation in a separate frontend bundle.
Do not put Foundry in production execution. Keep tests on disposable loopback services.
Architecture belongs in [config](../../config/foundry.yml) and [directory](../../packs/directory/foundry.yml).
Maintain living behavior and reconcile plan/tasks when requirements change.
