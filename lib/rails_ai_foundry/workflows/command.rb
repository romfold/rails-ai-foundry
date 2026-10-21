# frozen_string_literal: true

require 'optparse'
require_relative 'setup'

module RailsAIFoundry
  module Workflows
    class Command
      def call(arguments, stdout: $stdout, stderr: $stderr)
        action, *options = arguments
        settings = parse(action, options)
        root = settings.delete(:root)
        setup = Setup.new(root, stdout: stdout)
        messages = action == 'doctor' ? setup.doctor(**settings) : setup.call(**settings)
        stdout.puts messages
        0
      rescue OptionParser::ParseError, ConfigurationError, InstallationError, SystemCallError => e
        stderr.puts e.message
        1
      end

      private

      def parse(action, options)
        settings = { root: Dir.pwd, agent: 'codex', greenfield: false }
        parser(settings).parse!(options)
        raise OptionParser::InvalidArgument, options.join(' ') unless options.empty?
        if action == 'doctor' && settings.key?(:pretend)
          raise OptionParser::InvalidArgument, 'doctor is already read-only; omit --pretend'
        end

        settings
      end

      def parser(settings)
        OptionParser.new do |options|
          options.on('--root=PATH') { |value| settings[:root] = value }
          options.on('--specs=WORKFLOW') { |value| settings[:specs] = value }
          options.on('--agent=AGENT') { |value| settings[:agent] = value }
          options.on('--greenfield') { settings[:greenfield] = true }
          options.on('--pretend') { settings[:pretend] = true }
        end
      end
    end
  end
end
