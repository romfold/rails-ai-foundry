# frozen_string_literal: true

require_relative '../test/test_helper'
require_relative 'archive_helper'
require 'json'

class NativeBoundaryTest < FoundryTest
  include ArchiveAcceptance

  def test_upstream_debt_identities_and_native_privacy_from_installed_gem
    build_archive
    prepare_host
    File.open(File.join(@app, 'Gemfile'), 'a') { |file| file.puts "gem 'packs-rails', '~> 0.1.0'" }
    application = File.read(File.join(@app, 'config/application.rb'))
    write('app/config/application.rb',
          application.sub("require 'rails_ai_foundry'", "require 'packs-rails'\nrequire 'rails_ai_foundry'"))
    assert_command(RbConfig.ruby, '-S', 'gem', 'install', @archive, '--local', '--ignore-dependencies',
                   '--no-document', '--install-dir', @gem_home)
    assert_command(RbConfig.ruby, '-S', 'bundle', 'install', '--local')
    assert_provenance
    write('app/config/foundry.yml', "workflow:\n  specs: none\n")
    write('app/package.yml', "{}\n")
    %w[billing orders].each { |name| rails('generate', 'foundry:context', name) }
    write('app/packs/billing/app/models/billing/invoice.rb', "class Billing::Invoice; end\n")
    write('app/packs/orders/app/models/orders/summary.rb', "class Orders::Summary; TYPE = Billing::Invoice; end\n")
    write('app/packs/orders/app/models/orders/remaining.rb', "class Orders::Remaining; TYPE = Billing::Invoice; end\n")
    verify_debt
    verify_installed_parity if ENV['PKS_BIN']
    verify_complete_audit
  end

  private

  def verify_installed_parity
    foundry = File.join(@gem_home, 'bin/foundry')
    output = assert_command(RbConfig.ruby, foundry, 'parity', "--pks=#{ENV.fetch('PKS_BIN')}")
    report = JSON.parse(output)
    assert report['parity']
    assert report['source_unchanged']
    assert_equal 2, report['retained'].size
    assert_equal 2, report['resolved'].size
    evidence = File.join(@root, 'parity.json')
    File.write(evidence, output)
    assert_command(RbConfig.ruby, foundry, 'parity', "--pks=#{ENV.fetch('PKS_BIN')}", "--verify=#{evidence}")
  end

  def verify_complete_audit
    %w[summary remaining].each do |name|
      write("app/packs/orders/app/models/orders/#{name}.rb", "class Orders::#{name.capitalize}; end\n")
    end
    before = File.read(File.join(@app, 'packs/orders/package_todo.yml'))
    %w[.claude .foundry/skill-upgrades/agents/session vendor/synthetic].each do |directory|
      write("app/#{directory}/package_todo.yml", "invalid: [\n")
    end
    write('app/config/initializers/audit_privacy.rb', <<~RUBY)
      if File.basename(Rails.root.to_s).start_with?('foundry-audit-')
        %w[.claude .foundry/skill-upgrades vendor/synthetic].each do |path|
          raise 'Private audit input was copied' if Rails.root.join(path).exist?
        end
      end
    RUBY
    protected = snapshot
    output, error, status = command(RbConfig.ruby, File.join(@gem_home, 'bin/foundry'), 'audit')
    assert status.success?, "#{output}\n#{error}"
    report = JSON.parse(output)
    assert report['success']
    assert_equal 4, report['resolved'].size
    assert_empty report['current']
    assert_equal before, File.read(File.join(@app, 'packs/orders/package_todo.yml'))
    assert_equal protected, snapshot
  end

  def check_boundaries(success:)
    foundry = File.join(@gem_home, 'bin/foundry')
    output, error, status = command(RbConfig.ruby, foundry, 'check', '--boundaries', '--format=json')
    assert_equal success, status.success?, "#{output}\n#{error}"
    result = JSON.parse(output).fetch('boundaries')
    assert_equal success, result.fetch('success')
    assert result.fetch('baselines_unchanged')
    result.fetch('commands').map { |entry| entry.fetch('stdout') + entry.fetch('stderr') }.join("\n")
  end

  def verify_debt
    assert_includes check_boundaries(success: false), 'Privacy violation'
    todo = YAML.dump('packs/billing' => { '::Billing::Invoice' => {
                       'violations' => %w[dependency privacy],
                       'files' => %w[packs/orders/app/models/orders/summary.rb
                                     packs/orders/app/models/orders/remaining.rb]
                     } })
    write('app/packs/orders/package_todo.yml', todo)
    check_boundaries(success: true)
    rails('foundry:architecture:boundaries')
    write('app/packs/orders/app/models/orders/another.rb', "class Orders::Another; TYPE = Billing::Invoice; end\n")
    assert_includes check_boundaries(success: false), 'another.rb'
    output, error, status = command(RbConfig.ruby, 'bin/rails', 'foundry:architecture:boundaries')
    refute status.success?, "#{output}\n#{error}"
    assert_includes output, 'another.rb'
    assert_equal todo, File.read(File.join(@app, 'packs/orders/package_todo.yml'))
    File.unlink(File.join(@app, 'packs/orders/app/models/orders/another.rb'))
    write('app/packs/orders/app/models/orders/summary.rb', "class Orders::Summary; end\n")
    assert_includes check_boundaries(success: false), 'stale'
    assert_equal todo, File.read(File.join(@app, 'packs/orders/package_todo.yml'))
  end
end
