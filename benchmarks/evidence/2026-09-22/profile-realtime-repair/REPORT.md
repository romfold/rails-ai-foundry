# Offline profile and realtime repairs — September 22, 2026

Both unsuccessful applications from the latest paid study were repaired in disposable
applications. These are **human-assisted regression results**, not new agent scores.
The paid study remains **eight passes, one architecture-policy failure and one
verification infrastructure error**, with its original patches, grades and accounting
unchanged. No paid calls or new coding-agent trials ran.

## Confirmed causes and changes

The boundary candidate used a valid `rails_native` profile even though its task
requested `modular`. Its endpoint, authorization, public API and Packwerk checks
already passed. The repair changes only that profile. Fresh verification passes all
original checks; the [context assessment](boundary-context.json) identifies exactly
`packs/knowledge`, namespace `Knowledge`, profile `modular`, workflow `none`.
The generic Foundry checker correctly accepts either profile; task intent must be
checked separately. No public configuration validator was changed to enforce a
benchmark-specific choice.

The realtime candidate introduced a migration without the application's generated
`db/schema_sqlite.rb`. Replaying its original patch reproduces the pending-migration
stop before baseline reporting. A schema-only correction passes the 1,517-test
baseline but leaves all six browser checks with errors: submit/cancel buttons render
with zero dimensions. The [browser diagnostic](form-diagnostics.log) records valid
button HTML and actual dimensions. This candidate's `button_to` block was already
correct; the preceding study's malformed helper was not this candidate's defect.

The migration also used integer references for UUID users/comments. The repair uses
the application's UUID types and generates its SQLite schema with pinned Rails.
It was migrated in a disposable primary database and independently reconstructed
from the delivered patch in fresh graders. This evidence does not establish MySQL
compatibility.

The [effective callback probe](callback-diagnostics-corrected.log) shows that reusing
one method for `after_create_commit` and `after_destroy_commit` leaves conditions
matching deletion only. Distinct callbacks now publish committed entry additions
and removals. Tests demonstrate publication on the subscribed card stream and silence
on rollback. Stable entry IDs deduplicate HTTP responses and broadcast echoes.

Shared markup uses the comment's account and browser-local viewer identity. Existing
nested authorized lookup is retained, including requested-ID deletion and 403/404
behavior. Entries are updated separately from a permanent composer. Local successful
submissions/cancellation reset input; rejected input remains editable with visible
errors. Other viewers' drafts survive broadcasts and refresh/morph. Sized controls
use the application's existing CSS classes.

## Verification

| Derived candidate/control | Outcome |
| --- | --- |
| Original boundary | Behavioral checks pass; requested-profile policy fails |
| Repaired boundary | Visible 2/4 and behavioral 3/14 tests/assertions pass; Packwerk and Foundry pass |
| Original realtime | Infrastructure error: pending migration prevents structured baseline results |
| Schema-only realtime | Baseline passes; six browser checks error on invisible controls |
| Final realtime, repetitions 1–3 | Each: 21 tests / 143 assertions, zero failures/errors |
| Callback collision | Five assertion failures, zero errors after baseline passes |
| Zero-size controls | One visibility assertion failure and 11 browser errors after baseline passes |
| Destructive composer replacement | Four assertion failures, zero errors after baseline passes |
| Guarded composer replacement | 21 tests / 143 assertions, passed |
| Upstream reference | Six tests / 35 assertions, passed |
| Upstream no-op | Baseline passes; all six browser checks error because the feature is absent |


Each final realtime acceptance runs the unchanged six upstream browser checks plus
15 supplemental checks in a fresh credential-free, network-disabled container.
The baseline retains the two pinned Vips NIFTI/RAW skips. Required assertions are not
skipped or weakened. The upstream test SHA-256 remains
`1b952cc16114e5dc09935f63379c19f8bb15d5a8a8eceb4dc1633e3ad0f4be96`.

The callback, zero-size-control and destructive-composer variants fail assertions
after successful application baselines. Guarded composer replacement passes, showing
that acceptance permits an equivalent implementation. Original failures and the
schema-only probe remain negative evidence. Development `repaired-v1` failed on
button visibility; `repaired-v2` passed 20 checks before the additional visibility
regression and final whitespace correction. All iterations remain separately stored.

