# frozen_string_literal: true

require 'dry/operation'

module Ledger
  module Commands
    class PostMoney < Dry::Operation
      skip_prepending

      def initialize(store: RailsEventStore::JSONClient.new)
        @store = store
        super()
      end

      def call(tenant:, account_id:, cents:, expected_version:)
        return Failure(:invalid_amount) unless valid_amount?(cents)

        stream = "Ledger$#{tenant}$#{account_id}"
        account = load_account(stream)
        return Failure(:conflict) unless account.version == expected_version
        return Failure(:insufficient_funds) if (account.balance + cents).negative?

        event = MoneyPosted.new(data: { cents: cents })
        @store.append(event, stream_name: stream, expected_version: expected_version)
        Success(load_account(stream))
      rescue RubyEventStore::WrongExpectedEventVersion
        Failure(:conflict)
      end

      private

      def load_account(stream)
        Account.new(@store.read.stream(stream).to_a)
      end

      def valid_amount?(cents)
        cents.is_a?(Integer) && cents.nonzero? && cents.abs <= 1_000_000_000
      end
    end
  end
end
