# Modular event pipeline with Kafka and Karafka

The focal context is [pipeline](packs/pipeline/foundry.yml). Kafka/Karafka is the selected messaging adapter;
the same app includes an independently verified optional NATS JetStream recipe. Both use ordinary upstream clients
and an app-owned handler. There is no Foundry event execution runtime.

```sh
docker compose up -d --wait
bundle install
bin/setup
bin/verify
bundle exec rubocop
bundle exec karafka server
# Separate terminal for Rails read delivery:
bin/rails server
```

Publish JSON through `Karafka.producer.produce_sync(topic: 'foundry_events', key: 'a:orders', payload: json)`
from a Rails console. A version 1 envelope is
`{"event_id":"event-1","tenant":"a","stream_key":"orders","sequence":1,"version":1,"amount":10}`.
Version 2 uses delta instead of amount. Keep all events for one tenant/key on the same Kafka partition.
GET `/streams/orders` with `Authorization: Bearer demo-a` returns the committed position and total.
Broker publishing belongs to trusted producers; broker credentials/ACLs must enforce producer authority in deployment.
Demo HTTP tokens illustrate read isolation and must be replaced with your application's authentication.

The cursor and unique event receipt commit atomically. Duplicates have no second effect; reused event IDs with
changed content are poison. Sequence gaps retry and never advance state. Malformed messages are stored in
pipeline_rejections before transport acknowledgment. Repair the source and republish explicitly; do not blindly
skip sequence gaps. Quarantining an invalid logical sequence may require operator repair before later events
for that key can advance. Transient failures retain transport delivery for retry.

For JetStream, instantiate `Pipeline::Jetstream.new`, publish the same JSON and call consume, then close.
The stream uses file storage and a stable durable pull consumer. ack_sync follows commit, gaps use nak,
and durably quarantined poison uses term. Reconnect preserves the durable consumer; no auto-ack is used.
This is an alternative recipe, not automatic mirroring between Kafka and NATS.

`bin/verify` tests real JetStream and starts real Karafka processes against a fresh topic/group. It injects one
transient error in test-only worker code, verifies retry and v1/v2/duplicate effects, restarts the consumer, then
removes the task topic. Kafka 3.9.1, Karafka 2.4.13, NATS 2.11.8 and nats-pure 2.5.0 are the tested versions.
Run with the default loopback broker addresses; acceptance never targets production brokers.
Keep [the living contract](specs/001-reference/spec.md), plan and tasks reconciled. No throughput or exactly-once
transport claim is made. Scale partitioning, retention, poison monitoring and retry budgets from measured workloads.
