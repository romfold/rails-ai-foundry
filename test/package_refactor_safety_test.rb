# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/conventions/refactor_command'

class PackageRefactorSafetyTest < FoundryTest
  def setup
    super
    write('packs/a/package.yml', '{}')
    write('packs/a/foundry.yml', "namespace: A\nprofile: modular\n")
    @refactor = RailsAIFoundry::Conventions::Refactor.new(@root)
  end

  def test_one_discovery_and_duplicate_paths
    calls = 0
    discovery = lambda do |*|
      calls += 1
      ['["packs/a", "packs/a/."]', '', successful_status]
    end
    write('packs/a/lib/code.rb', 'RailsAIFoundry::Runtime')
    Open3.stub(:capture3, discovery) do
      assert_equal 1, @refactor.call(context: 'A').fetch('findings').size
    end
    assert_equal 1, calls
  end

  def test_malformed_or_unsafe_discovery_never_falls_back
    ['{', '{}', '["../elsewhere"]', '["/elsewhere"]', '[null]'].each do |output|
      Open3.stub(:capture3, [output, '', successful_status]) do
        assert_raises(RailsAIFoundry::ConfigurationError) { @refactor.call(context: 'A') }
      end
    end
    status = Object.new
    def status.success? = false
    Open3.stub(:capture3, ['', 'Missing packs-specification', status]) do
      error = assert_raises(RailsAIFoundry::ConfigurationError) { @refactor.call(context: 'A') }
      assert_includes error.message, 'Upstream pack discovery failed'
    end
    write('packs.yml', "pack_paths: invalid\n")
    assert_raises(RailsAIFoundry::ConfigurationError) { @refactor.call(context: 'A') }
  end

  def test_file_and_directory_symlinks_are_rejected
    write('target/code.rb', 'Object')
    ['target', 'target/code.rb', 'absent.rb'].each do |target|
      path = File.join(@root, 'packs/a/link')
      File.symlink(File.join(@root, target), path)
      error = assert_raises(RailsAIFoundry::ConfigurationError) { @refactor.call(context: 'A') }
      assert_includes error.message, 'packs/a/link'
      File.unlink(path)
    end
  end

  def test_disappeared_and_unreadable_selected_files
    path = 'packs/a/lib/code.rb'
    write(path, 'Object')
    files = @refactor.instance_variable_get(:@contexts).files
    read = files.method(:read)
    [nil, Errno::EACCES].each do |failure|
      replacement = lambda do |relative|
        next read.call(relative) unless relative == path
        raise failure if failure
      end
      files.stub(:read, replacement) do
        error = assert_raises(RailsAIFoundry::ConfigurationError) { @refactor.call(context: 'A') }
        assert_includes error.message, path
      end
    end
  end

  def test_non_regular_entry_and_failed_directory_enumeration
    File.mkfifo(File.join(@root, 'packs/a/fifo.rb'))
    assert_raises(RailsAIFoundry::ConfigurationError) { @refactor.call(context: 'A') }
    File.unlink(File.join(@root, 'packs/a/fifo.rb'))
    Dir.stub(:children, ->(*) { raise Errno::EACCES }) do
      error = assert_raises(RailsAIFoundry::ConfigurationError) { @refactor.call(context: 'A') }
      assert_equal 'Cannot enumerate source directory: packs/a', error.message
    end
  end

  def test_cli_preserves_files_and_findings_do_not_fail_a_complete_assessment
    write('Gemfile', "raise 'Do not evaluate Gemfile'")
    write('config/application.rb', "raise 'Do not boot Rails'")
    write('packs/a/lib/code.rb', "RailsAIFoundry::Runtime\nraise 'Do not execute'")
    before = snapshot
    %w[json text].each do |format|
      output = StringIO.new
      status = RailsAIFoundry::Conventions::RefactorCommand.new.call(
        ["--root=#{@root}", '--context=A', '--profile=domain', "--format=#{format}"],
        stdout: output, stderr: StringIO.new
      )
      assert_equal 0, status
      assert_includes output.string, 'packs/a/lib/code.rb'
    end
    assert_equal before, snapshot
  end

  private

  def successful_status
    status = Object.new
    def status.success? = true
    status
  end
end
