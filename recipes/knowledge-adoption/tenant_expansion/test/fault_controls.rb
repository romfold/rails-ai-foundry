# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'support/seed'

class TenantFaultControls < ActiveSupport::TestCase
  setup { TenantSeed.reset! }
  teardown { TenantSeed.reset! }

  test 'default_owner' do
    worker = Knowledge::TenantBackfill.new
    worker.define_singleton_method(:fill) do |row|
      row.update_columns(tenant_id: Knowledge::Collection.find(row.collection_id).tenant_id || 'tenant-a')
    end
    worker.start(old_writers_stopped: true)
    loop { break if worker.batch.zero? }
    assert_nil Knowledge::Document.find(1201).tenant_id, 'Unresolved ownership must remain unset'
  end

  test 'skipped_batch' do
    Knowledge::TenantBackfill.new.start(old_writers_stopped: true)
    Knowledge::TenantMigration.find(1).update!(cursor: 250)
    worker = Knowledge::TenantBackfill.new
    loop { break if worker.batch.zero? }
    assert_equal 1200, Knowledge::Document.where.not(tenant_id: nil).count, 'Checkpoint must not skip rows'
  end

  test 'unsafe_cutover' do
    rollout = Knowledge::TenantRollout.new
    rollout.define_singleton_method(:cutover) { Knowledge::TenantMigration.find(1).update!(active: true) }
    rollout.cutover
    refute rollout.active?, 'Incomplete migration must not activate'
  end

  test 'authorization' do
    catalog = Rails.configuration.x.knowledge
    catalog.define_singleton_method(:visible) { |_tenant| Knowledge::Document.all }
    assert catalog.list(tenant: 'tenant-a').all? { |row|
      row['tenant_id'] == 'tenant-a'
    }, 'Foreign data must be concealed'
  end
end
