# frozen_string_literal: true

require_relative 'lib/rails_ai_foundry/version'

Gem::Specification.new do |spec|
  spec.name = 'rails_ai_foundry'
  spec.version = RailsAIFoundry::VERSION
  spec.authors = ['romfold']
  spec.summary = 'Agent skills and Rails conventions for AI-assisted development.'
  spec.description = 'Rails conventions, safe architecture installation, ' \
                     'native generators, upstream package boundaries, and versioned agent skills.'
  spec.license = 'MIT'
  spec.homepage = 'https://github.com/romfold/rails-ai-foundry'
  spec.metadata = {
    'source_code_uri' => spec.homepage,
    'documentation_uri' => "#{spec.homepage}/blob/main/README.md",
    'changelog_uri' => "#{spec.homepage}/blob/main/CHANGELOG.md",
    'bug_tracker_uri' => "#{spec.homepage}/issues"
  }
  spec.required_ruby_version = '>= 3.3'
  spec.bindir = 'exe'
  spec.executables = ['foundry']
  spec.files = File.readlines(File.join(__dir__, 'packaging/files.txt'), chomp: true)
  spec.require_paths = ['lib']
  spec.add_dependency 'benchmark', '>= 0.1', '< 1'
  spec.add_dependency 'dry-operation', '~> 1.1'
  spec.add_dependency 'packs', '~> 0.3.0'
  spec.add_dependency 'packs-specification', '~> 0.0.11'
  spec.add_dependency 'packwerk', '~> 3.1.0'
  spec.add_dependency 'packwerk-extensions', '~> 0.3.0'
  spec.add_dependency 'railties', '>= 7.1'
end
