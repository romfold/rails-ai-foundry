# Reviewed ticket resolution

The existing [authorized-tools example](../examples/rails-native-agent-tools-structured-output-rubyllm/README.md "Repository-only reference; not installed")
now contains a separate request → proposal → review → execution → outcome workflow. It remains
Rails-native and independently bundled, built on Rails, packs/packs-rails and Packwerk. The
[decision](decisions/0012-application-owned-reviewed-ai-work.md) explains why application records
and native jobs own durability. No Foundry runtime or additional catalog application is needed.

## Run locally

From `examples/rails-native-agent-tools-structured-output-rubyllm`:

```sh
bundle install
docker compose up -d --wait
bin/setup
bin/rails server -b 127.0.0.1
# In a second terminal:
bin/jobs start
```

Visit `/demo/login`, choose Reader or Editor, and request a resolution. A reader may request and
cancel their work. An active editor in the same tenant may approve/reject, including their own
request. Approval stores a decision; a job subsequently closes the ticket and stores its approved
resolution. These known demo identities are intentionally not production authentication.

The older `POST /answers` remains offline by default. Its explicitly constructed `TicketAgent.with_model`
installs a close tool authorized for delegated execution. That demonstration is not the review flow.
The new `ResolutionAgent` only produces a bounded schema; it never installs a closing tool.

## HTTP contract

Use JSON with `Authorization: Bearer demo-reader` or `demo-editor` for the demonstration API.
Never accept an actor or tenant from request parameters. Browser actions use the demo session and CSRF.

| Request | Input / result |
| --- | --- |
| `POST /resolutions` | `ticket_id`, `question`, requester-scoped `idempotency_key`; 202 with Location/status URL |
| `GET /resolutions/:id` | Current status, source snapshot, proposal/digest and decision/outcome |
| `POST /resolutions/:id/approve` | Exact `proposal_digest` and `ticket_revision`; editor only |
| `POST /resolutions/:id/reject` | Editor rejects an awaiting-review proposal |
| `POST /resolutions/:id/cancel` | Requester or editor; conflicts after completion |
| `POST /resolutions/:id/retry` | Requester supplies a new idempotency key for a linked request after failed generation |

JSON transitions return 202; browser forms redirect with 303 to the current status page. Conflicts
return 409, unauthorized decisions 403, invalid input 422, missing identity 401, foreign resources 404.
Identical keys/content return the previous request; changed content conflicts. One active request
per ticket is enforced in PostgreSQL. Failed generation retry preserves attempts and never approval.
Stale work requires a fresh request. Proposals cannot be edited.

## Recovery and operating limits

Questions and proposals are limited to 2,000 characters. Generation has at most three persisted
attempts, 10/20-second retry delays, a 30-second provider timeout, no transport retries and a
90-second claim lease. A recurring sweep runs every 30 seconds, selecting at most 50 due requests.
Jobs contain only work IDs. The default provider is deterministic and offline; setup and workers
cannot activate a paid provider. Controlled RubyLLM responses verify the adapter separately.

Pending state survives lost scheduling. An operator can wake discovery with:

```sh
bin/rails runner 'Assistance::DiscoverResolutionsJob.perform_now'
```

A dead generation worker becomes reclaimable after lease expiry; an old result cannot overwrite
new ownership. Provider invocation can repeat after a crash. Execution and cancellation lock sorted
identity IDs, then the ticket and request. Closure, approved text, completion and audit commit
atomically. Permission revocation or changed source state makes execution stale. Duplicate jobs
observe completion and do nothing. No external action or exactly-once provider promise is made.

The status frame polls every three seconds for at most 120 polls per page visit and stops on a
terminal state. Reload to resume after the limit. Scratch notes remain outside the refreshed frame.
Audit records retain business content in protected database records; standard logs run at info
level and filter question/proposal/resolution/token parameters. Notifications
`assistance.resolution` and `assistance.scheduling_failed` contain safe event names and work IDs.
Monitor pending age, failure codes and attempt history from persisted records; never log prompts,
content, credentials or raw provider exception messages.

## Upgrade and rollback

Stop existing workers before applying additive migrations. Keep existing tickets and data. The
queue migration mirrors Solid Queue's locked schema. Run `bin/setup`, then restart workers with
recurring discovery. On rollback, stop workers and retain operational tables, approval/audit records
and additive ticket columns; do not undo committed business closures or erase review history.

## Verification

Use disposable loopback PostgreSQL ending in `_test`, a prepared Chrome/ChromeDriver, and offline
providers. The environment may set `PGPORT` and `SE_CHROMEDRIVER` for local resources.

```sh
bin/verify
bin/verify-controls
bundle exec rubocop
```

`bin/verify` runs the shipped baseline/caller/browser helper, source/prompt/Packwerk checks,
Spec Kit prerequisites and production loading. Process tests kill a separate worker at explicit
barriers after provider response, before local commit and after commit before acknowledgment.
Controls accept direct/delegated behavior and require each intentional fault to produce a
behavioral assertion failure. See [acceptance evidence](reviewed-ticket-resolution-evidence.md).
Hosted CI, live quality evaluations and further coding-agent studies remain separate and pending.
