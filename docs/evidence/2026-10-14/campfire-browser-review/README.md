# Campfire Search browser comparison

Date: 2026-10-14. This is a separate browser review of the extraction recorded in
[the October 10 evidence](../../2026-10-10/campfire-search-extraction.md).
It does not repair or replace Campfire's blocked Minitest acceptance.

## Result and attribution

No extraction regression was observed in the reviewed scenarios. Both healthy applications
produced the expected message identities, ordering, history and authorization behavior.
The deliberately unscoped application disclosed `message_secret`; the same visibility
check exited 1 with `Private-message disclosure: ["message_secret"]`. Restoring the
scope returned HTTP 200 with no private message IDs and exit 0.

| Input | Frozen selection |
| --- | --- |
| Original Campfire | `d2155e85a01b8439c32a3604ebb7f39fea1ace0f` |
| Extracted Campfire | `e9b63a2f138f41592e999b0fae5fcbca3b2eb2a4` (implementation `5925c10`) |
| Rails | 8.2.0.alpha, Git `1a02651ac37fb64b4de2a2b73461d86acf9c98fb` |
| Minitest | 6.0.6, unchanged |
| Ruby / Bundler | 3.4.10 / 4.0.13 |
| Browser / existing CLI | Chromium 155.0.8059.40 / Playwright CLI 0.1.22 |
| Redis | 7.2.5; disposable processes on separate loopback ports |
| Execution | Development Puma, default application configuration; 1200 × 948 browser viewport |

Original lock SHA-256: `c2e23ce4171d0611fa35b8c360b7d409b8d5727cd58bfeb849a0b4a7e72ec976`.
Extracted lock SHA-256: `f831ab48643b42df7de656f6c2776f0d8b824457cd76fc24402f4eba924a607e`.
Both match the prior evidence. No dependency was installed or changed during this review.
`bundle _4.0.13_ check` succeeded with `BUNDLE_FROZEN=true` for all three archives.

The original and extracted source trees, and the restored fault tree, were compared byte for
byte with every versioned file in their respective Git revisions: zero differences.
This includes Gemfile/lock, Rails boot/configuration, database schema and test harness.
The original checkout and isolated extraction branch were clean before evidence-only updates.
Database creation and mutations ran only in fresh disposable archives; original application
data was neither copied into them nor operated on.

## Observations

Each application began with two synthetic users, three closed rooms and 105 messages.
All 105 were indexed through ordinary model callbacks. Stable `client_message_id` values
produce DOM IDs such as `message_window1`; numeric database IDs are not DOM IDs here.

| Scenario | Expected and observed in both healthy applications |
| --- | --- |
| Signed-out Search | Redirect to `/session/new`; normal form login returns to Search |
| Ordinary search | `hello` returns only `message_ordinary`, formatted and marked as the current user's message |
| Navigation | Clear field returns to empty Search; history link restores results; Exit search returns to `/rooms/1` |
| Query normalization | `hello!!!` matches the ordinary message; absent query returns none |
| Literal operators | `salt AND` and `AND` match the seeded text; `OR` and `NOT` return none; all HTTP 200 |
| Result window | Exactly `message_window1` through `message_window100`, in that order; `window0` excluded |
| Frontend | All 100 results acquire `message--formatted`; search controller, Stimulus and Turbo assets return 200 |
| Nonmember visibility | Review One cannot see `message_secret`; Review Two, its room member, can |
| Revocation | `message_revocable` is visible before membership removal and absent afterward in the existing signed-in browser |
| Creation | Native creation adds `message_fresh`; message/index counts become 106/106 |
| Update | `beforeword` stops matching; `afterword` returns only `message_lifecycle` |
| Deletion | Deleting lifecycle/fresh messages removes old and new terms; message/index counts become 104/104 |
| History isolation | Review One cannot see Review Two's `privatehistory` |
| Injected creation owner | POST with `user_id=2` still records `ownedword` for signed-in Review One |
| History bound | Eleven sequential terms leave `term10` through `term1`, newest first |
| Repeat query | Repeating `term1` moves it first without adding an eleventh row |
| Clear dialog | Dismiss retains ten entries; accept removes all entries for the signed-in user |
| Injected clear owner | Authenticated DELETE with `user_id=2` clears Review One only; Review Two retains exactly `privatehistory` |
| Fault and recovery | Unscoped copy discloses `message_secret`; restored copy and both healthy apps exclude it |

