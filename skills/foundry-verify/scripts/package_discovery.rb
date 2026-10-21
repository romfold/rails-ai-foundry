# frozen_string_literal: true

require_relative 'package_inventory'

begin
  result = FoundrySkillVerification::PackageInventory.new(JSON.parse(ARGV.fetch(0))).call
  File.write(ARGV.fetch(1), JSON.generate(result))
rescue FoundrySkillVerification::DiscoveryFailure => e
  warn "Package discovery failed: #{e.message}"
  exit 1
rescue StandardError => e
  warn "Package discovery failed (#{e.class}); inspect application package/test configuration."
  exit 1
end
