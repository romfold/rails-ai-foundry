# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/conventions/context_installer'
require 'rails_ai_foundry/conventions/component_installer'
require 'rails_ai_foundry/conventions/agent_installer'

class NamespaceInflectionsTest < FoundryTest
  def setup
    super
    write('Gemfile', '# consumer')
    write('config/application.rb', "raise 'must not boot'\n")
  end

  def test_preview_customization_and_repeated_generation
    before = snapshot
    assert(context.call(pretend: true).any? { |action| action.include?('config/initializers/') })
    assert_equal before, snapshot
    context.call
    original = snapshot
    write(initializer, "#{File.read(File.join(@root, initializer))}# customized\n")
    customized = snapshot
    context.call
    assert_equal customized, snapshot
    component.call
    assert_equal customized[initializer], snapshot[initializer]
    assert_equal original[receipt], snapshot[receipt]
    before = snapshot
    component.call
    assert_equal before, snapshot
  end

  def test_missing_or_unowned_initializer_refuses_before_primary_writes
    context.call
    File.unlink(File.join(@root, receipt))
    before = snapshot
    [true, false].each do |pretend|
      assert_raises(RailsAIFoundry::InstallationError) { component.call(pretend: pretend) }
      assert_equal before, snapshot
    end
    File.unlink(File.join(@root, initializer))
    component.call
    File.unlink(File.join(@root, initializer))
    before = snapshot
    assert_raises(RailsAIFoundry::InstallationError) { component('other').call }
    assert_equal before, snapshot
  end

  def test_existing_context_gains_inflections_only_with_new_generation
    context.call
    component.call
    remove_inflections
    before = snapshot
    context.call
    component.call
    assert_equal before, snapshot
    component('other').call
    assert File.file?(File.join(@root, initializer))
    assert_equal before['packs/api/.foundry/context.yml'], snapshot['packs/api/.foundry/context.yml']
  end

  def test_new_agent_installs_inflections_but_complete_repeat_does_not_repair
    context.call
    remove_inflections
    agent.call
    assert File.file?(File.join(@root, initializer))
    remove_inflections
    before = snapshot
    agent.call
    assert_equal before, snapshot
  end

  def test_conflicting_namespace_segments_in_both_orders_and_inside_one_namespace
    context.call
    before = snapshot
    [true, false].each do |pretend|
      error = assert_raises(RailsAIFoundry::ConfigurationError) do
        context('other', 'Api::Client').call(pretend: pretend)
      end
      assert_includes error.message, 'API'
      assert_includes error.message, 'Api'
      assert_equal before, snapshot
    end
    assert_raises(RailsAIFoundry::ConfigurationError) { context('nested', 'GraphQL::GraphQl').call }
    assert_equal before, snapshot
    context('ordinary', 'Platform::ApiClient').call
    before = snapshot
    assert_raises(RailsAIFoundry::ConfigurationError) { context('client', 'APIClient').call }
    assert_equal before, snapshot
  end

  def test_symlink_initializer_refuses_without_writing_context
    write('external.rb', '# existing')
    FileUtils.mkdir_p(File.join(@root, 'config/initializers'))
    File.symlink(File.join(@root, 'external.rb'), File.join(@root, initializer))
    before = snapshot
    assert_raises(RailsAIFoundry::InstallationError, RailsAIFoundry::ConfigurationError) { context.call }
    assert_equal before, snapshot
  end

  def test_failure_writing_inflection_receipt_rolls_back_primary_and_initializer
    before = snapshot
    original = File.method(:open)
    File.stub(:open, lambda { |path, *args, &block|
      raise Errno::ENOSPC, 'injected receipt failure' if path.to_s.end_with?(receipt)

      original.call(path, *args, &block)
    }) do
      assert_raises(RailsAIFoundry::InstallationError) { context.call }
    end
    assert_equal before, snapshot
  end

  def test_fresh_rails_process_loads_acronyms_without_foundry_or_global_inflection_changes
    FileUtils.cp_r(Dir[File.expand_path('runtime_host/*', __dir__)], @root)
    application = File.read(File.join(@root, 'config/application.rb')).sub("require 'rails_ai_foundry'",
                                                                           "require 'packs-rails'")
    write('config/application.rb', application)
    %w[API APIClient GraphQL Platform::API::Client].each_with_index do |namespace, index|
      name = "context_#{index}"
      context(name, namespace).call
      RailsAIFoundry::Conventions::ComponentInstaller.new(@root, 'lookup', context: name, kind: 'query').call
    end
    code = <<~RUBY
      Rails.application.eager_load!
      [API::Lookup, APIClient::Lookup, GraphQL::Lookup, Platform::API::Client::Lookup].each do |constant|
        raise 'wrong superclass' unless constant.superclass == Object
      end
      raise 'global inflections changed' unless 'api'.camelize == 'Api'
      foundry = $LOADED_FEATURES.grep(%r{/rails_ai_foundry/})
      raise 'Foundry runtime loaded' unless foundry.all? { |path| path.end_with?('/version.rb') }
    RUBY
    env = { 'BUNDLE_GEMFILE' => File.expand_path(ENV.fetch('BUNDLE_GEMFILE', 'Gemfile')),
            'RAILS_ENV' => 'production' }
    output, error, status = Open3.capture3(env, RbConfig.ruby, 'bin/rails', 'runner', code, chdir: @root)
    assert status.success?, "#{output}\n#{error}"
  end

  private

  def context(name = 'api', namespace = 'API')
    capabilities = { 'ai' => { 'adapter' => 'ruby_llm' } }
    RailsAIFoundry::Conventions::ContextInstaller.new(@root, name, namespace: namespace,
                                                                   capabilities: capabilities)
  end

  def component(name = 'lookup')
    RailsAIFoundry::Conventions::ComponentInstaller.new(@root, name, context: 'api', kind: 'query')
  end

  def agent
    RailsAIFoundry::Conventions::AgentInstaller.new(@root, 'answer', context: 'api')
  end

  def initializer
    "config/initializers/foundry_inflections_#{Digest::SHA256.hexdigest('packs/api')}.rb"
  end

  def receipt
    'packs/api/.foundry/inflections.yml'
  end

  def remove_inflections
    File.unlink(File.join(@root, initializer))
    File.unlink(File.join(@root, receipt))
  end
end
