# frozen_string_literal: true

require_relative 'files'

module RailsAIFoundry
  module Conventions
    # Preserve complete application-owned scaffolds across template revisions.
    class AgentReceipt
      def initialize(files, pack, namespace)
        @files = files
        @pack = pack
        @namespace = namespace
      end

      def preserve(receipt, generated)
        return generated unless @files.exist?(receipt)

        data = @files.yaml(receipt)
        unless data['schema'].eql?(1) && data['namespace'] == @namespace && supported?(data['paths'], generated.keys)
          raise InstallationError, 'Conflicting agent receipt; review original scaffold ownership.'
        end

        (data.fetch('paths') + [receipt]).to_h do |path|
          content = @files.read(path)
          raise InstallationError, "Partial agent scaffold; restore #{path} before repeating generation." unless content

          [path, content]
        end
      end

      private

      def supported?(paths, current)
        return false unless paths.is_a?(Array) && paths.all?(String)

        original = current.reject { |path| path.end_with?('/evaluation.yml') }
        root_prompts = original.map { |path| path.sub(%r{\A#{Regexp.escape(@pack)}/app/prompts/}, 'app/prompts/') }
        [current, original, root_prompts].any? { |expected| paths.sort == expected.sort }
      end
    end
  end
end
