# Ledger principles

Use ordinary Rails and Rails Event Store. Monetary amounts are bounded integer cents.
The event stream is authoritative; optimistic concurrency prevents lost updates.
Authenticated identity determines stream ownership. Tests use only disposable loopback services.
Architecture belongs in [application configuration](../../config/foundry.yml),
[ledger configuration](../../packs/ledger/foundry.yml) and package.yml, not a second inventory here.
Keep this behavioral specification alive as requirements change; reconcile plan, tasks and tests together.
