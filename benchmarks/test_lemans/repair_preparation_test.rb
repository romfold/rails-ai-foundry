# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require_relative '../repairs/prepare'

class RepairPreparationTest < Minitest::Test
  def test_incremental_and_complete_repairs_match_recorded_hashes
    fixtures = BenchmarkRepairs::Preparation::FIXTURES
    provenance = JSON.parse(fixtures.join('provenance.json').read)
    provenance.fetch('candidates').each_value do |candidate|
      candidate.fetch('patches').each do |name, digest|
        assert_equal digest, Digest::SHA256.file(fixtures.join(name)).hexdigest
      end
    end
  end

  def test_original_evidence_is_accepted_but_changed_candidate_is_rejected
    task = 'boundary-extraction-foundry'
    history = BenchmarkSuite::ROOT.join('evidence/2026-09-19/openrouter-luna-study')
    original = history.glob("results/*/*/#{task}__*/agent.patch").fetch(0)
    BenchmarkRepairs::Preparation.validate_original(task, original)
    Dir.mktmpdir do |directory|
      changed = Pathname(directory).join('candidate.patch')
      changed.binwrite("#{original.binread}\n")
      assert_raises(BenchmarkSuite::Failure) do
        BenchmarkRepairs::Preparation.validate_original(task, changed)
      end
    end
  end

  def test_supplemental_tests_do_not_replace_upstream_requirements
    Dir.mktmpdir do |directory|
      task = Pathname(directory)
      original = "# immutable upstream checks\n"
      task.join('verification_test.rb').write(original)
      BenchmarkRepairs::Preparation.add_tests(task)
      assert_equal original, task.join('verification_test.rb').read
      assert_equal 3, task.join('tests').glob('*_test.rb').size
      assert_includes task.join('tests/realtime_test.rb').read, "require_relative 'verification_test'"
    end
  end
end
