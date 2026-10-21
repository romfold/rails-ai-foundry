# frozen_string_literal: true

require_relative 'prerequisites'

module BenchmarkSuite
  # Materializes input subsets; execution and scheduling remain native Le Mans.
  class Shards
    NAMES = %w[writebook-atomic fizzy-feature-0 fizzy-feature-1 fizzy-feature-2 saas].freeze

    def self.name(task)
      return 'saas' if task.name == 'ft-saas-billing'

      application = fizzy?(task) ? 'fizzy' : 'writebook'
      category = task.name.start_with?('ft-') ? 'feature' : 'atomic'
      return "#{application}-#{category}" unless application == 'fizzy' && category == 'feature'

      "fizzy-feature-#{Digest::SHA256.hexdigest(task.name).to_i(16) % 3}"
    end

    def self.fizzy?(task)
      task.environment_image.context_dir.to_s.include?('fizzy') || task.name == Prerequisites::TASK
    end

    def self.prepare(workspace, output, shard)
      raise Failure, "Unknown shard: #{shard}" unless NAMES.include?(shard)

      source = Pathname(workspace).realpath
      tasks = select_tasks(source, shard)

      root = Support.external_directory(output)
      copy(source, root, tasks)
      Support.json(root.join('shard.json'), { 'shard' => shard, 'tasks' => tasks.map(&:name),
                                              'source_files' => source_hashes(source) })
      root
    end

    def self.select_tasks(source, shard)
      tasks = Lemans::Config.load_file(source).tasks.select { |task| name(task) == shard }
      raise Failure, 'Empty shard' if tasks.empty?

      tasks
    end

    def self.source_hashes(source)
      Support.files(source)
    end

    def self.copy(source, root, tasks)
      source.children.reject { |path| path.basename.to_s == 'tasks' }.each { |path| FileUtils.cp_r(path, root) }
      root.join('tasks').mkpath
      tasks.each { |task| FileUtils.cp_r(task.dir, root.join('tasks')) }
    end
  end
end
