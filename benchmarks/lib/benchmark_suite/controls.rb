# frozen_string_literal: true

require_relative 'foundry'

module BenchmarkSuite
  class Controls
    def self.prepare(workspace, output)
      new(workspace, output).prepare
    end

    def initialize(workspace, output)
      @source = Pathname(workspace).realpath
      @root = Support.external_directory(output)
      @config = Lemans::Config.load_file(@source)
      @images = JSON.parse(@source.join('images.json').read)
    end

    def prepare
      @root.join('tasks').mkpath
      @config.tasks.each { |task| variants(task).each { |variant| copy(task, variant) } }
      manifest
      raise Failure, 'Expected exactly 45 controls' unless Lemans::Config.load_file(@root).tasks.size == 45

      @root
    end

    private

    def manifest
      FileUtils.cp(@source.join('bench.yml'), @root.join('bench.yml'))
      image_map = @images.values.to_h { |row| [row.fetch('id'), row] }
      Support.json(@root.join('images.json'), image_map)
      Support.json(@root.join('manifest.json'), { 'suite' => 'foundry-controls', 'source' => Support.files(@source),
                                                  'files' => Support.files(@root) })
    end

    def variants(task)
      names = %w[reference faulty]
      names += DeliveryVariants::NAMES if task.metadata['task'] == 'boundary-extraction'
      names
    end

    def copy(task, variant)
      destination = @root.join('tasks', "#{task.name}--#{variant}")
      destination.mkpath
      copy_files(task, destination)
      patch = variant == 'reference' ? 'solution.patch' : "#{variant}.patch"
      FileUtils.cp(task.dir.join(patch), destination.join('solution.patch'))
      empty_solution(destination) if destination.join('solution.patch').empty?
      configure(task, destination, variant)
    end

    def copy_files(task, destination)
      task.dir.children.reject { |path| path.basename.to_s == 'environment' }.each do |path|
        FileUtils.cp_r(path, destination)
      end
    end

    def empty_solution(destination)
      solution = destination.join('solution')
      solution.mkpath
      solution.join('solve.sh').write(<<~SCRIPT)
        #!/bin/sh
        # This faulty control deliberately leaves the starting defect unchanged.
        exit 0
      SCRIPT
    end

    def configure(task, destination, variant)
      image = @images.fetch(task.environment_image.name).fetch('id')
      destination.join('bench.yml').write({ 'environment' => { 'image' => image, 'dockerfile' => nil } }.to_yaml)
      expected = variant == 'reference' || variant.end_with?('_reference')
      original = destination.join('instruction.md').read
      original = original.sub("metadata:\n", "metadata:\n  expected_pass: #{expected}\n  control: #{variant}\n")
      destination.join('instruction.md').write(original)
    end
  end
end
