# frozen_string_literal: true

require 'json'
require 'optparse'
require_relative 'debt_audit'

module RailsAIFoundry
  module Conventions
    class AuditCommand
      def call(arguments, stdout: $stdout, stderr: $stderr)
        action, *options = arguments
        settings = parse(options)
        raise ConfigurationError, '--verify requires parity.' if settings[:evidence] && action != 'parity'

        report = assess(action, settings)
        stdout.puts JSON.pretty_generate(report)
        report['success'] ? 0 : 1
      rescue ConfigurationError, OptionParser::ParseError, SystemCallError, JSON::ParserError => e
        stderr.puts e.message
        1
      end

      private

      def assess(action, settings)
        audit = DebtAudit.new(settings[:root], pks: settings[:pks])
        return audit.call(parity: action == 'parity') unless settings[:evidence]

        audit.verify(JSON.parse(File.read(settings[:evidence], encoding: Encoding::UTF_8)))
      end

      def parse(arguments)
        settings = { root: Dir.pwd, pks: 'pks' }
        OptionParser.new do |parser|
          parser.on('--root=PATH') { |value| settings[:root] = value }
          parser.on('--pks=PATH') { |value| settings[:pks] = value }
          parser.on('--verify=PATH') { |value| settings[:evidence] = value }
        end.parse!(arguments)
        raise ConfigurationError, 'Unexpected audit arguments.' unless arguments.empty?

        settings
      end
    end
  end
end
