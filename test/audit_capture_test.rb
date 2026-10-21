# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/conventions/debt_audit'

class AuditCaptureTest < FoundryTest
  def setup
    super
    write('Gemfile', '# locked consumer')
    write('Gemfile.lock', '# installed')
    write('config/application.rb', '# app')
    write('packwerk.yml', '{}')
    write('app/model.rb', 'original')
    @audit = RailsAIFoundry::Conventions::DebtAudit.new(@root, pks: RbConfig.ruby)
  end

  def test_backends_share_captured_inputs_despite_live_edits
    directories = []
    @audit.stub(:execute, lambda { |backend, action, directory|
      unless action == '--version'
        directories << directory
        path = File.join(directory, 'app/model.rb')
        assert_equal 'original', File.read(path) if action == 'validate'
        File.write(path, 'backend edit')
        write('app/model.rb', 'intervening source edit') if backend == :packwerk
      end
      { 'stdout' => 'tool 1' }
    }) do
      report = @audit.call(parity: true)
      assert report['parity']
      refute report['source_unchanged']
      refute report['success']
    end
    assert_equal 2, directories.uniq.size
    directories.each { |path| refute File.exist?(path) }
  end

  def test_accepted_debt_comes_from_capture_and_generated_baselines_are_discovered
    identity = ['components/new', 'other', 'Invoice', 'privacy', 'app/a.rb']
    captured = nil
    @audit.stub(:regenerate, lambda { |_backend, input|
      captured = input.files.root
      assert File.file?(File.join(captured, 'app/model.rb'))
      write('package_todo.yml', "other:\n  Invoice:\n    violations: [privacy]\n    files: [app/a.rb]\n")
      [[], []]
    }) do
      report = @audit.call
      assert_empty report['accepted']
      refute report['source_unchanged']
    end
    refute File.exist?(captured)
    File.unlink(File.join(@root, 'package_todo.yml'))
    @audit.stub(:execute, lambda { |_backend, action, directory|
      if action == 'update-todo'
        FileUtils.mkdir_p(File.join(directory, 'components/new'))
        File.write(File.join(directory, 'components/new/package_todo.yml'),
                   "other:\n  Invoice:\n    violations: [privacy]\n    files: [app/a.rb]\n")
      end
      {}
    }) { assert_equal [identity], @audit.call['new'] }
  end

  def test_failed_backend_cleans_captured_and_working_directories
    captured = nil
    working = nil
    regenerate = @audit.method(:regenerate)
    @audit.stub(:regenerate, lambda { |backend, input|
      captured = input.files.root
      regenerate.call(backend, input)
    }) do
      @audit.stub(:execute, lambda { |_backend, _action, directory|
        working = directory
        raise RailsAIFoundry::ConfigurationError, 'Synthetic backend failure'
      }) { assert_raises(RailsAIFoundry::ConfigurationError) { @audit.call } }
    end
    [captured, working].each { |path| refute File.exist?(path) }
    assert_equal 'original', File.read(File.join(@root, 'app/model.rb'))
  end

  def test_write_failure_and_incomplete_copy_never_yield
    [->(*) { raise Errno::ENOSPC }, ->(*) {}].each do |fault|
      FileUtils.stub(:cp, fault) do
        assert_raises(RailsAIFoundry::ConfigurationError) do
          @audit.snapshot.copy { flunk 'Incomplete copy was yielded' }
        end
      end
    end
  end

  def test_prior_policy_evidence_requires_regeneration
    @audit.stub(:regenerate, ->(*) { [[], []] }) do
      @audit.stub(:execute, ->(*) { { 'stdout' => 'tool 1' } }) do
        report = @audit.call(parity: true)
        report['fingerprint'] = Digest::SHA256.hexdigest(JSON.generate(@audit.snapshot.inventory))
        error = assert_raises(RailsAIFoundry::ConfigurationError) { @audit.verify(report) }
        assert_includes error.message, 'rerun parity'
      end
    end
  end
end