HTTP requests used the browser's normal authenticated cookie context and real CSRF token,
without exporting either. Successful commands executing no tests were not used as evidence.
The checked browser functions throw on mismatches and return their actual observations.
The CLI's modal handling is separate: dialogs were explicitly dismissed/accepted and
history counts inspected afterward. Snippets are contributor review steps, not a new
application test runner or a substitute for the installed verification helper.

The two settled Search screenshots were byte-identical, SHA-256
`9aee575b4b7647a11f129571c2b6efc25ad170a2c508101fd152662383bdfdd7`.
One copy is retained as [search.png](search.png). It contains synthetic content only.
Both were visually inspected; this is one desktop viewport, not a cross-browser or
accessibility certification. Search/Stimulus/Turbo asset response fingerprints also matched.

## Observed baseline behavior and review corrections

- A raw browser `fetch` DELETE followed the application's 302 redirect as another DELETE
  to `/searches`, producing 404 in **both** revisions. The normal clear-history UI uses
  a POST with a method override and succeeded. This pre-existing HTTP redirect behavior
  was not changed. The explicit ownership check inspects the initial DELETE's 302 and
  then reloads with GET. The 404 is retained as a limitation, not hidden as a passing request.
- The first combined history snippet yielded a modal notification before returning its
  observations. It was split into non-dialog snippets and explicit CLI dialog actions;
  history and ownership were rerun with observed results. A command's exit 0 with a modal
  notification was not counted as completed scenario evidence.
- The initial service setup shared a Redis process. Before revocation/fault activity,
  the extracted app was restarted against a separate process; the fault app received a
  third. Redis database numbers alone do not isolate pub/sub. No worker jobs or real
  push subscriptions were enabled.
- The wrapper's `npx` resolution stalled and ultimately failed with registry `ENOTFOUND`.
  The already-installed CLI was invoked directly;
  no application dependency installation or upgrade was used as a workaround.
- Redis initially rejected the inherited locale, then sandboxed port binding. `LC_ALL=C`
  and authorized loopback execution resolved those environment issues. Early wrong element
  selection, wrong working directory and an unquoted URL were corrected before successful
  scenario execution. None were application failures.
- Final settled-page console checks reported zero errors/warnings. The earlier raw-DELETE
  404 remains recorded above; a clean later page does not erase that observation.
- Contributor Ruby snippets initially used Campfire's style; Foundry's RuboCop required
  single-quoted literals, spacing and frozen-string comments. Formatting was corrected
  without changing the scenario behavior.

## Reproduction

Use a Campfire repository containing the frozen commits, its existing exact bundle/cache,
and the existing browser CLI/browser. No network installation or lock update is required.
Use a new empty `REVIEW_ROOT`; set `CAMPFIRE_SOURCE`, `EVIDENCE` (this directory), and `PWCLI`
to absolute local paths. Keep machine-specific values out of committed logs.

```sh
mkdir -p "$REVIEW_ROOT/original" "$REVIEW_ROOT/extracted" "$REVIEW_ROOT/fault"
git -C "$CAMPFIRE_SOURCE" archive d2155e85a01b8439c32a3604ebb7f39fea1ace0f | tar -x -C "$REVIEW_ROOT/original"
git -C "$CAMPFIRE_SOURCE" archive e9b63a2f138f41592e999b0fae5fcbca3b2eb2a4 | tar -x -C "$REVIEW_ROOT/extracted"
git -C "$CAMPFIRE_SOURCE" archive e9b63a2f138f41592e999b0fae5fcbca3b2eb2a4 | tar -x -C "$REVIEW_ROOT/fault"
export BUNDLE_FROZEN=true RAILS_ENV=development
export REVIEW_PASSWORD=local-review-only
```

Select managed Ruby 3.4.10 and the existing bundle location. Run separate foreground Redis
processes with `LC_ALL=C redis-server --bind 127.0.0.1 --port PORT --save '' --appendonly no`:
original 16389, extracted 16390, fault 16391. In each archive, set `REDIS_URL` to its own
instance, then execute:

```sh
bundle _4.0.13_ check
bin/rails db:prepare
bin/rails runner "$EVIDENCE/seed.rb"
bin/rails server --binding 127.0.0.1 --port PORT
```

Use application ports 3141/3142/3143 respectively. The fault server was started with
`WEB_CONCURRENCY=0`; original/extracted used the same default seven Puma workers.
Schema preparation creates only disposable databases. Do not copy existing storage or
credentials. No queue worker is needed; Search's FTS callbacks run natively after commit.

