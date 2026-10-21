# frozen_string_literal: true

require 'json'
require_relative 'version'

module RailsAIFoundry
  module Contracts
    REPORT_SCHEMA = 1
    SCHEMA_ROOT = File.expand_path('../../schemas', __dir__)

    def self.report(kind, data)
      data.merge('report_schema' => REPORT_SCHEMA, 'foundry_version' => VERSION, 'report_kind' => kind)
    end

    def self.inventory
      require_relative 'conventions/component_installer'
      require_relative 'generation/skill_installer'

      report('contracts', {
               'configuration_schema' => 1,
               'schemas' => Dir.glob('*-v1.json', base: SCHEMA_ROOT).sort.to_h do |name|
                 [name.delete_suffix('-v1.json'), File.join(SCHEMA_ROOT, name)]
               end,
               'generators' => (%w[context agent skills] + Conventions::ComponentInstaller::KINDS).sort,
               'skills' => Generation::SkillInstaller::NAMES,
               'skill_targets' => Generation::SkillInstaller::TARGETS,
               'public_ruby_api' => ['RailsAIFoundry::VERSION']
             })
    end
  end
end
