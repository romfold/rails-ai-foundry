# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
ENV.delete('DATABASE_URL')
abort 'Tests require a loopback database' unless %w[127.0.0.1 localhost ::1].include?(ENV.fetch('PGHOST', '127.0.0.1'))
require_relative '../config/environment'
require 'rails/test_help'
require 'socket'

require_relative 'support/loopback_only'
Socket.singleton_class.prepend(LoopbackOnly::SocketMethods)
TCPSocket.singleton_class.prepend(LoopbackOnly::TCPMethods)

module ActiveSupport
  class TestCase
    self.use_transactional_tests = false

    setup do
      @catalog = Rails.configuration.x.knowledge
      @search = Rails.configuration.x.search
      @store = Rails.configuration.x.event_store
      @principal = Access::Identity.authenticate('demo-a')
      ActiveRecord::Base.connection.execute(
        'TRUNCATE search_rebuild_entries, search_rebuild_runs, knowledge_projection_changes, ' \
        'knowledge_deliveries, knowledge_documents, search_vectors, search_settings, ' \
        'event_store_events_in_streams, event_store_events RESTART IDENTITY CASCADE'
      )
      client = Elasticsearch::Client.new(url: 'http://127.0.0.1:59210')
      client.indices.get(index: 'foundry_knowledge_test*').each_key { |name| client.indices.delete(index: name) }
      @search.setup
    end

    def document(title: 'Refund policy', body: 'Refund payment within thirty days')
      @catalog.change(principal: @principal, action: 'create', attributes: { title: title, body: body }).value!
    end

    def transition(row, action, **options)
      @catalog.change(principal: @principal, action: action, id: row[:id],
                      expected_revision: row[:revision], **options)
    end

    def published
      transition(document, 'publish').value!
    end

    def drain
      DeliveryPollJob.perform_now
      assert(@catalog.queue.status.all? { |row| row[:state] == 'done' })
    end
  end
end
