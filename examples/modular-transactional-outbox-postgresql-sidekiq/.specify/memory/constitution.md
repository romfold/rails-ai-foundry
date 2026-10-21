# Orders principles

Business state and publication intent commit atomically. A queue acknowledgment is not business completion.
Use ordinary Rails and Sidekiq; keep the durable intent authoritative until a transactional receipt exists.
Architecture belongs in [config](../../config/foundry.yml) and [orders](../../packs/orders/foundry.yml).
Maintain living requirements, implementation plan and tasks together. Test only disposable loopback services.
