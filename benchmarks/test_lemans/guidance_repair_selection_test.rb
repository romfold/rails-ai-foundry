# frozen_string_literal: true

require_relative 'selected_repair_test'

class GuidanceRepairSelectionTest < SelectedRepairTest
  NAME = 'realtime-guidance-2026-09-21'
  FIXTURES = Pathname(__dir__).join('../repairs/sets', NAME)
  HISTORY = BenchmarkSuite::ROOT.join('evidence/2026-09-21/openrouter-luna-guidance-study')
end
