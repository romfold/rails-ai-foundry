# frozen_string_literal: true

require_relative 'test_helper'

class LoadTest < FoundryTest
  def test_native_tooling_stays_boot_free
    code = <<~RUBY
      require 'rails_ai_foundry/conventions/context_installer'
      require 'rails_ai_foundry/conventions/component_installer'
      require 'rails_ai_foundry/conventions/assessment_command'
      require 'rails_ai_foundry/workflows/setup'
      abort 'Rails loaded' if defined?(Rails)
      abort 'Legacy installer loaded' if defined?(RailsAIFoundry::Generation::Installer)
      abort 'Manifest loaded' if defined?(RailsAIFoundry::Architecture::Manifest)
      abort 'Graph loaded' if defined?(RailsAIFoundry::Architecture::Graph)
      abort 'Runtime loaded' if defined?(RailsAIFoundry::Runtime)
      abort 'Composition loaded' if defined?(Dry::System)
    RUBY
    _, error, status = Open3.capture3(RbConfig.ruby, '-Ilib', '-e', code)
    assert status.success?, error
  end

  def test_plain_require_does_not_load_rails
    code = "require 'rails_ai_foundry'; " \
           'abort if defined?(Rails) || defined?(Parser) || defined?(RailsAIFoundry::Architecture); ' \
           'puts RailsAIFoundry::VERSION'
    output, error, status = Open3.capture3(RbConfig.ruby, '-Ilib', '-e', code)
    assert status.success?, error
    assert_equal "#{RailsAIFoundry::VERSION}\n", output
  end

  def test_removed_execution_files_are_not_shipped
    root = File.expand_path('../lib/rails_ai_foundry', __dir__)
    %w[runtime package_loading composition operation command query record event aggregate unit_of_work
       ruby_llm].each do |name|
      refute File.exist?(File.join(root, "#{name}.rb")), name
    end
    refute(Gem.loaded_specs.fetch('rails_ai_foundry').dependencies.any? do |dependency|
      dependency.name == 'dry-system'
    end)
  end
end
