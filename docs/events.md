# Events

Event and CQRS intent are independent of profile. Selecting integration or event_sourced records intent; it does not install event execution. Foundry 0.4 has no event bus, aggregate engine, projection processor or outbox runtime. Use direct upstream libraries and application-owned transactions. The [0.3 data recipes](data-recipes.md) provide application-owned PostgreSQL outbox, OpenSearch and RabbitMQ implementations with real crash-window, duplicate-delivery and concurrency acceptance. The [integration recipes](integration-recipes.md) add the authoritative RES ledger, PostgreSQL/Sidekiq outbox, and Kafka/Karafka/NATS pipeline with verified replay and recovery behavior.

See [native contexts](native-contexts.md), [native AI](native-ai.md) and [the implementation program](implementation-program.md) for detailed contracts and delivery status.
