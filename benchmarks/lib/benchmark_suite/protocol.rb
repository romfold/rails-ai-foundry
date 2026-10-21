# frozen_string_literal: true

require_relative 'support'

module BenchmarkSuite
  module Protocol
    module_function

    def rules(task)
      restored = task.verifier.restore_paths
      forbidden = restored - %w[test saas/test]
      forbidden += %w[test/visible_test.rb test/test_helper.rb] if task.metadata['group']
      { 'restore' => restored, 'forbidden' => forbidden,
        'application_tests' => 'Edits are retained as evidence and restored before grading; they cannot award credit' }
    end
  end
end
