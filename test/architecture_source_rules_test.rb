# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/conventions/source_check'

class ArchitectureSourceRulesTest < FoundryTest
  def test_pure_domain_rules_are_scoped_to_configured_domain_layer
    write('components/billing/app/domain/billing/entities/invoice.rb', <<~RUBY)
      module Billing
        class Invoice
          def call
            ActiveRecord::Base.transaction { Rails.logger.info('billing') }
          end
        end
      end
    RUBY
    write('components/billing/app/queries/billing/invoice.rb', 'ActiveRecord::Base.connection.select_all("SELECT 1")')
    result = check
    refute result['success']
    assert_equal ['source.domain_dependency'], result['diagnostics'].map { |item| item['rule'] }.uniq
    assert(result['diagnostics'].all? { |item| item['line'] == 4 })
    assert check(profile: 'modular')['success']
  end

  def test_delivery_provider_calls_and_query_writes_are_explicit_errors
    write('app/models/invoice.rb', 'class Invoice < ApplicationRecord; end')
    write('app/queries/invoices.rb', 'Invoice.where(active: true).update_all(active: false)')
    write('app/controllers/chat_controller.rb', 'RubyLLM.chat.ask("hello")')
    result = check
    refute result['success']
    assert_equal %w[source.delivery_provider source.query_write], result['diagnostics'].map { |item|
      item['rule']
    }.uniq.sort
    assert(result['diagnostics'].all? { |item| item['severity'] == 'error' && item['certainty'] == 'detected' })
  end

  def test_transactions_callbacks_and_projection_writes_are_advisory
    write('app/models/invoice.rb', <<~RUBY)
      class Invoice < ApplicationRecord
        after_commit :notify
        def notify
          RubyLLM.chat.ask('notification')
        end
      end
    RUBY
    write('app/services/charge.rb', <<~RUBY)
      ApplicationRecord.transaction do
        RubyLLM.chat.ask('within transaction')
      end
      RubyLLM.chat.ask('outside transaction')
    RUBY
    write('app/projections/invoice_projection.rb', 'Invoice.update_all(active: true)')
    result = check
    assert result['success']
    warnings = result['diagnostics']
    locations = warnings.map { |item| [item['file'], item['line']] }.uniq
    assert_includes locations, ['app/services/charge.rb', 2]
    refute_includes locations, ['app/services/charge.rb', 4]
    assert_includes locations, ['app/models/invoice.rb', 4]
    assert(warnings.any? { |item| item['rule'] == 'source.projection_write' })
    assert_equal ['warning'], warnings.map { |item| item['severity'] }.uniq
    assert_equal ['inferred'], warnings.map { |item| item['certainty'] }.uniq
  end

  def test_comments_literals_native_reads_and_non_persistence_objects_are_not_writes
    write('app/queries/invoices.rb', <<~RUBY)
      # RubyLLM.chat; Invoice.update_all(active: false)
      TEXT = 'ApplicationRecord.transaction { RubyLLM.chat }'
      Invoice.pluck(:id)
      Report.create(title: 'an in-memory report')
    RUBY
    write('app/models/invoice.rb', 'class Invoice < ApplicationRecord; end')
    write('app/models/report.rb', 'class Report; end')
    write('app/controllers/chat_controller.rb', 'Support::Reply.new.call(params)')
    result = check
    assert result['success']
    assert_empty result['diagnostics']
  end

  private

  def check(profile: 'domain')
    contexts = [{ 'path' => 'components/billing', 'namespace' => 'Billing', 'profile' => profile }]
    RailsAIFoundry::Conventions::SourceCheck.new(@root, contexts: contexts, packages: ['components/billing']).call
  end
end
