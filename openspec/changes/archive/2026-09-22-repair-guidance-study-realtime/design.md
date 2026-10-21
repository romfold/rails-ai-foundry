## Context

The saved patch is `0cba1a704df26b74a226492686c57e9c817fba73a4a2ae8d79112ea1cb952f78`, from Foundry revision ce57b2657398ffca89715e3d28e82bc360829790 and study manifest 702f34d0353d370082d600711740421083cedce44f6a92bebf588e52290cafa1. Rails image 7a68abbb405addbea91cc7c9ea75c802b63e2603e2f25f51c3c03f92e64b85a0 reproduces callback deduplication and form-helper argument interpretation. See proposal.md for motivation.

## Goals / Non-Goals

Repair only the saved application, keep its content/creator schema and authorization, and improve reusable skills. Do not alter upstream task requirements, grading, public Foundry interfaces, historical evidence or agent execution inputs. No new paid experiment is authorized.

## Decisions

- Use distinct create/destroy commit hooks, stable entry append/remove actions and matching HTTP streams. Guarded whole-strip morph remains a tested valid alternative, but targeted entries simplify ownership of unsaved input.
- Use an explicit deletion helper block and retain requested-ID lookup; validate rendered action, DELETE override and accessible controls behaviorally.
- Keep a permanent composer separate from the entry list; use 422 error updates without clearing failed input. Successful local submissions and cancellation alone reset it.
- Render shared entries in the comment account with no request user. Materialize controls using the application's browser-local Current.user and keep server authorization authoritative.
- Add `realtime-guidance-2026-09-21` to existing named repair preparation. Provenance validates the frozen study, source/task/image/candidate and all fixture hashes before output.
- Keep causal diagnostics and six faults contributor-only: callback collision, malformed button, duplicate echo, destructive composer replacement, sender-dependent controls and wrong-record deletion. Test a guarded replacement as a valid alternative.
- Add only small generic guidance to existing skills and their shared behavioral reference; no task-specific solution or new skill.

## Risks / Trade-offs

Browser timing can mask publication failures; synchronize subscriptions and DOM assertions without arbitrary sleeps. Earlier passed repairs do not improve newly generated upstream candidates: retain independent attribution and the paid 9/1 score. Raw patches/logs may contain whitespace; preserve their bytes and report any check exception explicitly.

## Migration Plan

No business-data migration or deployment. Reconstruct in a new external workspace, run offline acceptance, record separate evidence, and archive after verified completion. Reverting this change removes only the new repair selection/guidance; prior fixtures remain usable.
