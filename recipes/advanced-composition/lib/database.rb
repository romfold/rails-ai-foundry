# frozen_string_literal: true

require 'rom-sql'
require 'uri'

module Billing
  module Database
    def self.validate!(url)
      uri = URI(url)
      return if %w[localhost 127.0.0.1].include?(uri.host) && uri.path == '/foundry_composition_test'

      raise ArgumentError, 'Recipe requires the disposable loopback foundry_composition_test database'
    end

    def self.connect(url)
      validate!(url)
      ROM.container(:sql, url) do |configuration|
        configuration.relation(:orders) { schema(infer: true) }
        configuration.relation(:outbox) { schema(infer: true) }
        configuration.relation(:receipts) { schema(infer: true) }
      end
    end

    def self.prepare(url)
      validate!(url)
      gateway = ROM::SQL::Gateway.new(url)
      db = gateway.connection
      db.create_table?(:orders) do
        primary_key :id
        Integer :cents, null: false
      end
      db.create_table?(:outbox) do
        primary_key :id
        foreign_key :order_id, :orders, null: false, unique: true
        String :event_id, null: false, unique: true
        String :status, null: false, default: 'pending'
        String :error
      end
      db.create_table?(:receipts) do
        String :event_id, primary_key: true
        Integer :cents, null: false
      end
      gateway.disconnect
    end
  end
end
