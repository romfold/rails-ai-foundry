# frozen_string_literal: true

require_relative '../test/test_helper'
require_relative '../test_packaging/archive_helper'

class NativeAIArchiveTest < FoundryTest
  include ArchiveAcceptance

  def test_native_agent_from_installed_gem_executes_without_foundry
    build_archive
    assert_includes Gem::Package.new(@archive).contents, 'docs/native-ai.md'
    prepare_host
    prepare_native_bundle
    assert_command(RbConfig.ruby, '-S', 'gem', 'install', @archive, '--local', '--ignore-dependencies',
                   '--no-document', '--install-dir', @gem_home)
    assert_command(RbConfig.ruby, '-S', 'bundle', 'install', '--local')
    assert_provenance
    rails('generate', 'foundry:context', 'support')
    intent = YAML.safe_load_file(File.join(@app, 'packs/support/foundry.yml'))
    intent['capabilities'] = { 'ai' => { 'adapter' => 'ruby_llm' } }
    write('app/packs/support/foundry.yml', YAML.dump(intent))
    rails('generate', 'foundry:agent', 'summarize', '--context=support')
    assert_match(/2 runs, 4 assertions, 0 failures/, rails('test', 'packs/support/test/agents'))
    verify_production
  end

  private

  def prepare_native_bundle
    gemfile = File.read(File.join(@app, 'Gemfile'))
    gemfile = gemfile.sub(/^gem 'rails_ai_foundry', (.*)$/, "gem 'rails_ai_foundry', \\1, group: [:development, :test]")
    write('app/Gemfile', "#{gemfile}\ngem 'ruby_llm', '1.16.0', require: false\ngem 'packs-rails', '~> 0.1.0'\n")
    application = File.read(File.join(@app, 'config/application.rb'))
    application = application.sub("require 'rails_ai_foundry'", "require 'packs-rails'\nrequire 'ruby_llm'")
    write('app/config/application.rb', application.lines.reject do |line|
      line.include?('config.rails_ai_foundry')
    end.join)
  end

  def verify_production
    rails('runner', <<~RUBY, extra_env: { 'RAILS_ENV' => 'production', 'BUNDLE_WITHOUT' => 'development:test' })
      raise 'Foundry loaded' if defined?(RailsAIFoundry)
      received = []
      chat = Object.new
      chat.define_singleton_method(:with_instructions) { |text| received << text }
      chat.define_singleton_method(:with_tools) { |*tools| received.concat(tools) }
      chat.define_singleton_method(:with_schema) { |schema| received << schema }
      Dir.chdir('/') do
        Support::SummarizeAgent.new(chat: chat, operation: ->(query:) { query }, authorize: ->(**) { true })
      end
      raise 'prompt missing' unless received.first.include?('untrusted data')
      raise 'tool missing' unless received[1].execute(query: 'evidence') == 'evidence'
      raise 'schema missing' unless received.last == Support::SummarizeSchema
    RUBY
  end
end
