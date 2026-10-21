# frozen_string_literal: true

require_relative 'support'

module BenchmarkSuite
  class Corpus
    GROUPS = %w[rails packs foundry].freeze
    TASKS = %w[boundary-extraction private-coupling authorized-tool duplicate-delivery stale-embedding
               search-rebuild].freeze
    POLICY = "require:\n  - packwerk-extensions\nexclude:\n  - test/**/*\n  - tmp/**/*\n  - log/**/*\n"

    def self.materialize(destination, task, group, solution: 'starting')
      new(Pathname(destination), task, group, solution).call
    end

    def initialize(root, task, group, solution)
      raise Failure, 'Unknown task or treatment' unless TASKS.include?(task) && GROUPS.include?(group)
      raise Failure, 'Unknown solution' unless %w[starting reference faulty].include?(solution)
      raise Failure, 'Candidate already exists' if root.exist?

      @root = root
      @task = task
      @group = group
      @solution = solution
    end

    def call
      merge_inputs
      dependencies
      FileUtils.cp(task_root.join('requirements.md'), @root.join('TASK.md'))
      packages unless @group == 'rails'
      foundry if @group == 'foundry'
      @root.join('AGENTS.md').write(instructions)
      @root
    end

    private

    def merge_inputs
      merge(ROOT.join('fixture'))
      merge(task_root.join('starting'))
      merge(task_root.join('reference')) unless @solution == 'starting'
      merge(task_root.join('faulty')) if @solution == 'faulty'
    end

    def task_root
      ROOT.join('tasks/v1', @task)
    end

    def merge(source)
      return unless source.directory?

      @root.mkpath
      FileUtils.cp_r(source.children, @root)
    end

    def dependencies
      name = @group == 'rails' ? 'base' : @group
      ['', '.lock'].each do |suffix|
        FileUtils.cp(ROOT.join("runtime/#{name}.Gemfile#{suffix}"), @root.join("Gemfile#{suffix}"))
      end
    end

    def packages
      @root.join('packs.yml').write("pack_paths:\n  - packs/*\n")
      @root.join('packwerk.yml').write(POLICY)
      extracted = @task != 'boundary-extraction' || @solution != 'starting'
      if extracted
        package('knowledge', [])
        package('answering', ['packs/knowledge'])
      end
      dependencies = extracted ? '[packs/knowledge]' : '[]'
      @root.join('package.yml').write("enforce_dependencies: true\ndependencies: #{dependencies}\n")
    end

    def package(name, dependencies)
      folder = @root.join('packs', name)
      folder.mkpath
      config = { 'enforce_dependencies' => true, 'enforce_privacy' => true, 'dependencies' => dependencies }
      folder.join('package.yml').write(config.to_yaml)
      move_owned_code(folder, name)
      return unless name == 'knowledge'

      target = folder.join('app/public/knowledge/catalog.rb')
      target.dirname.mkpath
      FileUtils.mv(folder.join('app/services/knowledge/catalog.rb'), target)
    end

    def move_owned_code(folder, name)
      %w[models services].each do |kind|
        source = @root.join('app', kind, name)
        next unless source.exist?

        target = folder.join('app', kind, name)
        target.dirname.mkpath
        FileUtils.mv(source, target)
      end
    end

    def foundry
      @root.join('config/foundry.yml').write("defaults:\n  profile: modular\nworkload: balanced\n" \
                                             "workflow:\n  specs: none\n")
      %w[knowledge answering].each do |name|
        folder = @root.join('packs', name)
        next unless folder.exist?

        folder.join('foundry.yml').write("schema: 1\nkind: domain\nprofile: modular\nnamespace: #{name.capitalize}\n")
      end
    end

    def instructions
      text = 'Use ordinary Rails and constructor injection. Workflow is none. Implement TASK.md, preserve public ' \
             'behavior, add focused tests, and run visible tests. ' \
             "Do not access external services or other workspaces.\n" \
             'Keep Gemfile, Gemfile.lock, AGENTS.md, TASK.md, ' \
             'test/visible_test.rb and test/test_helper.rb unchanged. ' \
             'Add regression tests in a new file such as test/regression_test.rb with a separate test class; ' \
             "adding tests to a protected file is still a protocol violation. Inspect git diff before finishing.\n"
      unless @group == 'rails'
        text += 'Use packs/packs-rails and Packwerk with enforced dependencies/privacy ' \
                'and public APIs in app/public. ' \
                "Run bundle exec ruby -rstringio -S packwerk validate and check. Do not add debt or disable checks.\n"
      end
      if @group == 'foundry'
        text += 'Read relevant installed skills under .agents/skills before planning, root and pack foundry.yml. ' \
                "Run bundle exec foundry check --sources as well as upstream boundary checks.\n"
      end
      text
    end
  end
end
