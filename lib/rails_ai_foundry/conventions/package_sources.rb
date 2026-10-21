# frozen_string_literal: true

require_relative 'package_files'

module RailsAIFoundry
  module Conventions
    class PackageSources < PackageFiles
      def paths
        select('app') { |path| path.end_with?('.rb') }
      end
    end
  end
end
