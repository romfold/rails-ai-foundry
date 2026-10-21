# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'support/seed'
require_relative 'support/tenant_rollout_helpers'
require 'timeout'

class TenantConcurrencyTest < ActiveSupport::TestCase
  include TenantRolloutHelpers

  setup { TenantSeed.reset! }
  teardown { TenantSeed.reset! }

  test 'ordinary writers continue while a batch holds its checkpoint transaction' do
    started_worker
    ready, signal = IO.pipe
    release, resume = IO.pipe
    ActiveRecord::Base.connection_pool.disconnect!
    pid = fork do
      ready.close
      resume.close
      worker = Knowledge::TenantBackfill.new
      worker.define_singleton_method(:before_commit) do
        signal.puts('ready')
        signal.flush
        release.gets
      end
      worker.batch
      exit! 0
    end
    signal.close
    release.close
    assert_equal "ready\n", Timeout.timeout(10) { ready.gets }
    catalog = Rails.configuration.x.knowledge
    row = catalog.create(tenant: 'tenant-a', collection_id: 1, title: 'Concurrent', body: 'New')
    catalog.update(tenant: 'tenant-a', id: 1000, revision: 7, title: 'Concurrent', body: 'Changed')
    catalog.delete(tenant: 'tenant-b', id: 1001)
    assert_equal 'tenant-a', Knowledge::Document.find(row['id']).tenant_id
    resume.puts('commit')
    resume.close
    assert Timeout.timeout(10) { Process.wait2(pid).last.success? }
    pid = nil
    worker = Knowledge::TenantBackfill.new
    loop { break if worker.batch.zero? }
    assert_equal 'Changed', Knowledge::Document.find(1000).body
    refute Knowledge::Document.exists?(1001)
  ensure
    stop_child(pid)
    [ready, signal, release, resume].compact.each { |io| io.close unless io.closed? }
  end

  test 'failed validation resumes from installed constraints after explicit repair' do
    finish_backfill
    Knowledge::Document.find(1).update_columns(tenant_id: nil)
    validator = Knowledge::TenantConstraints.new
    assert_raises(ActiveRecord::StatementInvalid) { validator.validate }
    refute validator.validated?
    Knowledge::Document.find(1).update_columns(tenant_id: 'tenant-a')
    validator.validate
    assert validator.validated?
    Knowledge::TenantRollout.new.cutover
    assert Knowledge::TenantRollout.new.active?
  end
end
