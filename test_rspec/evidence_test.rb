# frozen_string_literal: true

require_relative '../test/test_helper'
require 'bundler'

class RSpecEvidenceTest < FoundryTest
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

  def test_native_phases_and_unavailable_expectation_count
    output = accepted('--realtime', '--browser', 'spec/system_spec.rb')
    %w[baseline caller browser].each { |phase| assert_includes output, "Verified #{phase}:" }
    assert_includes output, 'expectation counts unavailable'
    spec('spec/request_spec.rb', 'request', 'nil')
    accepted
  end

  def test_shared_examples_belong_to_including_file
    write('support/shared.rb', "RSpec.shared_examples('HTTP') { it('works') { expect(1).to eq(1) } }\n")
    write('spec/request_spec.rb', <<~RUBY)
      require_relative '../support/shared'
      RSpec.describe('requests', type: :request) { include_examples 'HTTP' }
    RUBY
    accepted
  end

  def test_shared_definition_cannot_claim_an_unselected_including_file
    write('spec/request_spec.rb', <<~RUBY)
      RSpec.shared_examples('HTTP') { it('works') { expect(1).to eq(1) } }
      require_relative 'including_spec'
    RUBY
    write('spec/including_spec.rb', "RSpec.describe('requests', type: :request) { include_examples 'HTTP' }\n")
    rejected('executed no RSpec request examples')
  end

  def test_wrong_type_empty_and_unrelated_files
    spec('spec/request_spec.rb', 'model')
    rejected('executed no RSpec request examples')
    write('spec/request_spec.rb', '# empty')
    rejected('no RSpec examples executed')
    write('spec/request_spec.rb', "require_relative 'baseline_spec'\n")
    rejected('executed no RSpec request examples')
  end

  def test_pending_selected_and_reviewed_baseline
    spec('spec/request_spec.rb', 'request', "skip 'unimplemented'")
    rejected('pending RSpec examples')
    spec('spec/request_spec.rb', 'request')
    write('spec/baseline_spec.rb', <<~RUBY)
      RSpec.describe 'baseline' do
        it('known skip') { skip 'reviewed' }
        it('works') { expect(true).to be true }
      end
    RUBY
    rejected('pending RSpec examples')
    accepted('--allow-baseline-skip', './spec/baseline_spec.rb[1:1]')
  end

  def test_failing_examples_and_suite_errors
    spec('spec/request_spec.rb', 'request', 'expect(1).to eq(2)')
    rejected('command failed')
    write('spec/request_spec.rb', "raise 'fixture suite failure'\n")
    rejected('command failed')
  end

  def test_dry_run_and_explicit_filters
    options = ['--dry-run', '--tag selected', '--example behavior', '--only-failures', '--pattern spec/request_spec.rb']
    options.each do |option|
      write('.rspec', option)
      output, error, status = verify
      refute status.success?, "#{option}: #{output}\n#{error}"
      refute_includes output, 'Selected feature verification passed'
    end
  end

  def test_conditional_and_focus_filters
    write('spec/request_spec.rb', <<~RUBY)
      RSpec.configure { |config| config.filter_run_when_matching :focus }
      RSpec.describe('HTTP', type: :request) do
        it('one', focus: true) { expect(true).to be true }
        it('two') { expect(true).to be true }
      end
    RUBY
    rejected('narrowed or dry-run')
    write('spec/request_spec.rb', <<~RUBY)
      RSpec.describe('HTTP', type: :request) do
        it('one', if: false) { raise 'filtered' }
        it('two') { expect(true).to be true }
      end
    RUBY
    rejected('narrowed or dry-run')
  end

  def test_exit_without_report_and_timeout
    write('spec/request_spec.rb', "puts '999 examples, 0 failures'; $stdout.flush; exit! 0")
    rejected('no RSpec evidence')
    spec('spec/request_spec.rb', 'request', 'sleep 30')
    rejected('exceeded 1 seconds', '--timeout', '1')
  end

  def test_missing_rspec_dependencies_produces_guidance
    write('Gemfile', "source 'https://rubygems.org'\n")
    output, error, status = verify
    refute status.success?, output
    assert_includes error, 'RSpec verification requires rspec-core and rspec-rails'
    assert_includes error, 'run bundle install explicitly'
  end

  def test_interrupted_example_cannot_supply_completion
    spec('spec/request_spec.rb', 'request', "Process.kill('INT', Process.pid); sleep 1")
    output, error, status = verify
    refute status.success?, "#{output}\n#{error}"
    refute_includes output, 'Selected feature verification passed'
  end

  def test_rejects_malformed_and_incomplete_reports
    require_relative '../skills/foundry-verify/scripts/verification'
    require_relative '../skills/foundry-verify/scripts/rspec_evidence'
    path = File.join(@root, 'result.json')
    selection = Struct.new(:skips).new([])
    ['{}', '[]', '{'].each do |body|
      File.write(path, body)
      assert_raises(FoundrySkillVerification::Failure) do
        FoundrySkillVerification::RSpecEvidence.new(path, 'caller', [], selection).verify
      end
    end
    report = { version: 1, framework: 'rspec', examples: [{ id: 'one', status: 'pass', type: 'request', files: [] }],
               started: [], problems: [], expected: 1, errors: 0, complete: true }
    File.write(path, JSON.generate(report))
    error = assert_raises(FoundrySkillVerification::Failure) do
      FoundrySkillVerification::RSpecEvidence.new(path, 'caller', [], selection).verify
    end
    assert_includes error.message, 'incomplete'
  end

  private

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
