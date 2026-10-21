# Reconciliation evidence

Verified locally on 2026-09-09 with Ruby 3.4.10 / Rails 8.1.3.1: 8 tests / 81 assertions, zero failures/errors/skips.

`test/broker_test.rb`: real RabbitMQ confirms/mandatory routing, crash after publication and commit, reconnect, poison, duplicate identity and stale delivery. `test/media_test.rb`: tenant authorization, bounded frames/bytes, parallel producers, interruption and reconnect fencing. `test/delivery_test.rb`: authenticated control, separate media route and pack-owned demo view.

`bin/setup` and `bin/verify` passed with real disposable services, including upstream Packwerk
and production eager loading without Foundry execution. The independent `bundle exec rubocop`
passed. Spec Kit 1.0.0 initialized this application, and its own prerequisite script resolves
the application's spec/plan/tasks. This is artifact presence evidence, not a common behavioral validator.

The checked-in CI job runs the same independent bundle and service configuration. Remote CI
was not run. No live model or speech provider calls occurred. See README for bounded-demo
tradeoffs and the manual browser playback check.
