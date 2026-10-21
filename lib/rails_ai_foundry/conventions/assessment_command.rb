# frozen_string_literal: true

require 'json'
require 'optparse'
require 'shellwords'
require_relative 'assessment'
require_relative '../contracts'

module RailsAIFoundry
  module Conventions
    class AssessmentCommand
      def call(arguments, stdout: $stdout, stderr: $stderr)
        action, *options = arguments
        settings = parse(options)
        validate_action!(action, settings)
        report = Assessment.new(settings.fetch(:root)).call(specs: settings[:specs], adoption: action == 'adopt')
        verify_sources(report, settings)
        verify_prompts(report, settings)
        verify_boundaries(report, settings)
        publish(report, action, settings[:format], stdout)
        failed?(report) ? 1 : 0
      rescue OptionParser::ParseError, ConfigurationError, SystemCallError => e
        stderr.puts e.message
        1
      end

      private

      def publish(report, action, format, stdout)
        report = Contracts.report(action, report.merge('success' => !failed?(report)))
        stdout.puts(format == 'json' ? JSON.pretty_generate(report) : text(report))
      end

      def failed?(report)
        %w[sources prompts boundaries].any? { |check| report.dig(check, 'success') == false }
      end

      def validate_action!(action, settings)
        return unless (settings[:boundaries] || settings[:prompts]) && action != 'check'

        raise OptionParser::InvalidArgument, '--boundaries and --prompts are only supported by foundry check.'
      end

      def parse(arguments)
        settings = { root: Dir.pwd, format: 'text' }
        OptionParser.new do |options|
          options.on('--root=PATH') { |value| settings[:root] = value }
          options.on('--specs=WORKFLOW') { |value| settings[:specs] = value }
          options.on('--format=FORMAT', %w[text json]) { |value| settings[:format] = value }
          verification_options(options, settings)
        end.parse!(arguments)
        raise OptionParser::InvalidArgument, arguments.join(' ') unless arguments.empty?

        settings
      end

      def verification_options(options, settings)
        options.on('--boundaries') { settings[:boundaries] = true }
        options.on('--sources') { settings[:sources] = true }
        options.on('--prompts') { settings[:prompts] = true }
      end

      def text(report)
        ["Foundry #{report.fetch('mode')} assessment: #{report.fetch('application')}",
         "Workflow: #{report.fetch('workflow')}; workload: #{report.fetch('workload')}",
         "Context configurations validated: #{report.fetch('contexts').size}",
         report.fetch('verification'), *source_output(report), *prompt_output(report),
         *boundary_output(report), *report.fetch('next_steps')]
      end

      def verify_prompts(report, settings)
        return unless settings[:prompts]

        require_relative 'prompt_check'
        report['prompts'] = PromptCheck.new(settings.fetch(:root), contexts: report.fetch('contexts'),
                                                                   packages: report.fetch('packages')).call
      end

      def prompt_output(report)
        return [] unless report.key?('prompts')

        result = report.fetch('prompts')
        ["Prompt check: #{result.fetch('files_checked')} contracts; #{result.fetch('success') ? 'passed' : 'failed'}.",
         *result.fetch('diagnostics').map { |item| "#{item.fetch('file')}: #{item.fetch('message')}" },
         result.fetch('limitations')]
      end

      def verify_sources(report, settings)
        return unless settings[:sources]

        require_relative 'source_check'
        report['sources'] = SourceCheck.new(settings.fetch(:root), contexts: report.fetch('contexts'),
                                                                   packages: report.fetch('packages')).call
        report['verification'] = 'Configuration and selected Ruby sources checked without booting Rails; ' \
                                 'Packwerk boundaries were not checked.'
      end

      def source_output(report)
        return [] unless report.key?('sources')

        result = report.fetch('sources')
        ["Source check: #{result.fetch('files_checked')} Ruby files; #{result.fetch('success') ? 'passed' : 'failed'}.",
         *result.fetch('diagnostics').map do |item|
           "#{item.fetch('file')}:#{item.fetch('line')} " \
             "[#{item.fetch('severity')}/#{item.fetch('certainty')}:#{item.fetch('rule')}] " \
             "#{item.fetch('message')}"
         end, result.fetch('limitations')]
      end

      def verify_boundaries(report, settings)
        return unless settings[:boundaries]

        require_relative 'boundary_check'
        report['boundaries'] = BoundaryCheck.new(settings.fetch(:root)).call
        report['mode'] = 'boundaries'
        report['verification'] = 'Configuration checked; Packwerk ran in test and may have booted Rails.'
        report['next_steps'] = ['Review upstream diagnostics and baseline diffs.',
                                'Run owning-context behavioral tests.']
      end

      def boundary_output(report)
        return ['No files were changed.'] unless report.key?('boundaries')

        result = report.fetch('boundaries')
        output = result.fetch('commands').flat_map do |command|
          ["$ #{command.fetch('argv').shelljoin}", command.fetch('stdout'), command.fetch('stderr')]
        end
        output << "Packwerk: #{result.fetch('success') ? 'passed' : 'failed'}."
        output << result.fetch('limitations')
        output << baseline_message(result)
      end

      def baseline_message(result)
        return 'Accepted debt files unchanged.' if result.fetch('baselines_unchanged')

        'Accepted debt files changed during verification. Inspect the diff; no files were restored or regenerated.'
      end
    end
  end
end
