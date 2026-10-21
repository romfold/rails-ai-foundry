# frozen_string_literal: true

require_relative 'support'

module BenchmarkSuite
  # Validate contributor output placement before any command creates directories.
  module CommandPaths
    module_function

    def check(command, arguments)
      output, inputs = locations(command, arguments)
      return unless output

      destination = resolve(output)
      inputs.compact.each do |input|
        source = resolve(input)
        if destination == source || destination.to_s.start_with?("#{source}/")
          raise Failure, 'Output must be separate from input workspaces and evidence'
        end
      end
    end

    def locations(command, arguments)
      return study_locations(command, arguments) if %w[prepare-study study-report study-preflight].include?(command)

      ordinary_locations(command, arguments)
    end

    def ordinary_locations(command, arguments)
      case command
      when 'prepare-upstream' then [arguments[0], [arguments[1]]]
      when 'prepare-controls', 'prepare-shard', 'dependencies', 'isolation', 'reviewed-study-controls' then [
        arguments[1], [arguments[0]]
      ]
      when 'replay' then [arguments[2], arguments.first(2)]
      when 'verify' then [arguments[3], [arguments[0]]]
      when 'report' then [arguments[1], [arguments[0], *arguments.drop(2).map { |path| File.dirname(path) }]]
      else [nil, []]
      end
    end

    def study_locations(command, arguments)
      index = { 'prepare-study' => 0, 'study-report' => 1, 'study-preflight' => 2 }.fetch(command)
      roots = command == 'prepare-study' ? [] : study_inputs(arguments[0])
      [arguments[index], roots]
    end

    def study_inputs(root)
      return [] unless root

      %w[smoke foundry upstream sources dependencies results verification preflights].map do |name|
        File.join(root, name)
      end
    end

    def resolve(path)
      path = Pathname(path).expand_path
      ancestor = path
      ancestor = ancestor.parent until ancestor.exist?
      ancestor.realpath.join(path.relative_path_from(ancestor)).cleanpath
    end
  end
end
