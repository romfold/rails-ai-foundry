# frozen_string_literal: true

at_exit do
  legacy = $LOADED_FEATURES.select do |path|
    path.match?(%r{/rails_ai_foundry/architecture/(manifest|graph|checker)\.rb\z}) ||
      path.match?(%r{/rails_ai_foundry/(runtime\.rb|package_loading\.rb|unit_of_work\.rb|ai/|events/)}) ||
      path.match?(%r{/rails_ai_foundry/generation/(installer|component_installer|operation_installer)\.rb\z})
  end
  abort "Native generation loaded legacy implementation: #{legacy.join(', ')}" unless legacy.empty?
end