For each healthy application:

1. `"$PWCLI" -s=SESSION open URL/searches --headed`. Observe the signed-out redirect.
2. Use `snapshot`, then `fill`/`click` with observed refs to sign in as `one@example.test`
   using the synthetic password above. Submit `hello` through the Search form.
3. `"$PWCLI" -s=SESSION run-code --filename "$EVIDENCE/queries.js"`.
4. `"$PWCLI" -s=SESSION run-code --filename "$EVIDENCE/history.js"`.
5. Snapshot, click the visible Clear recent searches button, `dialog-dismiss`, and verify
   `.searches__recents a` has ten elements. Click again, `dialog-accept`, and verify zero.
6. `"$PWCLI" -s=SESSION run-code --filename "$EVIDENCE/ownership.js"`.
7. In that app run `bin/rails runner "$EVIDENCE/mutate.rb" create`; visit
   `/searches?q=freshword` and verify exactly `message_fresh`.
8. Run `bin/rails runner "$EVIDENCE/mutate.rb" update`, then execute `updated.js` through
   `run-code --filename`. It checks update, revocation and continuing private-room exclusion.
9. Run `bin/rails runner "$EVIDENCE/mutate.rb" delete`, then execute `deleted.js`.
10. Visit `/searches?q=hello`, inspect the settled page, and capture with
    `screenshot --filename output/playwright/campfire-search-review/NAME.png`.
    Inspect `console error` and relevant asset response statuses.

Use new empty databases for a complete rerun. The snippets do not reset existing data.
For negative control, replace only `Current.user.reachable_messages` with `Message.all`
in the fault copy's Search controller. Sign in as Review One in a separate browser session
and run `visibility.js`: require exit 1 with the specific disclosed identity. Restore
the original file, rerun to require exit 0, then run the same snippet in both healthy apps.
Never treat an infrastructure error as successful fault detection.

## Completion boundary and rollback

The browser-review checklist is separate from original tasks 2.2/2.3. The existing zero-test
and `minitest/unit` failures still block installed-helper behavioral acceptance and omitted-
coverage controls. No Minitest change, adapter, suppression, runtime, new integration,
dependency upgrade, hosted CI or agent trial was introduced. The OpenSpec change stays open.

Stop the three browser sessions and only the disposable Puma/Redis processes after review.
Discard disposable databases/copies when their evidence is no longer needed. No application
schema or data rollback is necessary. Reverting this review removes evidence and planning
updates only; the Search extraction remains a separate commit with its existing rollback.

The prior portable bundle remains historical evidence. Any refreshed handoff adds only
application documentation; it does not replace the frozen tested revision or claim a new
application implementation was verified.

Application evidence commit: `fdd36355faa91e98ca2b62c9b113da7cb34d6a6e` (documentation only).
The refreshed ignored local artifact is `tmp/campfire-adoption/search-browser-review.bundle`,
SHA-256 `0c8a397a5c2555e642a52b66f21306c28593dc5bfe167ddd77ad7a84b32bf2ce`.
`git bundle verify` passes; it requires the original base commit. The previous
`search-adoption.bundle` was preserved. Recover using the October 10 bundle instructions
with this new artifact path and review the documentation-only follow-up separately.
All three review browser sessions and disposable Puma/Redis processes were stopped.

## Foundry reconciliation checks

| Command | Actual result |
| --- | --- |
| `bundle exec rake test` | 210 runs, 2,271 assertions, zero failures/errors/skips; includes archive-content/link/privacy controls |
| `bundle exec ruby -Itest test/distribution_integrity_test.rb` | After the final roadmap link: 2 runs / 683 assertions, zero failures/errors/skips |
| `bundle exec rubocop --cache false --format simple` | 840 files, no offenses after contributor snippet formatting corrections |
| `ruby script/validate_skills` | Six development workflows and eight product skills validated |
| `npm run contracts:validate` | 10 runs / 142 assertions; eight schemas and 73 cases validated |
| `npm run spec:validate` | 40 items passed strict validation |
| `ruby script/privacy_check.rb` | Zero findings; matched values are never printed |
| `git diff --check` | Passed |

Only shipped roadmap guidance changed; its evidence link is marked repository-only.
No Foundry runtime, generator, schema or product skill changed. Broader
packaged/AI/workflow matrices and the twelve-app corpus were not rerun for this contributor
evidence update. Prior compatibility results remain attributed to their original revisions.
