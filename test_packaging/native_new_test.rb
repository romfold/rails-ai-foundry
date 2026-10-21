# frozen_string_literal: true

require_relative '../test/test_helper'
require_relative 'archive_helper'

class NativeNewTest < FoundryTest
  include ArchiveAcceptance

  def test_native_rails_new_from_installed_gem
    create_application('sqlite3')
    verify_application
  end

  def test_postgresql_defaults_without_a_cache_service
    create_application('postgresql')
    gemfile = File.read(File.join(@app, 'Gemfile'))
    assert_match(/gem ["']pg["']/, gemfile)
    refute_match(/^\s*gem ["'](?:redis|solid_cache|solid_cable)["']/, gemfile)
    assert_includes File.read(File.join(@app, 'config/database.yml')), 'adapter: postgresql'
    assert_includes File.read(File.join(@app, 'config/cable.yml')), 'adapter: postgresql'
    assert_equal 1, Dir[File.join(@app, 'db/migrate/*_create_solid_queue_tables.rb')].size
  end

  private

  def create_application(database)
    build_archive
    prepare_host
    @app = @root
    assert_command(RbConfig.ruby, '-S', 'gem', 'install', @archive, '--local', '--ignore-dependencies',
                   '--no-document', '--install-dir', @gem_home)
    prepare_local_bundle
    foundry = File.join(@gem_home, 'bin/foundry')
    selection = workflow == 'spec-kit' ? [] : ["--specs=#{workflow}"]
    assert_command(RbConfig.ruby, foundry, 'new', 'native_shop', *selection, "--database=#{database}",
                   '--skip-git', '--skip-dev-gems', extra_env: creation_environment)
    @app = File.join(@root, 'native_shop')
  end

  def prepare_local_bundle
    write('local_bundle.rb', <<~RUBY)
      gem 'json', '>= 2.9', '< 3'
      gem 'railties', '#{Gem.loaded_specs.fetch('railties').version}'
      require 'rails/generators/rails/app/app_generator'
      module FoundryLocalNativeBundle
        def run_bundle
          bundle_command('install --local') if bundle_install?
        end
        def add_bundler_platforms
          say 'Archive acceptance keeps the local platform lock.'
        end
      end
      Rails::Generators::AppBase.prepend(FoundryLocalNativeBundle)
    RUBY
  end

  def creation_environment
    bins = [File.join(@gem_home, 'bin')] + Gem.path.map { |path| File.join(path, 'bin') }
    paths = bins + [RbConfig::CONFIG.fetch('bindir')] + ENV.fetch('PATH').split(File::PATH_SEPARATOR)
    { 'BUNDLE_GEMFILE' => nil, 'SHELL' => '/bin/sh', 'ZDOTDIR' => @root,
      'PATH' => paths.uniq.join(File::PATH_SEPARATOR),
      'RUBYOPT' => "-r#{File.join(@root, 'network_guard.rb')} -r#{File.join(@root, 'local_bundle.rb')}" }
  end

  def verify_application
    assert_provenance
    refute File.exist?(File.join(@app, 'config/architecture.yml'))
    refute File.exist?(File.join(@app, '.foundry/new-in-progress'))
    refute File.exist?(File.join(@app, 'db/queue_schema.rb'))
    assert File.file?(File.join(@app, '.agents/skills/foundry-add-feature/SKILL.md'))
    configuration = YAML.safe_load_file(File.join(@app, 'config/foundry.yml'))
    assert_equal workflow.tr('-', '_'), configuration.dig('workflow', 'specs')
    verify_workflow
    verify_delivery
  end

  def verify_delivery
    rails('db:prepare')
    write('native_shop/app/jobs/probe_job.rb', <<~RUBY)
      class ProbeJob < ApplicationJob
        def perform
        end
      end
    RUBY
    rails('runner', 'before = SolidQueue::Job.count; ProbeJob.perform_later; ' \
                    'raise unless SolidQueue::Job.count == before + 1')
    rails('generate', 'foundry:context', 'billing')
    rails('generate', 'foundry:command', 'charge', '--context=billing')
    rails('generate', 'foundry:context', 'api', '--namespace=Platform::API')
    rails('generate', 'foundry:query', 'lookup', '--context=api')
    verify_loading
  end

  def verify_loading
    rails('runner', 'Rails.application.eager_load!; raise unless Billing::Charge.superclass == Dry::Operation; ' \
                    'raise unless ApplicationJob.queue_adapter.class.name == "ActiveJob::QueueAdapters::SolidQueueAdapter"')
    rails('runner', 'Rails.application.eager_load!; raise if defined?(RailsAIFoundry); ' \
                    'raise unless Billing::Charge.superclass == Dry::Operation; ' \
                    'raise unless Platform::API::Lookup.superclass == Object; ' \
                    'raise unless "api".camelize == "Api"',
          extra_env: { 'BUNDLE_WITHOUT' => 'development:test', 'RAILS_ENV' => 'production',
                       'SECRET_KEY_BASE' => 'offline-test-secret' * 8 })
  end

  def workflow
    ENV.fetch('FOUNDRY_ACCEPTANCE_WORKFLOW', 'none')
  end

  def verify_workflow
    return if workflow == 'none'

    marker = workflow == 'spec-kit' ? '.specify/memory/constitution.md' : 'openspec/config.yaml'
    assert File.file?(File.join(@app, marker))
  end
end
