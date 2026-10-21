# Modular realtime voice with RabbitMQ

The focal context is [Voice](packs/voice/foundry.yml); topology is in its adjacent
[package.yml](packs/voice/package.yml). [Root defaults](config/foundry.yml) select the workflow.

PostgreSQL owns authorized sessions and monotonically increasing turn epochs. RabbitMQ transports
small reliable control messages; a separate bounded PCM endpoint transports audio. Applications
execute Rails and Bunny directly, with no Foundry control or media runtime.

## Try it

Open `http://localhost:3000`, choose a short speech recording, and start playback. Interrupt
stops local playout and invalidates the server's old epoch; reconnect starts an idle new epoch.
This local echo demo calls no speech or AI provider. A worker can process control independently:

```sh
bin/control
curl -X POST http://localhost:3000/sessions -H 'Authorization: Bearer demo-a'
curl -X POST http://localhost:3000/sessions/1/control -H 'Authorization: Bearer demo-a' -H 'Content-Type: application/json' -d '{"action_name":"turn"}'
```

The response supplies the current epoch. POST base64 PCM with `epoch`, increasing `sequence`,
and `data` to `/sessions/:id/media`; GET the same path with `epoch` to consume a frame.
PCM is signed 16-bit little-endian mono at 24 kHz in the browser demo. Each frame is at most
4096 bytes; each session holds at most 32 frames even across multiple Rails instances.
Out-of-order/duplicate sequences are dropped. Stale epochs are rejected and a full buffer applies
backpressure. HTTP transport favors inspectability here; use WebRTC for production audio and
retain the control protocol. Server epoch checks cannot retract bytes already on the wire:
the browser must also fence responses and stop playout on interruption.

Replace the demo `TENANT_TOKENS` JSON mapping with application authentication outside local use.
Every session/control/media call checks the authenticated tenant. RabbitMQ requires private
networking, dedicated credentials and permissions in a deployment; the loopback Compose demo
uses local credentials only.

## Delivery and recovery

Control changes and publication intent commit in one PostgreSQL transaction. `bin/control`
publishes up to 100 due entries using persistent messages, mandatory routing and confirms, then
consumes up to 100 with manual acknowledgments. Run it repeatedly under a supervisor. Consumer
receipts make database effects idempotent across a crash after commit and before acknowledgment.
A different payload reusing an event identity is poison. Invalid envelopes go to the durable
`.dead` queue. Inspect/correct the cause and explicitly republish corrected controls with a new
identity; do not blindly requeue poison.

Transport failures back off and poison after three publisher attempts. After repair, explicitly
reset the selected control's attempts/available_at/poisoned_at in a reviewed Rails console.
Transient consumer failures close the connection without acknowledgment so RabbitMQ requeues.
Reconnect creates a fresh Bunny connection. Old controls can record receipts but cannot alter
current turn state. Audio never enters RabbitMQ or the outbox.

Tests exercise real broker confirms, unroutable publication, duplicate identities, crash/reconnect
windows, dead letters, tenant isolation, concurrent media bounds and stale-epoch rejection.
The Rails view is tested; listening to playback is a manual browser acceptance check.

## Run and verify

Use Ruby 3.4.10 and Bundler 2.6.9. Run every command from this application directory.
Docker Compose v2 is required for the disposable services. PostgreSQL client tools 17
(`psql` and `pg_dump`) must be on PATH for SQL schema loading in the RAG application.

```sh
bundle install
docker compose up -d --wait
bin/setup
bin/verify
bundle exec rubocop
bin/rails server
```

Services bind to loopback only. The default PostgreSQL port is 55432. If another example
is already using it, run with a distinct `PGPORT` for both Compose and Rails, or reuse a
compatible disposable service explicitly. Each application has a distinct database name.
`docker compose down -v` removes only this Compose project's disposable services and data.
Never point these acceptance commands at a production database.

`bin/verify` runs real integration tests, source diagnostics, upstream Packwerk,
Spec Kit artifact prerequisites, and production eager loading without Foundry execution.
Normal tests permit loopback services only; no model credentials or provider requests are needed.
The independent CI lane uses the same commands and locked Linux dependencies.
Remote CI execution is separate from the local evidence reported here.

## Specification workflow

Pinned upstream Spec Kit 1.0.0 initialized this app. Its installed skills and scripts are
checked in; running this Rails application needs no Python or Spec Kit runtime.
For workflow changes, install Python 3.11+ and the pinned Specify CLI as described in
[Foundry workflow setup](../../docs/core-workflow.md).
Read the application constitution, living spec, plan, tasks and reconciliation evidence.
Upstream prerequisite checks establish artifact presence; they do not validate behavior.
