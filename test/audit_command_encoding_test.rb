# frozen_string_literal: true

require_relative 'test_helper'
require 'json'

class AuditCommandEncodingTest < FoundryTest
  def test_utf8_parity_evidence_loads_under_ascii_locale
    write('parity.json', JSON.generate('success' => true, 'tool_output' => "\u{1f4e6}"))
    code = <<~RUBY
      require 'rails_ai_foundry/conventions/audit_command'
      class RailsAIFoundry::Conventions::DebtAudit
        def verify(evidence)
          raise 'Lost UTF-8 output' unless evidence['tool_output'] == "\\u{1f4e6}"
          evidence
        end
      end
      exit RailsAIFoundry::Conventions::AuditCommand.new.call(ARGV)
    RUBY
    output, error, status = Open3.capture3({ 'LC_ALL' => 'C' }, RbConfig.ruby, '-EUS-ASCII',
                                           '-Ilib', '-e', code, 'parity', "--root=#{@root}",
                                           "--verify=#{File.join(@root, 'parity.json')}")
    assert status.success?, "#{output}\n#{error}"
    assert JSON.parse(output.force_encoding(Encoding::UTF_8))['success']
  end
end