## Reproduction and provenance

Use the [commands](COMMANDS.md) and named fixture set
[`profile-realtime-2026-09-22`](../../../repairs/sets/profile-realtime-2026-09-22/provenance.json).
Preparation verifies the study, both tasks/images, original candidates and fixture
hashes before creating output. Prior default and named preparation paths were also
replayed successfully. Rejected-provenance tests cover both candidates and changed
repair material.

Original source revision: `545e12f2cbfe6da095808c74ffbd29c5ec26229f`.
Study SHA-256: `b2531150d04fe69d5e3f7bdad18f1765b36f6908977597c614eb9275c0364759`.
Le Mans remains 1.3.5 at `2d0b7fb8d3b0077574dcf7b70fd4e32c8f9d6e76`;
AI-evals remains `5327efe54dd767d662ab89332f6a4285fef07bd8`.

| Candidate | Original patch SHA-256 | Complete repair SHA-256 |
| --- | --- | --- |
| Boundary | `58f0e44c60d33a64946406bdc1733fd3e6eeacf49bd12017fddb3cbba6b8cd92` | `0db0cb921de69fa5423e0818a2ab8ef334f2c13fccd7bba61f3847eb029cd9ef` |
| Realtime | `cb62fd83a4d7964fc49722bf047f4372461b0a5946cc9ae8114de81f7078edd3` | `492f95781341af8786546f394eec5860586b8960d5339659eca7782cb44a0e20` |

[Independent Git-index reconstruction](equivalence.json) proves that original plus
incremental repair produces the same tree as each complete patch: boundary
`95679c3de49b28babb320b72f8bbdcf84a3a508a`, realtime
`930449e5cb81072184636ebf52879e5bfca1f1ac`. Input snapshots retain development and
accepted patch/test hashes. Original candidates remain in the unchanged paid-study
archive; no new native trial was fabricated for a repaired application.

## Reusable guidance and repository checks

The existing `foundry-verify` skill now explicitly compares the assessed profile with
requested intent and checks both migration and fresh schema preparation. It asks
agents to inspect identifier types and the application's schema/database conventions.
The eight-skill count, CLI, public schemas, task requirements and verifier remain
unchanged. The unchanged upstream suite does not receive Foundry skills; these
repairs cannot establish improved future upstream model behavior.

| Check | Outcome |
| --- | --- |
| Contributor suite | 77 tests / 621 assertions, passed; final helper refactor also passes its 13 tests / 74 assertions |
| Core | 147 tests / 1,134 assertions, passed |
| Installed gem | 6 tests / 430 assertions, passed |
| Default/custom-root feature and skill replay | 2 tests / 208 assertions, passed; customized files, workflow and accepted debt preserved |
| RuboCop | 714 repository Ruby files passed; final changed test and three application Ruby files passed |
| Skills / catalog | Six development skills, eight product skills, twelve applications valid |
| Contracts | 10 tests / 142 assertions; eight schemas and 73 cases valid |
| Strict OpenSpec | 32 items before archive; 31 after synchronized archive, zero failures |

The [history inventory](history-integrity.json) checks 2,059 existing files. Only the
repair preparer and its documentation changed; 2,057 files, including all historical
study/repair artifacts, remain byte-identical. New evidence uses a separate directory.
The installed gem check's intentionally faulty endpoint produces a failure as an
expected control, while its enclosing acceptance passes.

Diagnostic development encountered an incorrect hardcoded workdir in the first
boundary reconstruction helper, a non-namespaced multi-database rollback command,
and an initial callback probe that did not model Rails' transaction predicate.
These were corrected in disposable applications. Direct Docker copying into its
read-only root was replaced with writing through the writable temporary mount.
Fixture hash validation rejected an intermediate stale provenance file as intended.
Small RuboCop offenses were corrected before final acceptance. Browser driver
metadata/telemetry requests fail under the offline network; the installed browser
executes the tests. These events do not alter historical grades or authorize retries
of paid attempts. Hosted release CI and publishing remain outside this repair.
