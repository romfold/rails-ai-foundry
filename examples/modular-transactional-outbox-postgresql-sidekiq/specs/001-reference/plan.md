# Plan

Follow installed context configuration. Use direct Dry::Operation with an explicit requires_new savepoint
and failed-result rollback. Lock outbox candidates with SKIP LOCKED and publish native Sidekiq jobs.
Keep intent due until fulfillment and a unique receipt commit with completion in one PostgreSQL transaction.
Exercise Redis crash/loss windows, duplicate/poison handling, failed results and a real worker process.
Pin connection_pool 2.5.5: Sidekiq 7.3.9 scheduler is incompatible with the 3.x positional pop API change.
