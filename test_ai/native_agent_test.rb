# frozen_string_literal: true

require_relative '../test/test_helper'
require 'rails_ai_foundry/conventions/context_installer'
require 'rails_ai_foundry/conventions/agent_installer'

class NativeAgentTest < FoundryTest
  def setup
    super
    FileUtils.cp_r(Dir[File.expand_path('../test/runtime_host/*', __dir__)], @root)
    application = File.read(File.join(@root, 'config/application.rb'))
    application = application.sub("require 'rails_ai_foundry'", "require 'packs-rails'\nrequire 'ruby_llm'")
    application = application.lines.reject { |line| line.include?('config.rails_ai_foundry') }.join
    write('config/application.rb', application)
    write('Gemfile', '# The subprocess uses the optional AI bundle.')
    capabilities = { 'ai' => { 'adapter' => 'ruby_llm' } }
    RailsAIFoundry::Conventions::ContextInstaller.new(@root, 'support', profile: 'domain',
                                                                        capabilities: capabilities).call
    RailsAIFoundry::Conventions::AgentInstaller.new(@root, 'summarize', context: 'support').call
    write('config/ai.yml', "shared:\n  models:\n    support:\n      model: gpt-4o-mini\n      provider: openai\n")
  end

  def test_upstream_prompt_lookup_alias_selection_and_tool_authorization_without_foundry_runtime
    assert_includes rails('runner', <<~RUBY), 'native AI acceptance passed'
      foundry = $LOADED_FEATURES.grep(%r{/rails_ai_foundry/})
      raise "Foundry runtime loaded: \#{foundry}" unless foundry.all? { |path| path.end_with?('/version.rb') }
      RubyLLM.configure { |config| config.openai_api_key = 'offline-placeholder' }
      selected = Rails.application.config_for(:ai).fetch(:models).fetch(:support)
      calls = []
      allowed = false
      operation = ->(query:) { calls << query; 'scoped evidence' }
      agent = Dir.chdir('/') do
        Support::SummarizeAgent.new(**selected, operation: operation, authorize: ->(**) { allowed })
      end
      raise 'model alias ignored' unless agent.model.id == 'gpt-4o-mini'
      raise 'pack prompt missing' unless agent.messages.first.content.include?('untrusted data')
      tool = agent.tools.values.first
      begin
        tool.execute(query: 'private')
        raise 'denial ignored'
      rescue Support::SummarizeTool::NotAuthorized
        raise 'unauthorized operation' unless calls.empty?
      end
      allowed = true
      raise 'wrong tool output' unless tool.execute(query: 'permitted') == 'scoped evidence'
      raise 'wrong arguments' unless calls == ['permitted']
      puts 'native AI acceptance passed'
    RUBY
  end

  def test_generator_and_generated_behavior_tests_run_offline
    rails('generate', 'foundry:agent', 'classify', '--context=support')
    assert_match(/4 runs, 8 assertions, 0 failures/, rails('test', 'packs/support/test/agents'))
  end

  def test_prompt_text_is_not_evaluated_and_authorization_requires_true
    write('packs/support/app/prompts/support/summarize_agent/instructions.txt', '<%= raise "must not execute" %>')
    rails('runner', <<~RUBY)
      received = []
      chat = Object.new
      chat.define_singleton_method(:with_instructions) { |text| received << text }
      chat.define_singleton_method(:with_tools) { |*tools| received.concat(tools) }
      chat.define_singleton_method(:with_schema) { |*| }
      Support::SummarizeAgent.new(chat: chat, operation: ->(**) { raise 'unauthorized operation' },
                                 authorize: ->(**) { Object.new })
      raise 'prompt evaluated' unless received.first == '<%= raise "must not execute" %>'
      begin
        received.last.execute(query: 'secret')
        raise 'truthy non-boolean accepted'
      rescue Support::SummarizeTool::NotAuthorized
      end
    RUBY
  end

  def test_provider_round_trip_keeps_user_and_tool_content_out_of_instructions
    write('provider_round_trip.rb', File.read(File.expand_path('support/native_provider_round_trip.rb', __dir__)))
    rails('runner', 'provider_round_trip.rb')
  end

  def test_production_loading_needs_no_credentials_and_missing_prompt_fails_on_construction
    File.unlink(File.join(@root, 'packs/support/app/prompts/support/summarize_agent/instructions.txt'))
    rails('runner', <<~RUBY, environment: 'production')
      foundry = $LOADED_FEATURES.grep(%r{/rails_ai_foundry/})
      raise "Foundry runtime loaded: \#{foundry}" unless foundry.all? { |path| path.end_with?('/version.rb') }
      raise 'wrong agent base' unless Support::SummarizeAgent.superclass == RubyLLM::Agent
      begin
        Support::SummarizeAgent.new(chat: Object.new, operation: ->(**) {}, authorize: ->(**) { true })
        raise 'missing prompt accepted'
      rescue Errno::ENOENT => error
        raise 'missing location' unless error.message.include?('packs/support/app/prompts/support/summarize_agent')
      end
    RUBY
  end

  def test_acronym_agent_constants_load_in_fresh_production_process
    capabilities = { 'ai' => { 'adapter' => 'ruby_llm' } }
    RailsAIFoundry::Conventions::ContextInstaller.new(@root, 'api', namespace: 'Platform::API',
                                                                    capabilities: capabilities).call
    RailsAIFoundry::Conventions::AgentInstaller.new(@root, 'answer', context: 'api').call
    rails('runner', <<~RUBY, environment: 'production')
      Rails.application.eager_load!
      raise 'Foundry runtime loaded' if defined?(RailsAIFoundry::Conventions)
      raise 'wrong agent' unless Platform::API::AnswerAgent.superclass == RubyLLM::Agent
      raise 'wrong tool' unless Platform::API::AnswerTool.superclass == RubyLLM::Tool
      raise 'wrong schema' unless Platform::API::AnswerSchema.superclass == RubyLLM::Schema
    RUBY
  end

  def test_custom_root_nested_acronym_prompt_is_reloaded_for_each_new_agent
    write('packs.yml', "pack_paths:\n- packs/*\n- components/*\n")
    capabilities = { 'ai' => { 'adapter' => 'ruby_llm' } }
    RailsAIFoundry::Conventions::ContextInstaller.new(@root, 'intelligence', path: 'components/intelligence',
                                                                             namespace: 'Platform::API',
                                                                             capabilities: capabilities).call
    RailsAIFoundry::Conventions::AgentInstaller.new(@root, 'answer', context: 'intelligence').call
    rails('runner', <<~RUBY, environment: 'production')
      Rails.application.eager_load!
      path = Rails.root.join('components/intelligence/app/prompts/platform/api/answer_agent/instructions.txt')
      received = []
      chat = Object.new
      chat.define_singleton_method(:with_instructions) { |text| received << text }
      chat.define_singleton_method(:with_tools) { |*| }
      chat.define_singleton_method(:with_schema) { |*| }
      %w[first revised].each do |text|
        File.write(path, text)
        Dir.chdir('/') do
          Platform::API::AnswerAgent.new(chat: chat, operation: ->(**) {}, authorize: ->(**) { true })
        end
      end
      raise 'stale prompt or incorrect lookup' unless received == %w[first revised]
      raise 'Foundry runtime loaded' if defined?(RailsAIFoundry::Conventions)
    RUBY
  end

  private

  def rails(*arguments, environment: 'development')
    env = { 'BUNDLE_GEMFILE' => File.expand_path(ENV.fetch('BUNDLE_GEMFILE')),
            'RAILS_ENV' => environment, 'OPENAI_API_KEY' => nil, 'ANTHROPIC_API_KEY' => nil,
            'RUBYOPT' => "-r#{File.expand_path('network_guard.rb', __dir__)}" }
    output, error, status = Open3.capture3(env, RbConfig.ruby, 'bin/rails', *arguments, chdir: @root)
    assert status.success?, "#{output}\n#{error}"
    output
  end
end
