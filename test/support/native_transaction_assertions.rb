# frozen_string_literal: true

Rails.application.eager_load!
raise 'Foundry runtime loaded' if defined?(RailsAIFoundry::Runtime)
raise 'Wrong superclass' unless Billing::Commands::Charge.superclass == Dry::Operation
raise 'Wrong model superclass' unless Billing::Invoice.superclass == ApplicationRecord

ActiveRecord::Schema.define do
  create_table(:billing_invoices) { |table| table.integer :amount }
end

module Billing
  module Commands
    class Charge
      private

      def perform(input)
        Billing::Invoice.create!(amount: 42)
        raise 'write failed' if input == :exception

        input == :failure ? Failure(:declined) : Success(42)
      end
    end
  end
end

command = Billing::Commands::Charge.new
result = command.call(:success)
raise 'Nested result boundary' unless result.success? && result.value! == 42
raise 'Success not committed' unless Billing::Invoice.one?

result = command.call(:failure)
raise 'Lost native failure' unless result.failure? && result.failure == :declined
raise 'Failure committed' unless Billing::Invoice.one?

begin
  command.call(:exception)
  raise 'Exception was swallowed'
rescue RuntimeError => e
  raise unless e.message == 'write failed'
end
raise 'Exception committed' unless Billing::Invoice.one?

ApplicationRecord.transaction do
  Billing::Invoice.create!(amount: 1)
  command.call(:failure)
  raise 'Nested failure leaked or rolled back its caller' unless Billing::Invoice.count == 2
end

ApplicationRecord.transaction do
  Billing::Invoice.create!(amount: 2)
  raise ActiveRecord::Rollback if command.call(:failure).failure?
end
raise 'Outer rollback failed' unless Billing::Invoice.count == 2

Billing::NotifyJob.perform_now
raise 'Pack job failed' unless Billing::Invoice.count == 3

session = ActionDispatch::Integration::Session.new(Rails.application)
session.host! 'localhost'
session.get '/invoices'
raise "Pack route/view failed: #{session.response.status}" unless session.response.body.include?('Invoices: 3')

Rails.application.reloader.reload!
raise 'Ordinary reload failed' unless Billing::Commands::Charge.superclass == Dry::Operation

puts 'native transaction and delivery acceptance passed'
