# frozen_string_literal: true

require_relative '../test/test_helper'
require_relative '../test_packaging/archive_helper'
require_relative '../test_journey/support/skill_upgrades'

class InstalledRSpecTest < FoundryTest
  include ArchiveAcceptance
  include InstalledSkillUpgrades

  %w[agents claude cursor].product(%w[packs components]).each do |target, root|
    define_method("test_#{target}_with_#{root}") { replay(root, target) }
  end

  private

  def replay(root, target)
    build_archive
    prepare_host
    @pack_root = root
    prepare_rspec_application
    assert_command(RbConfig.ruby, '-S', 'gem', 'install', @archive, '--local', '--ignore-dependencies',
                   '--no-document', '--install-dir', @gem_home)
    assert_command('bundle', 'install', '--local')
    rails('generate', 'foundry:skills')
    verify_skill_upgrades(root, target: target)
    assert_provenance
  end

  def prepare_rspec_application
    %w[rails rspec-rails capybara selenium-webdriver puma json].each do |name|
      File.open(File.join(@app, 'Gemfile'), 'a') do |file|
        file.puts "gem '#{name}', '#{Gem.loaded_specs.fetch(name).version}'"
      end
    end
    write('network_guard.rb', '') # Browser acceptance uses loopback; no application provider exists.
    application = File.read(File.join(@app, 'config/application.rb'))
    application = application.sub("require 'rails/test_unit/railtie'",
                                  "require 'rails/test_unit/railtie'\nrequire 'active_job/railtie'")
    write('app/config/application.rb', application)
    write('app/config/foundry.yml', "schema: 1\nworkflow:\n  specs: none\n")
    write('app/config/routes.rb', "Rails.application.routes.draw { get '/screen', to: 'screen#show' }\n")
    copy_fixture('screen_controller.rb', 'app/controllers/screen_controller.rb')
    copy_fixture('rails_helper.rb', 'spec/rails_helper.rb')
    copy_fixture('request_spec.rb', 'spec/requests/screen_spec.rb')
    copy_fixture('system_spec.rb', 'spec/system/screen_spec.rb')
    write('app/.rspec', "--require rails_helper\n")
  end

  def copy_fixture(name, destination)
    write("app/#{destination}", File.binread(File.join(__dir__, 'fixtures', name)))
  end

  def prepare_prior_catalog(pack_root)
    paths = super
    receipt = JSON.parse(File.binread(File.join(@app, @upgrade_receipt)))
    %w[loaded_files.rb package_baseline.rb package_discovery.rb package_inventory.rb].each do |name|
      path = "#{@upgrade_base}/scripts/#{name}"
      receipt['files'].delete(path)
      FileUtils.rm(File.join(@app, path))
    end
    write("app/#{@upgrade_receipt}", JSON.pretty_generate(receipt))
    paths
  end

  def verify_upgraded_helper
    prepare_package_tests
    write('app/bin/verify-feature', <<~RUBY)
      #!/usr/bin/env ruby
      require 'rbconfig'
      Dir.chdir(File.expand_path('..', __dir__))
      helper = '#{@upgrade_base}/scripts/verify.rb'
      abort 'Minitest verification failed' unless system(RbConfig.ruby, helper, '--include-pack-tests',
        '--caller', '#{@pack_root}/billing/test/screen_test.rb', '--realtime',
        '--browser', 'test/system/screen_test.rb', '--timeout', '120')
      exec RbConfig.ruby, helper, '--include-pack-tests', '--framework=rspec',
        '--caller', '#{@pack_root}/billing/spec/requests/screen_spec.rb', '--realtime',
        '--browser', 'spec/system/screen_spec.rb', '--timeout', '120'
    RUBY
    output = assert_command(RbConfig.ruby, 'bin/verify-feature')
    assert_includes output, 'Verified browser: 1 RSpec examples'
    assert_includes output, 'Verified browser: 1 tests'
    verify_package_faults
  end

  def prepare_package_tests
    write('app/packs.yml', "pack_paths: ['#{@pack_root}/*']\n")
    write("app/#{@pack_root}/billing/package.yml", '{}')
    copy_fixture('request_spec.rb', "#{@pack_root}/billing/spec/requests/screen_spec.rb")
    %w[helper screen system].each do |name|
      destination = { 'helper' => 'test/test_helper.rb', 'screen' => "#{@pack_root}/billing/test/screen_test.rb",
                      'system' => 'test/system/screen_test.rb' }.fetch(name)
      copy_fixture("minitest_#{name}.rb", destination)
    end
    write('app/test/root_test.rb', <<~RUBY)
      require 'test_helper'
      class RootTest < ActiveSupport::TestCase
        test('root behavior') { assert ENV['FOUNDRY_FIXTURE_FAULT'] != 'root' }
      end
    RUBY
    write('app/spec/root_spec.rb', <<~RUBY)
      RSpec.describe('root behavior') { it('works') { expect(ENV['FOUNDRY_FIXTURE_FAULT']).not_to eq('root') } }
    RUBY
  end

  def verify_package_faults
    %w[root authorization browser].each do |fault|
      output, error, status = command(RbConfig.ruby, 'bin/verify-feature',
                                      extra_env: { 'FOUNDRY_FIXTURE_FAULT' => fault })
      refute status.success?, output
      assert_includes error, "#{fault == 'browser' ? 'browser' : 'baseline'}: command failed"
      # Also prove the second required invocation rejects failures independently.
      output, error, status = command(RbConfig.ruby, "#{@upgrade_base}/scripts/verify.rb",
                                      '--framework=rspec', '--include-pack-tests', '--caller',
                                      "#{@pack_root}/billing/spec/requests/screen_spec.rb", '--realtime',
                                      '--browser', 'spec/system/screen_spec.rb', '--timeout', '120',
                                      extra_env: { 'FOUNDRY_FIXTURE_FAULT' => fault })
      refute status.success?, output
      assert_includes error, "#{fault == 'browser' ? 'browser' : 'baseline'}: command failed"
    end
  end
end
