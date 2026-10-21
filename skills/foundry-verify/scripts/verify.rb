# frozen_string_literal: true

require_relative 'verification'

begin
  FoundrySkillVerification::Runner.new(ARGV).call
rescue FoundrySkillVerification::Failure, OptionParser::ParseError, SystemCallError => e
  warn "Verification failed: #{e.message}"
  exit 1
end
