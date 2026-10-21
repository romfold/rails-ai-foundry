# frozen_string_literal: true

require 'optparse'
require 'json'
require_relative 'refactor'
require_relative '../contracts'

module RailsAIFoundry
  module Conventions
    class RefactorCommand
      def call(arguments, stdout: $stdout, stderr: $stderr)
        options = parse(arguments)
        result = Refactor.new(options.fetch(:root)).call(context: options.fetch(:context), profile: options[:profile])
        result = Contracts.report('refactor', result)
        stdout.puts(options[:format] == 'json' ? JSON.pretty_generate(result) : render(result))
        result.fetch('complete') ? 0 : 1
      rescue OptionParser::ParseError, ConfigurationError, SystemCallError => e
        stderr.puts e.message
        1
      end

      private

      def parse(arguments)
        arguments = arguments.first == 'refactor' ? arguments.drop(1) : arguments.dup
        settings = { root: Dir.pwd, format: 'text' }
        parser(settings).parse!(arguments)
        raise OptionParser::MissingArgument, '--context=NAME' unless settings[:context]
        raise OptionParser::InvalidArgument, arguments.join(' ') unless arguments.empty?

        settings
      end

      def parser(settings)
        OptionParser.new do |parser|
          parser.on('--root=PATH') { |value| settings[:root] = value }
          parser.on('--context=NAME') { |value| settings[:context] = value }
          parser.on('--profile=PROFILE') { |value| settings[:profile] = value }
          parser.on('--format=FORMAT', %w[text json]) { |value| settings[:format] = value }
        end
      end

      def render(result)
        findings = result.fetch('findings').map do |finding|
          "#{finding.fetch('path')}:#{finding.fetch('line')} [#{finding.fetch('certainty')}] #{finding.fetch('advice')}"
        end
        ["Read-only assessment: #{result.fetch('context')}",
         "Profile: #{result.fetch('profile')}; proposed: #{result.fetch('proposed_profile')}",
         *findings, result.fetch('limitations'), *result.fetch('next_steps')].join("\n")
      end
    end
  end
end
