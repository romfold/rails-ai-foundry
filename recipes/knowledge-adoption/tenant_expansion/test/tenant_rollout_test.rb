# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'support/seed'
require 'timeout'
require_relative 'support/tenant_rollout_helpers'

class TenantRolloutTest < ActiveSupport::TestCase
  include TenantRolloutHelpers

  setup { TenantSeed.reset! }
  teardown { TenantSeed.reset! }

  test 'confirmation, bounded batches and reviewed ownership repair' do
    worker = Knowledge::TenantBackfill.new
    assert_raises(Knowledge::TenantRollout::Blocked) { worker.start(old_writers_stopped: false) }
    worker.start(old_writers_stopped: true)
    assert_equal 250, worker.batch
    assert_equal 250, Knowledge::TenantMigration.find(1).cursor
    loop { break if worker.batch.zero? }
    assert_equal 1, Knowledge::TenantIssue.count
    assert_nil Knowledge::Document.find(1201).tenant_id
    assert_raises(Knowledge::TenantRollout::Blocked) { Knowledge::TenantConstraints.new.validate }
    assert_raises(Knowledge::TenantRollout::Blocked) { worker.repair(document_id: 1201, collection_id: 1) }
    Knowledge::Collection.find(4).update!(tenant_id: 'tenant-c')
    worker.repair(document_id: 1201, collection_id: 4)
    assert_equal 'tenant-c', Knowledge::Document.find(1201).tenant_id
    assert_equal 0, Knowledge::TenantIssue.count
    TenantSeed.verify!
  end

  test 'new and edited records derive ownership while backfill is incomplete' do
    catalog = Rails.configuration.x.knowledge
    worker = started_worker
    worker.batch
    row = catalog.create(tenant: 'tenant-a', collection_id: 1, title: 'Concurrent', body: 'Body')
    assert_equal 'tenant-a', Knowledge::Document.find(row['id']).tenant_id
    catalog.update(tenant: 'tenant-a', id: 1000, revision: 7, title: 'Concurrent edit', body: 'Updated')
    assert_equal 'tenant-a', Knowledge::Document.find(1000).tenant_id
    catalog.delete(tenant: 'tenant-b', id: 1001)
    loop { break if worker.batch.zero? }
    assert_equal 'Updated', Knowledge::Document.find(1000).body
    refute Knowledge::Document.exists?(1001)
    assert_equal 'tenant-a', Knowledge::Document.find(row['id']).tenant_id
  end

  test 'conflicting ownership rolls back batch rows and cursor' do
    worker = started_worker
    Knowledge::Document.find(2).update_columns(tenant_id: 'tenant-a')
    assert_raises(Knowledge::TenantRollout::Blocked) { worker.batch }
    assert_nil Knowledge::Document.find(1).tenant_id
    assert_equal 0, Knowledge::TenantMigration.find(1).cursor
  end

  test 'crashes before commit and after persistence recover without losing rows' do
    started_worker
    crash_worker(:before)
    assert_equal 0, Knowledge::TenantMigration.find(1).cursor
    assert_equal 0, Knowledge::Document.where.not(tenant_id: nil).count
    crash_worker(:after)
    assert_equal 250, Knowledge::TenantMigration.find(1).cursor
    assert_equal 250, Knowledge::Document.where.not(tenant_id: nil).count
    assert_equal 250, Knowledge::TenantBackfill.new.batch
    assert_equal 500, Knowledge::TenantMigration.find(1).cursor
    TenantSeed.verify!
  end

  test 'duplicate workers serialize atomic checkpoints' do
    started_worker
    reader, writer = IO.pipe
    ActiveRecord::Base.connection_pool.disconnect!
    pids = 2.times.map do
      fork do
        reader.close
        Knowledge::TenantBackfill.new.batch
        writer.puts('committed')
        writer.close
        exit! 0
      end
    end
    writer.close
    assert_equal %w[committed committed], Timeout.timeout(10) { reader.read.split }
    pids.each { |pid| assert Process.wait2(pid).last.success? }
    assert_equal 500, Knowledge::TenantMigration.find(1).cursor
    assert_equal 500, Knowledge::Document.where.not(tenant_id: nil).count
  ensure
    reader&.close
    writer&.close unless writer&.closed?
  end

  test 'cutover needs actual validated constraints and rollback retains ownership' do
    rollout = Knowledge::TenantRollout.new
    assert_raises(Knowledge::TenantRollout::Blocked) { rollout.cutover }
    finish_backfill
    Knowledge::TenantMigration.find(1).update!(phase: 'validated')
    assert_raises(Knowledge::TenantRollout::Blocked) { rollout.cutover }
    Knowledge::TenantMigration.find(1).update!(phase: 'backfilled')
    Knowledge::TenantConstraints.new.validate
    rollout.cutover
    assert rollout.active?
    assert_raises(ActiveRecord::StatementInvalid) { Knowledge::Document.find(1).update_columns(tenant_id: 'tenant-b') }
    rollout.rollback
    refute rollout.active?
    assert_equal 1201, Knowledge::Document.where.not(tenant_id: nil).count
    TenantSeed.verify!
  end

  test 'constraint validation refuses missing rows despite a completed checkpoint' do
    finish_backfill
    Knowledge::Document.find(1).update_columns(tenant_id: nil)
    assert_raises(ActiveRecord::StatementInvalid) { Knowledge::TenantConstraints.new.validate }
    refute Knowledge::TenantRollout.new.active?
  end

  test 'writer lock timeout preserves active selection' do
    finish_backfill
    Knowledge::TenantConstraints.new.validate
    reader, writer = IO.pipe
    ActiveRecord::Base.connection_pool.disconnect!
    pid = fork do
      reader.close
      Knowledge::TenantRollout.new.write do
        writer.puts('locked')
        writer.flush
        sleep 30
      end
      exit! 0
    end
    writer.close
    assert_equal "locked\n", Timeout.timeout(10) { reader.gets }
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    assert_raises(ActiveRecord::StatementInvalid) { Knowledge::TenantRollout.new.cutover }
    assert_operator Process.clock_gettime(Process::CLOCK_MONOTONIC) - started, :<, 10
    refute Knowledge::TenantRollout.new.active?
  ensure
    stop_child(pid)
    reader&.close
  end

  test 'checked budget failure rolls back the selection update' do
    finish_backfill
    Knowledge::TenantConstraints.new.validate
    slow = Class.new(Knowledge::TenantRollout) do
      def bound_remaining(started)
        @checks = (@checks || 0) + 1
        super(@checks == 2 ? started - 11 : started)
      end
    end
    assert_raises(Knowledge::TenantRollout::Blocked) { slow.new.cutover }
    refute Knowledge::TenantRollout.new.active?
  end
end
