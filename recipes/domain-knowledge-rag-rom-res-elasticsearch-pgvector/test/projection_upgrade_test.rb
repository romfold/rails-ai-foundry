# frozen_string_literal: true

require_relative 'test_helper'

Dir[Rails.root.join('db/migrate/20260917*.rb')].each { |path| require path }

class ProjectionUpgradeTest < ActiveSupport::TestCase
  test 'additive upgrade preserves business rows events outbox and selections' do
    published
    drain
    @search.rebuild_vectors(version: 'existing-v2')
    expected = persisted_business_state
    migrations = [AddProjectionProgress, LinkProjectionChanges, AddRebuildRetryState, CaptureRebuildOptions]
    connection = ActiveRecord::Base.connection
    connection.transaction do
      # Recreate the old schema in this disposable transaction only. Operational tables
      # are deliberately retained during real rollback, as documented in the runbook.
      migrations.reverse_each { |migration| migration.new.migrate(:down) }
      migrations.each { |migration| migration.new.migrate(:up) }
      assert_equal expected, persisted_business_state
      raise ActiveRecord::Rollback
    end
  end

  private

  def persisted_business_state
    tables = %w[knowledge_documents knowledge_deliveries event_store_events event_store_events_in_streams
                search_vectors search_settings]
    rows = tables.to_h do |table|
      [table, ActiveRecord::Base.connection.select_all("SELECT * FROM #{table} ORDER BY 1").to_a]
    end
    rows.merge(alias: Elasticsearch::Client.new(url: 'http://127.0.0.1:59210')
                                           .indices.get_alias(name: 'foundry_knowledge_test').keys)
  end
end
