# frozen_string_literal: true

require_relative 'contexts'
require_relative 'debt'
require_relative '../workflows/selection'

module RailsAIFoundry
  module Conventions
    class Assessment
      VERIFICATION = 'Configuration only; Rails was not booted and Packwerk boundaries were not checked.'

      def initialize(root)
        @configuration = ApplicationConfig.new(root)
        @files = @configuration.files
        @contexts = Contexts.new(root)
      end

      def call(specs: nil, adoption: false)
        @files.application!
        contexts = @contexts.all
        check_namespaces!(contexts)
        selection = Workflows::Selection.new(@files.root)
        workflow = selection.resolve(explicit: specs)
        result = { 'application' => @files.root, 'mode' => adoption ? 'adoption' : 'structural',
                   'workload' => @configuration.workload, 'workflow' => workflow,
                   'workflow_initialized' => selection.initialized?(workflow),
                   'contexts' => contexts.map { |path, intent| describe(path, intent) },
                   'verification' => VERIFICATION }
                 .merge(inventory(adoption))
        result.merge('next_steps' => next_steps(result))
      end

      private

      def inventory(adoption)
        result = { 'packages' => @contexts.packages }
        result['accepted_debt'] = Debt.identities(@files.root) if adoption
        result
      end

      def check_namespaces!(contexts)
        contexts.group_by { |_path, intent| intent.namespace }.each do |namespace, owners|
          next if owners.one?

          raise ConfigurationError, "Namespace #{namespace} has multiple owners: #{owners.map(&:first).join(', ')}."
        end
      end

      def describe(path, intent)
        { 'path' => path, 'configuration' => "#{path}/foundry.yml", 'namespace' => intent.namespace,
          'profile' => intent.profile, 'patterns' => intent.data.fetch('patterns') }
      end

      def next_steps(report)
        steps = ['Run owning-context behavioral tests.',
                 'Run foundry check --boundaries in an isolated test environment for upstream Packwerk verification.',
                 'Preserve accepted Packwerk baselines; do not regenerate debt during adoption or checking.']
        return steps unless report.fetch('mode') == 'adoption'

        package_steps(report) + steps + [workflow_step(report)]
      end

      def package_steps(report)
        contexts = report.fetch('contexts')
        packages = report.fetch('packages') - ['.']
        unconfigured = packages - contexts.map { |context| context.fetch('path') }
        steps = contexts.map do |context|
          path = context.fetch('path')
          "Assess #{path} (#{context.fetch('profile')}): foundry plan refactor --context=#{path}; " \
            'characterize behavior and retain current persistence during extraction.'
        end
        steps.concat(unconfigured.map do |path|
          "Review existing package #{path}; decide its ownership before adding #{path}/foundry.yml. " \
            'Keep its current root, public API and declared dependencies.'
        end)
        if packages.empty?
          steps << 'Choose one business boundary in app/ and characterize its endpoints before extracting a pack.'
        end
        steps
      end

      def workflow_step(report)
        workflow = report.fetch('workflow')
        if workflow == 'none'
          return 'Workflow none is selected; verify checkpoints with behavioral tests and architecture checks.'
        end
        if report.fetch('workflow_initialized')
          return "Preserve initialized #{workflow} artifacts and history; record the next adoption checkpoint there."
        end

        "Initialize selected #{workflow} explicitly before workflow-guided changes: " \
          "foundry setup --specs=#{workflow.tr('_', '-')}"
      end
    end
  end
end
