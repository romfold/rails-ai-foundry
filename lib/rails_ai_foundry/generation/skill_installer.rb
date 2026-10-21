# frozen_string_literal: true

require_relative '../errors'
require 'digest'
require 'json'
require_relative '../version'
require_relative 'scaffold_installer'

module RailsAIFoundry
  module Generation
    class SkillInstaller < ScaffoldInstaller
      ROOT = File.expand_path('../../../skills', __dir__)
      TARGETS = { 'agents' => '.agents/skills', 'claude' => '.claude/skills', 'cursor' => '.cursor/skills' }.freeze
      NAMES = %w[foundry-add-package foundry-add-feature foundry-architecture-review foundry-verify
                 foundry-profile-promotion foundry-event-workflow foundry-adopt-existing-app foundry-plan].freeze

      def initialize(root, target: 'agents')
        super(root)
        @target = target
      end

      def call(pretend: false)
        require_relative 'skill_upgrade'
        SkillUpgrade::Store.new(@file_system.root).lock do
          SkillUpgrade::Command.new(@file_system.root, target: @target).assert_idle!
          install_files(files, receipt: ".foundry/skills/#{@target}.json", pretend: pretend)
        end
      end

      def files
        destination = TARGETS.fetch(@target) { raise InstallationError, 'Use target agents, claude or cursor.' }
        files = catalog_files(destination)
        receipt = ".foundry/skills/#{@target}.json"
        digests = files.transform_values { |content| Digest::SHA256.hexdigest(content) }
        files[receipt] = "#{JSON.pretty_generate('version' => VERSION, 'files' => digests)}\n"
        files
      end

      private

      def catalog_files(destination)
        NAMES.each_with_object({}) do |name, result|
          base = "#{destination}/#{name}"
          result["#{base}/SKILL.md"] = File.binread(File.join(ROOT, name, 'SKILL.md'))
          result.merge!(local_resources(name, base))
          %w[planning packs rag ai workflows spec-kit openspec native-conventions
             adoption-checkpoints behavioral-recovery reviewed-ai-work delivery-extraction].each do |reference|
            result["#{base}/references/#{reference}.md"] =
              File.binread(File.join(ROOT, 'references', "#{reference}.md"))
          end
        end
      end

      def local_resources(name, destination)
        paths = Dir[File.join(ROOT, name, '{scripts,references}', '**', '*')].select { |path| File.file?(path) }
        paths.to_h do |path|
          ["#{destination}/#{path.delete_prefix("#{ROOT}/#{name}/")}", File.binread(path)]
        end
      end
    end
  end
end
