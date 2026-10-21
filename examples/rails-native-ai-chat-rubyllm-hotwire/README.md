# Rails-native persistent chat with RubyLLM and Hotwire

The focal context is [conversations](packs/conversations/foundry.yml). The app owns ordinary Rails models,
services, delivery and its independent bundle. Foundry is development-only.

```sh
docker compose up -d --wait
bundle install
bin/setup
bin/verify
bundle exec rubocop
bin/rails server
```

Open localhost:3000, choose a demo identity, create a conversation and send a message. Text streams through
Rails Live responses and native Turbo DOM updates. Load history reads the persisted PostgreSQL messages.
The unchanged Turbo 2.0.23 browser distribution and MIT license are in public/vendor for offline delivery.

Delivery explicitly uses DemoProvider, which makes no model requests. The application-owned Provider uses
RubyLLM.chat, pack-local prompts and config/ai.yml aliases; inject it into Reply after configuring provider credentials.
No model keys are needed for tests. Demo bearer identities illustrate isolation; replace them with real authentication.

Only one reply may be pending per chat. Partial failed responses remain labeled failed and are excluded from
future model history. Requests are bounded to 4000 characters and replies to 32000; only the last 20 completed
turns go to the native provider. A process killed midstream can leave a pending row: after confirming that worker
is dead, mark that row failed before retrying. This example does not claim durable background generation.

Acceptance covers persistent history, concurrent-turn rejection, ownership, escaped streaming output,
provider failure and the direct RubyLLM adapter contract. Live model quality and proxy buffering are separate deployment checks.
Spec Kit prerequisites check artifact presence; [the living contract](specs/001-reference/spec.md) is reconciled against tests.
