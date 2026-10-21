# frozen_string_literal: true

require_relative '../test/test_helper'
require 'bundler'

class RSpecPackageEvidenceTest < FoundryTest
  SCRIPT = File.expand_path('../skills/foundry-verify/scripts/verify.rb', __dir__)

  def setup
    super
    write('Gemfile',
          "source 'https://rubygems.org'\ngem 'rspec-rails', '#{Gem.loaded_specs.fetch('rspec-rails').version}'\n")
    write('bin/rails', '# application marker')
    spec('spec/baseline_spec.rb', 'model')
    spec('spec/request_spec.rb', 'request')
    spec('spec/system_spec.rb', 'system')
  end

  def test_package_baseline_includes_root_pack_and_loaded_shared_definitions
    enable_packages
    write('components/billing/spec/shared_spec.rb',
          "RSpec.shared_examples('shared') { it('works') { expect(true).to be true } }")
    write('components/billing/spec/model_spec.rb', <<~RUBY)
      require_relative 'shared_spec'
      RSpec.describe('shared consumer') { include_examples 'shared' }
    RUBY
    output = accepted('--include-pack-tests', '--browser', 'spec/system_spec.rb')
    assert_includes output, 'Baseline package components/billing:'
    assert_includes output, 'Verified baseline: 3 RSpec examples'
    spec('components/billing/spec/model_spec.rb', 'model', 'expect(1).to eq(2)')
    rejected('baseline: command failed', '--include-pack-tests', '--browser', 'spec/system_spec.rb')
  end

  def test_package_only_application
    enable_packages
    FileUtils.rm_rf(File.join(@root, 'spec'))
    spec('components/billing/spec/requests_spec.rb', 'request')
    output, error, status = Bundler.with_unbundled_env do
      Open3.capture3({ 'RUBYOPT' => nil }, RbConfig.ruby, SCRIPT, '--app', @root,
                     '--framework=rspec', '--include-pack-tests', '--caller',
                     'components/billing/spec/requests_spec.rb')
    end
    assert status.success?, "#{output}\n#{error}"
    assert_includes output, 'Verified baseline: 1 RSpec examples'
  end

  def test_package_discovery_rejects_narrowing_before_examples_execute
    enable_packages
    write('.rspec', '--tag selected')
    write('spec/request_spec.rb',
          "RSpec.describe(type: :request) { it('unsafe', selected: true) { File.write('ran', 'yes') } }")
    rejected('command failed', '--include-pack-tests')
    refute File.exist?(File.join(@root, 'ran'))
  end

  def test_package_loaded_file_evidence_rejects_omission
    require_relative '../skills/foundry-verify/scripts/verification'
    require_relative '../skills/foundry-verify/scripts/rspec_evidence'
    path = File.join(@root, 'report.json')
    selection = Struct.new(:skips, :include_pack_tests).new([], true)
    File.write(path, JSON.generate('loaded_files' => ['spec/root_spec.rb']))
    error = assert_raises(FoundrySkillVerification::Failure) do
      FoundrySkillVerification::RSpecEvidence.new(path, 'baseline', ['packs/billing/spec/model_spec.rb'], selection)
    end
    assert_includes error.message, 'planned files were not loaded'
  end

  private

  def enable_packages
    File.open(File.join(@root, 'Gemfile'), 'a') { |file| file.puts "gem 'packs-specification', '0.0.11'" }
    write('packs.yml', "pack_paths: ['components/*']\n")
    write('components/billing/package.yml', '{}')
  end

  def spec(path, type, body = 'expect(1).to eq(1)')
    write(path, "RSpec.describe('fixture', type: :#{type}) { it('behavior') { #{body} } }\n")
  end

  def verify(*arguments)
    Bundler.with_unbundled_env do
      Open3.capture3({ 'RUBYOPT' => nil }, RbConfig.ruby, SCRIPT, '--app', @root, '--framework=rspec',
                     '--baseline', 'spec/baseline_spec.rb', '--caller', 'spec/request_spec.rb', *arguments)
    end
  end

  def accepted(*arguments)
    output, error, status = verify(*arguments)
    assert status.success?, "#{output}\n#{error}"
    output
  end

  def rejected(message, *arguments)
    output, error, status = verify(*arguments)
    refute status.success?, output
    assert_includes error, message, "#{output}\n#{error}"
    refute_includes output, 'Selected feature verification passed'
  end
end
