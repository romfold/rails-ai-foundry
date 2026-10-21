# Reconciliation

2026-09-09: Ruby 3.4.10, Rails 8.1.3.1, PostgreSQL 17.11.
Kafka 3.9.1, Karafka 2.4.13, NATS 2.11.8, nats-pure 2.5.0; real consumer retry/restart and durable JetStream replay verified.
`bin/verify` passed: 5 tests, 27 assertions, structural checks, Packwerk,
Spec Kit prerequisites and production eager loading without Foundry execution.
RuboCop passed on 29 files. No live-model or production throughput claims.
