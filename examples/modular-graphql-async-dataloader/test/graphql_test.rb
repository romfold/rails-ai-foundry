# frozen_string_literal: true

require 'test_helper'

class GraphqlTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    Directory::Person.delete_all
    @manager = Directory::Person.create!(tenant: 'a', name: 'Manager')
    @people = 3.times.map do |index|
      Directory::Person.create!(tenant: 'a', name: "Person #{index}", manager_id: @manager.id)
    end
    @other = Directory::Person.create!(tenant: 'b', name: 'Private')
  end

  test 'nested reads batch keys and propagate tenant and read role to source fibers' do
    batches = []
    listener = ->(_name, _start, _finish, _id, payload) { batches << payload }
    result = ActiveSupport::Notifications.subscribed(listener, 'directory.fetch') do
      execute('a', @people.map(&:id))
    end
    assert_nil result['errors']
    assert_equal(['Manager'] * 3, result.dig('data', 'people').map { |person| person.dig('manager', 'name') })
    assert_equal 2, batches.size
    assert_equal 3, batches.first.fetch(:ids).size
    assert(batches.all? { |batch| batch[:tenant] == 'a' && batch[:role] == :reading })
    assert_nil Directory::Current.tenant
    assert_equal :writing, ApplicationRecord.current_role
    assert_empty busy_read_connections
  end

  test 'multiplex source caches cannot mix tenant identities' do
    result = Directory::Schema.multiplex([
                                           { query: query, variables: { ids: [@other.id] },
                                             context: { tenant: 'a', role: :reading } },
                                           { query: query, variables: { ids: [@other.id] },
                                             context: { tenant: 'b', role: :reading } }
                                         ])
    assert_equal [nil], result[0].dig('data', 'people')
    assert_equal 'Private', result[1].dig('data', 'people', 0, 'name')
    assert_nil Directory::Current.tenant
  end

  test 'concurrent sources overlap while each owns and releases its connection' do
    active = 0
    peak = 0
    listener = lambda do |*args|
      payload = args.last
      next unless payload[:phase] == :start

      active += 1
      peak = [peak, active].max
      ApplicationRecord.connection.execute('SELECT pg_sleep(0.05)')
      active -= 1
    end
    # A start notification runs inside each checked-out source connection.
    Directory::PeopleSource.prepend(SourceStartProbe) unless Directory::PeopleSource < SourceStartProbe
    ActiveSupport::Notifications.subscribed(listener, 'directory.probe') do
      Directory::Schema.multiplex(%w[a b].map do |tenant|
        { query: query, variables: { ids: [@manager.id] }, context: { tenant: tenant, role: :reading } }
      end)
    end
    assert_equal 2, peak
    assert_equal 0, active
    assert_nil Directory::Current.tenant
  end

  test 'source failure restores context and releases connections' do
    listener = ->(*) { raise IOError, 'source unavailable' }
    assert_raises(IOError) do
      ActiveSupport::Notifications.subscribed(listener, 'directory.fetch') { execute('a', [@manager.id]) }
    end
    assert_nil Directory::Current.tenant
    assert_equal :writing, ApplicationRecord.current_role
    assert_empty busy_read_connections
    assert_nil execute('a', [@manager.id])['errors']
  end

  module SourceStartProbe
    def fetch(ids)
      Directory::Current.set(tenant: @tenant) do
        ApplicationRecord.connected_to(role: @role, prevent_writes: true) do
          ApplicationRecord.connection_pool.with_connection(prevent_permanent_checkout: true) do
            ActiveSupport::Notifications.instrument('directory.probe', phase: :start)
            super
          end
        end
      end
    end
  end

  private

  def busy_read_connections
    ApplicationRecord.connection_handler.connection_pool_list(:reading).flat_map(&:connections).select(&:in_use?)
  end

  def query
    'query($ids: [ID!]!) { people(ids: $ids) { name manager { name } } }'
  end

  def execute(tenant, ids)
    Directory::Schema.execute(query, variables: { ids: ids }, context: { tenant: tenant, role: :reading })
  end
end
