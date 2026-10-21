# frozen_string_literal: true

require 'optparse'
require_relative 'new_application'

module RailsAIFoundry
  module Conventions
    class NewCommand
      def call(arguments, stdout: $stdout, stderr: $stderr)
        options = arguments.drop(1)
        settings = parse(options)
        raise OptionParser::InvalidArgument, 'Provide exactly one new application name.' unless options.one?

        stdout.puts NewApplication.new(settings.delete(:root), stdout: stdout).call(options.first, **settings)
        0
      rescue OptionParser::ParseError, ConfigurationError, InstallationError, SystemCallError, Gem::Exception => e
        stderr.puts e.message
        1
      end

      private

      def parse(options)
        settings = { root: Dir.pwd }
        OptionParser.new do |parser|
          %i[root specs agent database].each do |key|
            parser.on("--#{key}=VALUE") { |value| settings[key] = value }
          end
          %i[pretend skip_git skip_dev_gems].each do |key|
            parser.on("--#{key.to_s.tr('_', '-')}") { settings[key] = true }
          end
        end.parse!(options)
        settings
      end
    end
  end
end
