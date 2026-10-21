# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/cli'

class NativeSourceCheckTest < FoundryTest
  def setup
    super
    write('Gemfile', "raise 'Do not evaluate Gemfile'\n")
    write('config/application.rb', "raise 'Do not boot Rails'\n")
    write('config/foundry.yml', "workflow:\n  specs: none\n")
    write('packs.yml', "pack_paths:\n- components/*\n")
    write('components/billing/package.yml', "{}\n")
    write('components/billing/foundry.yml', "namespace: Billing\nprofile: domain\n")
    write('components/billing/package_todo.yml', '# accepted upstream debt')
  end

  def test_explicit_runtime_references_report_locations_and_replacements_without_execution
    write('components/billing/app/application/billing/charge.rb', <<~RUBY)
      raise 'Never execute package code'
      class Billing::Charge < ::RailsAIFoundry::Command
        def call
          RailsAIFoundry::AI::Agent.new
        end
      end
    RUBY
    write('app/jobs/tool_job.rb', "RailsAIFoundry::Runtime.resolve(:billing)\n")
    before = snapshot
    status, report = check
    assert_equal 1, status
    assert_equal 2, report.fetch('sources').fetch('files_checked')
    findings = report.fetch('sources').fetch('diagnostics')
    assert_equal([1, 2, 4], findings.map { |item| item.fetch('line') })
    assert(findings.all? { |item| item.fetch('certainty') == 'detected' })
    assert_includes findings[1].fetch('message'), 'development-only Foundry'
    assert_includes findings[2].fetch('message'), 'upstream APIs'
    assert_equal before, snapshot
  end

  def test_current_tooling_constants_are_development_only_dependencies
    write('app/models/tool_reference.rb', 'RailsAIFoundry::Conventions::Intent.new({})')
    status, report = check
    assert_equal 1, status
    item = report.fetch('sources').fetch('diagnostics').first
    assert_equal 'source.foundry_dependency', item.fetch('rule')
    assert_equal 'RailsAIFoundry::Conventions::Intent', item.fetch('constant')
  end

  def test_native_code_comments_strings_and_other_namespaces_do_not_trigger_findings
    write('app/models/example.rb', <<~RUBY)
      # RailsAIFoundry::Runtime
      TEXT = 'RailsAIFoundry::Command'
      EXTERNAL = Other::RailsAIFoundry::Operation
      class Invoice < ApplicationRecord; end
      class Charge < Dry::Operation; end
    RUBY
    status, report = check
    assert_equal 0, status
    assert_empty report.fetch('sources').fetch('diagnostics')
    assert_includes report.fetch('sources').fetch('limitations'), 'dynamic lookup'
  end

  def test_unparseable_source_fails_instead_of_claiming_success
    write('app/models/broken.rb', 'class Broken <')
    status, report = check
    assert_equal 1, status
    assert_equal 'source.syntax', report.fetch('sources').fetch('diagnostics').first.fetch('rule')
  end

  def test_source_check_is_explicit_and_adoption_remains_read_only
    write('config/other_tool.yml', "enabled: true\n")
    write('app/models/tool_reference.rb', 'RailsAIFoundry::Record')
    before = snapshot
    status, _report = check(action: 'adopt')
    assert_equal 1, status
    assert_equal before, snapshot
    status, report = check(action: 'adopt', sources: false)
    assert_equal 0, status
    refute report.key?('sources')
  end

  def test_unconfigured_packages_are_checked_alongside_shell_sources
    write('components/search/package.yml', "{}\n")
    write('components/search/app/services/reference.rb', "RailsAIFoundry::Conventions::Intent.new({})\n")
    write('app/models/reference.rb', "RailsAIFoundry::Conventions::Intent.new({})\n")
    before = snapshot
    %w[check adopt].each do |action|
      status, report = check(action: action)
      assert_equal 1, status
      assert_equal 2, report.dig('sources', 'files_checked')
      assert_equal(%w[app/models/reference.rb components/search/app/services/reference.rb],
                   report.dig('sources', 'diagnostics').map { |item| item.fetch('file') })
      assert_equal(['components/billing'], report.fetch('contexts').map { |item| item.fetch('path') })
    end
    assert_equal before, snapshot
  end

  def test_package_only_syntax_failure_cannot_be_hidden_by_a_missing_sidecar
    write('components/search/package.yml', "{}\n")
    write('components/search/app/services/broken.rb', 'class Broken <')
    status, report = check
    assert_equal 1, status
    assert_equal 1, report.dig('sources', 'files_checked')
    assert_equal 'source.syntax', report.dig('sources', 'diagnostics', 0, 'rule')
  end

  def test_symbolic_link_sources_are_rejected_without_reading_target
    write('elsewhere.rb', "raise 'Outside selected source roots'\n")
    FileUtils.mkdir_p(File.join(@root, 'app/models'))
    File.symlink(File.join(@root, 'elsewhere.rb'), File.join(@root, 'app/models/link.rb'))
    error = StringIO.new
    status = RailsAIFoundry::CLI.new.call(['check', "--root=#{@root}", '--sources'],
                                          stdout: StringIO.new, stderr: error)
    assert_equal 1, status
    assert_includes error.string, 'Symbolic links are not supported'
  end

  def test_successful_boundaries_do_not_mask_source_findings
    require 'rails_ai_foundry/conventions/boundary_check'
    write('app/models/tool_reference.rb', 'RailsAIFoundry::Operation')
    checker = Object.new
    checker.define_singleton_method(:call) { { 'success' => true } }
    RailsAIFoundry::Conventions::BoundaryCheck.stub(:new, ->(*) { checker }) do
      stdout = StringIO.new
      status = RailsAIFoundry::CLI.new.call(['check', "--root=#{@root}", '--sources', '--boundaries', '--format=json'],
                                            stdout: stdout, stderr: StringIO.new)
      assert_equal 1, status
      report = JSON.parse(stdout.string)
      assert report.dig('boundaries', 'success')
      refute report.dig('sources', 'success')
    end
  end

  def test_failed_discovery_never_falls_back_to_the_shell
    write('app/models/native.rb', 'Object')
    stdout = StringIO.new
    stderr = StringIO.new
    RailsAIFoundry::Conventions::Contexts.stub(:new, lambda { |*|
      raise RailsAIFoundry::ConfigurationError, 'Discovery failed'
    }) do
      status = RailsAIFoundry::CLI.new.call(['check', "--root=#{@root}", '--sources'], stdout: stdout, stderr: stderr)
      assert_equal 1, status
      assert_empty stdout.string
      assert_includes stderr.string, 'Discovery failed'
    end
  end

  private

  def check(action: 'check', sources: true)
    stdout = StringIO.new
    arguments = [action, "--root=#{@root}", '--format=json']
    arguments << '--sources' if sources
    status = RailsAIFoundry::CLI.new.call(arguments, stdout: stdout, stderr: StringIO.new)
    [status, JSON.parse(stdout.string)]
  end
end
