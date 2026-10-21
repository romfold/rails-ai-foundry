# frozen_string_literal: true

require_relative '../test/test_helper'
require_relative 'archive_helper'

class NativeWorkflowTest < FoundryTest
  include ArchiveAcceptance

  def test_installed_archive_generates_native_context_and_workflow_neutral_skills
    build_archive
    prepare_host
    write('app/app/models/application_record.rb',
          "class ApplicationRecord < ActiveRecord::Base\n  self.abstract_class = true\nend\n")
    File.open(File.join(@app, 'Gemfile'), 'a') { |file| file.puts "gem 'packs-rails', '~> 0.1.0'" }
    application = File.read(File.join(@app, 'config/application.rb'))
    write('app/config/application.rb',
          application.sub("require 'rails_ai_foundry'", "require 'packs-rails'\nrequire 'rails_ai_foundry'"))
    install_archive
    assert_provenance
    foundry = File.join(@gem_home, 'bin/foundry')
    assert_command(RbConfig.ruby, foundry, 'setup', '--specs=none')
    assert_command(RbConfig.ruby, foundry, 'doctor')
    rails('generate', 'foundry:context', 'billing', '--profile=modular')
    verify_native_generators
    verify_native_operation
    verify_native_assessment(foundry)
    rails('generate', 'foundry:skills', '--target=cursor')
    path = File.join(@app, '.cursor/skills/foundry-add-feature/references/spec-kit.md')
    assert_includes File.read(path), 'Specify CLI 1.0.0'
    assert File.file?(File.join(@app, '.cursor/skills/foundry-add-feature/references/native-conventions.md'))
  end

  private

  def verify_native_generators
    probe = File.expand_path('../test/support/native_generator_isolation.rb', __dir__)
    %w[operation command model query].each do |kind|
      name = kind == 'operation' ? 'quote' : "sample_#{kind}"
      assert_command(RbConfig.ruby, '-r', probe, 'bin/rails', 'generate', "foundry:#{kind}",
                     name, '--context=billing')
    end
    before = snapshot
    output, error, status = command(RbConfig.ruby, 'bin/rails', 'generate', 'foundry:model', 'quote',
                                    '--context=billing')
    refute status.success?, "#{output}\n#{error}"
    assert_includes error, 'Billing::Quote is already generated'
    %w[install setup].each do |kind|
      # Rails 7.1 reports absent generators with exit zero; Rails owns that status.
      output, error, = command(RbConfig.ruby, 'bin/rails', 'generate', "foundry:#{kind}")
      assert_includes output + error, "Could not find generator 'foundry:#{kind}'"
    end
    assert_equal before, snapshot
  end

  def verify_native_assessment(foundry)
    before = snapshot
    assert_command(RbConfig.ruby, foundry, 'adopt', '--format=json')
    assert_command(RbConfig.ruby, foundry, 'check')
    assert_command(RbConfig.ruby, foundry, 'check', '--sources')
    assert_command(RbConfig.ruby, foundry, 'plan', 'refactor', '--context=billing', '--format=json')
    rails('foundry:architecture:sources')
    rails('foundry:check')
    assert_equal before, snapshot
  end

  def install_archive
    assert_command(RbConfig.ruby, '-S', 'gem', 'install', @archive, '--local', '--ignore-dependencies',
                   '--no-document', '--install-dir', @gem_home)
    assert_command(RbConfig.ruby, '-S', 'bundle', 'install', '--local')
  end

  def verify_native_operation
    path = 'app/packs/billing/app/operations/billing/quote.rb'
    source = File.read(File.join(@root, path))
    source = source.sub("raise NotImplementedError, 'Implement behavior and return a native Success or Failure'",
                        'Success(42)')
    write(path, source)
    code = 'Rails.application.eager_load!; raise unless Billing::Quote.superclass == Dry::Operation; ' \
           'raise unless Billing::Quote.new.call(nil).value! == 42; ' \
           'raise if defined?(RailsAIFoundry::Runtime); raise if defined?(RailsAIFoundry::PackageLoading)'
    rails('runner', code)
    rails('generate', 'foundry:operation', 'quote', '--context=billing')
    assert_equal source, File.read(File.join(@root, path))
  end
end
