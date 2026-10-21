# Plan

Follow installed package configuration. Normalize bounded identity fields and v1/v2 envelope shapes before applying.
Use a PostgreSQL cursor lock and unique event receipts in the same transaction as totals/position changes.
Use an ordinary Karafka consumer and application-owned routing file. Verify Kafka with isolated topics/groups,
a one-time test-only failure, duplicate/versioned events and real consumer restarts.
Use native NATS durable pull consumers, file streams, ack_sync after commit, nak for gaps and term after quarantine.
Tests use task-local services, never external providers. This is at-least-once transport with idempotent database effects.
