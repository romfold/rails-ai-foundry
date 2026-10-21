# Durable order fulfillment

An authenticated tenant places an order synchronously. Order and publication intent commit together;
failed operation results and outer transactions roll back both. Fulfillment is durable asynchronous work.
A dispatcher publishes due intents to Redis and retries until PostgreSQL records completion.
Crashes after queue acceptance and lost jobs must be recoverable. Duplicate execution commits one receipt/effect.
Invalid envelopes are quarantined; repair and explicit replay restore processing without silently dropping intent.
A real Sidekiq worker must consume the queue, acknowledge the database effect and shut down successfully.
