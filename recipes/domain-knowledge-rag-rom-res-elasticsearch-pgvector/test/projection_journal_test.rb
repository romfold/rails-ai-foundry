# frozen_string_literal: true

require_relative 'test_helper'
require 'timeout'

class ProjectionJournalTest < ActiveSupport::TestCase
  test 'failed business writes roll back journal entries while sequence gaps remain valid' do
    before = @catalog.projection_fence
    result = @catalog.change(principal: @principal, action: 'create', attributes: { title: 'No', body: 'No' },
                             after_write: -> { Dry::Monads::Failure(:rejected) })
    assert result.failure?
    assert_equal before, @catalog.projection_fence
    row = published
    changes = @catalog.projection_changes(after: before, through: @catalog.projection_fence)
    assert_equal [row[:id]], changes.pluck(:document_id).uniq
    assert_equal 2, changes.size
  end

  test 'missing journal history blocks activation' do
    run = @search.start_rebuild(destination: 'search')
    row = published
    ActiveRecord::Base.connection.execute('DELETE FROM knowledge_projection_changes WHERE id = 1')
    assert_raises(RuntimeError) { @search.rebuild_search(run_id: run[:id]) }
    refute_equal [run[:candidate]], elastic.selected
    assert_equal row[:id], @catalog.snapshot(row[:id])[:id]
  end

  test 'a delayed writer cannot commit a lower journal entry after the committed fence' do
    entered = Queue.new
    release = Queue.new
    first = Thread.new do
      @catalog.with_write_gate do
        entered << document
        release.pop
      end
    end
    first_row = entered.pop
    waiting = Queue.new
    second = Thread.new do
      database = @catalog.instance_variable_get(:@database).connection
      database.synchronize do
        waiting << database.get(Sequel.function(:pg_backend_pid))
        document
      end
    end
    pid = waiting.pop
    Timeout.timeout(10) do
      loop do
        waiting_count = ActiveRecord::Base.uncached do
          ActiveRecord::Base.connection.select_value(
            "SELECT count(*) FROM pg_locks WHERE locktype = 'advisory' AND NOT granted AND pid = #{Integer(pid)}"
          )
        end
        break if waiting_count.positive?

        Thread.pass
      end
    end
    release << true
    first.value
    second_row = second.value
    changes = @catalog.projection_changes(after: 0, through: @catalog.projection_fence)
    assert_equal [first_row[:id], second_row[:id]], changes.pluck(:document_id)
  ensure
    release << true if first&.alive?
    first&.join
    second&.join
  end

  private

  def elastic
    Search::ElasticIndex.new(url: 'http://127.0.0.1:59210', name: 'foundry_knowledge_test')
  end

  def database_url
    config = ActiveRecord::Base.connection_db_config.configuration_hash
    "postgres://#{config[:username]}:#{config[:password]}@#{config[:host]}:#{config[:port]}/#{config[:database]}"
  end
end
