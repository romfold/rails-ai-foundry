# frozen_string_literal: true

begin
  require 'rspec/core'
  raise LoadError unless Gem.loaded_specs.key?('rspec-rails')
rescue LoadError
  warn 'RSpec verification requires rspec-core and rspec-rails in the application test bundle. ' \
       'Add compatible versions and run bundle install explicitly.'
  exit 1
end

require_relative 'rspec_formatter'
exit RSpec::Core::Runner.run([*ARGV, '--format', 'progress', '--format', 'FoundrySkillVerification::RSpecFormatter'])
