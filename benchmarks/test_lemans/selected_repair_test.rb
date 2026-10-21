# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require_relative '../repairs/prepare'
require_relative '../repairs/selected_preparation'

class SelectedRepairTest < Minitest::Test
  NAME = 'realtime-2026-09-21'
  FIXTURES = Pathname(__dir__).join('../repairs/sets', NAME)
  HISTORY = BenchmarkSuite::ROOT.join('evidence/2026-09-21/openrouter-luna-study')
  Config = Struct.new(:tasks)
  Image = Struct.new(:name)
  Task = Struct.new(:name, :digest, :dir, :environment_image, keyword_init: true)

  def test_named_set_preserves_upstream_tests_and_records_its_identity
    with_study do |source, output, task|
      original = source.join('upstream/tasks', task.name, 'verification_test.rb').read
      run_preparation(source, output, task)
      assert_equal original, output.join('upstream/tasks', task.name, 'verification_test.rb').read
      assert_selected_output(output)
    end
  end

  def test_unknown_selection_is_rejected
    assert_raises(BenchmarkSuite::Failure) do
      BenchmarkRepairs::SelectedPreparation.new('/tmp', '/tmp/unused', '../fixtures')
    end
  end

  def test_mismatched_study_task_image_and_candidate_are_rejected_before_output
    %i[study task image candidate].each do |kind|
      with_study do |source, output, task|
        corrupt(source, task, kind)
        assert_raises(BenchmarkSuite::Failure, kind.to_s) { run_preparation(source, output, task) }
        refute_path_exists output
      end
    end
  end

  def test_changed_fixture_is_rejected
    with_study do |source, output, task|
      fixtures = source.join('modified-fixtures')
      FileUtils.cp_r(fixture_root, fixtures)
      fixtures.join('realtime-repair.patch').write('changed')
      preparation = BenchmarkRepairs::SelectedPreparation.new(source, output, repair_name)
      preparation.instance_variable_set(:@fixtures, fixtures)
      Lemans::Config.stub(:load_file, Config.new([task])) do
        assert_raises(BenchmarkSuite::Failure) { preparation.call }
      end
      refute_path_exists output
    end
  end

  def test_repair_set_hashes_match
    provenance.fetch('files').each do |name, digest|
      assert_equal digest, Digest::SHA256.file(fixture_root.join(name)).hexdigest, name
    end
  end

  def test_existing_fixtures_remain_distinct
    original = JSON.parse(BenchmarkRepairs::Preparation::FIXTURES.join('provenance.json').read)
    refute_equal provenance.fetch('original_sha256'),
                 original.fetch('candidates').fetch(provenance.fetch('task')).fetch('original_sha256')
  end

  private

  def assert_selected_output(output)
    assert_path_exists output.join('original.patch')
    assert_path_exists output.join('realtime-complete.patch')
    assert_equal repair_name, JSON.parse(output.join('manifest.json').read).fetch('repair_set')
    refute_path_exists output.join('boundary-complete.patch')
  end

  def provenance
    JSON.parse(fixture_root.join('provenance.json').read)
  end

  def run_preparation(source, output, task)
    Lemans::Config.stub(:load_file, Config.new([task])) do
      BenchmarkRepairs::SelectedPreparation.new(source, output, repair_name).call
    end
  end

  def with_study
    Dir.mktmpdir do |directory|
      source = Pathname(directory).join('study')
      task = seed(source)
      yield source, Pathname(directory).join('output'), task
    end
  end

  def seed(source)
    task_dir = source.join('upstream/tasks', provenance.fetch('task'))
    task_dir.mkpath
    task_dir.join('verification_test.rb').write('# unchanged upstream requirements')
    seed_artifacts(source)
    Task.new(name: provenance.fetch('task'), digest: provenance.fetch('task_digest'), dir: task_dir,
             environment_image: Image.new('fizzy'))
  end

  def seed_artifacts(source)
    FileUtils.cp(history_root.join('study.json'), source)
    source.join('upstream/images.json').write({ 'fizzy' => { 'id' => provenance.fetch('image') } }.to_json)
    seed_candidate(source)
  end

  def seed_candidate(source)
    candidate = source.join('results/09-task/model', "#{provenance.fetch('task')}__original")
    candidate.mkpath
    FileUtils.cp(history_root.glob('results/09-*/**/agent.patch').fetch(0), candidate)
  end

  def corrupt(source, task, kind)
    case kind
    when :study then source.join('study.json').write("#{source.join('study.json').read}\n")
    when :task then task.digest = 'changed'
    when :image then source.join('upstream/images.json').write({ 'fizzy' => { 'id' => 'changed' } }.to_json)
    when :candidate then source.glob('results/**/agent.patch').fetch(0).write('changed')
    end
  end

  def repair_name
    self.class::NAME
  end

  def fixture_root
    self.class::FIXTURES
  end

  def history_root
    self.class::HISTORY
  end
end
