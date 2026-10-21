# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../skills/foundry-verify/scripts/verification'

class PackageEvidenceIntegrityTest < FoundryTest
  def test_discovery_reports_must_be_complete_local_inventories
    selection = Struct.new(:root).new(File.realpath(@root))
    reader = FoundrySkillVerification::PackageBaseline.new(selection)
    write('test/pass_test.rb', '# fixture')
    path = File.join(@root, 'inventory.json')
    valid = { 'files' => ['test/pass_test.rb'], 'origins' => { 'test/pass_test.rb' => 'root' },
              'deferred' => [], 'untested_packages' => [] }
    [nil, [], {}, valid.merge('files' => [1]), valid.merge('files' => ['../escape.rb']),
     valid.merge('origins' => {}), valid.merge('deferred' => nil)].each do |data|
      File.write(path, JSON.generate(data))
      assert_raises(FoundrySkillVerification::Failure) { reader.files(path) }
    end
    File.write(path, JSON.generate(valid))
    assert_output(%r{Baseline root: test/pass_test.rb}) { assert_equal valid['files'], reader.files(path) }
  end

  def test_loaded_files_are_required_separately_from_test_results
    [nil, [], {}, { 'loaded_files' => nil }, { 'loaded_files' => [1] }].each do |data|
      assert_raises(FoundrySkillVerification::Failure) do
        FoundrySkillVerification::LoadedFiles.verify(data, ['test/pass_test.rb'])
      end
    end
    assert_raises(FoundrySkillVerification::Failure) do
      FoundrySkillVerification::LoadedFiles.verify({ 'loaded_files' => ['test/other_test.rb'] }, ['test/pass_test.rb'])
    end
    FoundrySkillVerification::LoadedFiles.verify({ 'loaded_files' => ['test/pass_test.rb'] }, ['test/pass_test.rb'])
  end
end
