# frozen_string_literal: true

require_relative 'selected_repair_test'

class ProfileRepairSelectionTest < SelectedRepairTest
  NAME = 'profile-realtime-2026-09-22'
  FIXTURES = Pathname(__dir__).join('../repairs/sets', NAME)
  HISTORY = BenchmarkSuite::ROOT.join('evidence/2026-09-22/openrouter-luna-realtime-guidance-study')

  def test_changed_fixture_is_rejected
    with_study do |source, output, task|
      preparation = altered_preparation(source, output)
      Lemans::Config.stub(:load_file, Config.new([task, @companion])) do
        error = assert_raises(BenchmarkSuite::Failure) { preparation.call }
        assert_equal 'Repair fixture mismatch: boundary-repair.patch', error.message
      end
      refute_path_exists output
    end
  end

  def test_companion_mismatches_are_rejected_before_output
    %i[task image candidate].each do |kind|
      with_study do |source, output, task|
        case kind
        when :task then @companion.digest = 'changed'
        when :image then source.join('foundry/images.json').write({ 'foundry' => { 'id' => 'changed' } }.to_json)
        when :candidate then source.glob('results/03-*/**/agent.patch').fetch(0).write('changed')
        end
        assert_raises(BenchmarkSuite::Failure, kind.to_s) { run_preparation(source, output, task) }
        refute_path_exists output
      end
    end
  end

  private

  def altered_preparation(source, output)
    fixtures = source.join('modified-fixtures')
    FileUtils.cp_r(fixture_root, fixtures)
    fixtures.join('boundary-repair.patch').write('changed')
    BenchmarkRepairs::SelectedPreparation.new(source, output, repair_name).tap do |preparation|
      preparation.instance_variable_set(:@fixtures, fixtures)
    end
  end

  def seed(source)
    task = super
    expected = provenance.fetch('companion')
    task_dir = source.join('foundry/tasks', expected.fetch('task'))
    task_dir.mkpath
    task_dir.join('instruction.md').write('Companion requirements')
    seed_companion_artifacts(source, expected)
    @companion = Task.new(name: expected.fetch('task'), digest: expected.fetch('task_digest'), dir: task_dir,
                          environment_image: Image.new('foundry'))
    task
  end

  def seed_companion_artifacts(source, expected)
    source.join('foundry/images.json').write({ 'foundry' => { 'id' => expected.fetch('image') } }.to_json)
    candidate = source.join('results/03-task/model', "#{expected.fetch('task')}__original")
    candidate.mkpath
    FileUtils.cp(history_root.glob('results/03-*/**/agent.patch').fetch(0), candidate)
  end

  def run_preparation(source, output, task)
    Lemans::Config.stub(:load_file, Config.new([task, @companion])) do
      BenchmarkRepairs::SelectedPreparation.new(source, output, repair_name).call
    end
  end

  def assert_selected_output(output)
    %w[original.patch realtime-complete.patch boundary-original.patch boundary-complete.patch].each do |name|
      assert_path_exists output.join(name)
    end
    assert_path_exists output.join('foundry/tasks', provenance.fetch('companion').fetch('task'), 'instruction.md')
    assert_equal repair_name, JSON.parse(output.join('manifest.json').read).fetch('repair_set')
  end
end
