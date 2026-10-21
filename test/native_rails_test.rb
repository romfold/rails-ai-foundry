# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/conventions/context_installer'
require 'rails_ai_foundry/conventions/component_installer'

class NativeRailsTest < FoundryTest
  def setup
    super
    FileUtils.cp_r(Dir[File.expand_path('runtime_host/*', __dir__)], @root)
    write('Gemfile', '# The subprocess uses the managed test bundle.')
    application = File.read(File.join(@root, 'config/application.rb'))
    application = application.sub("require 'rails_ai_foundry'", <<~RUBY.chomp)
      require 'active_record/railtie'
      require 'active_job/railtie'
      require 'packs-rails'
      require 'rails_ai_foundry'
    RUBY
    write('config/application.rb', application)
    write('config/database.yml', "development:\n  adapter: sqlite3\n  database: ':memory:'\n")
    write('app/models/application_record.rb',
          "class ApplicationRecord < ActiveRecord::Base\n  self.abstract_class = true\nend\n")
    write('app/controllers/application_controller.rb', "class ApplicationController < ActionController::Base\nend\n")
    write('app/jobs/application_job.rb', "class ApplicationJob < ActiveJob::Base\nend\n")
  end

  def test_upstream_rails_loading_delivery_and_native_transaction_results
    write('config/foundry.yml', "defaults:\n  profile: rails_native\n  patterns:\n    cqrs: queries\n")
    rails('generate', 'foundry:context', 'billing', '--profile=domain', '--events=integration')
    intent = RailsAIFoundry::Conventions::Intent.load(@root, 'packs/billing')
    assert_equal 'domain', intent.profile
    assert_equal({ 'events' => 'integration', 'cqrs' => 'queries' }, intent.data['patterns'])
    rails('generate', 'foundry:command', 'charge', '--context=billing')
    %w[model controller job].zip(%w[invoice invoices notify]).each do |kind, name|
      rails('generate', "foundry:#{kind}", name, '--context=billing')
    end
    implement_delivery
    write('verify.rb', File.read(File.expand_path('support/native_transaction_assertions.rb', __dir__)))
    assert_includes rails('runner', 'verify.rb'), 'native transaction and delivery acceptance passed'
  end

  private

  def implement_delivery
    write('packs/billing/app/controllers/billing/invoices_controller.rb', <<~RUBY)
      class Billing::InvoicesController < ApplicationController
        def index
          @total = Billing::Invoice.count
        end
      end
    RUBY
    write('packs/billing/app/views/billing/invoices/index.html.erb', 'Invoices: <%= @total %>')
    write('config/routes.rb', "Rails.application.routes.draw { get '/invoices', to: 'billing/invoices#index' }\n")
    write('packs/billing/app/jobs/billing/notify_job.rb', <<~RUBY)
      class Billing::NotifyJob < ApplicationJob
        def perform
          Billing::Invoice.create!(amount: 9)
        end
      end
    RUBY
  end

  def rails(*arguments)
    env = { 'BUNDLE_GEMFILE' => File.expand_path(ENV.fetch('BUNDLE_GEMFILE', File.expand_path('../Gemfile', __dir__))),
            'RAILS_ENV' => 'development', 'FOUNDRY_AUTOLOAD' => '0' }
    output, error, status = Open3.capture3(env, RbConfig.ruby, 'bin/rails', *arguments, chdir: @root)
    assert status.success?, "#{output}\n#{error}"
    output
  end
end
