# frozen_string_literal: true

require_relative 'study'

module BenchmarkSuite
  module StudyOutcome
    LIMITS = %w[agent_timeout step_limit_reached cost_ceiling_reached].freeze

    module_function

    def status(native, independent, compared)
      return 'invalid_protocol' if independent['status'] == 'invalid_protocol'
      return 'infrastructure_error' if independent['status'] == 'infrastructure_error'
      return 'incomplete' if LIMITS.include?(native.dig('outcome', 'name'))
      return 'infrastructure_error' unless native.dig('outcome', 'name') == 'completed'

      compared
    end

    def valid_identity?(native, row, root)
      hashes = JSON.parse(root.join(row['suite'], 'study-tasks.json').read).fetch(row['task'])
      native.values_at('task', 'agent', 'model', 'task_digest', 'profile_digest') ==
        [row['task'], 'miniswen', Study::MODEL, hashes['task_digest'], hashes['profile_digest']]
    end
  end
end
