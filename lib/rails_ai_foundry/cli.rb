# frozen_string_literal: true

module RailsAIFoundry
  class CLI
    def call(arguments, stdout: $stdout, stderr: $stderr)
      return information_command(arguments, stdout) if [%w[--version], %w[contracts]].include?(arguments)

      if %w[new adopt check setup doctor audit parity].include?(arguments.first)
        return native_command(arguments.first).call(arguments, stdout: stdout, stderr: stderr)
      end

      if arguments.first(2) == %w[plan refactor]
        require_relative 'conventions/refactor_command'
        return Conventions::RefactorCommand.new.call(arguments.drop(1), stdout: stdout, stderr: stderr)
      end

      stderr.puts 'Usage: foundry new NAME [--specs=spec-kit|openspec|none] [--pretend] | ' \
                  'foundry adopt|check [--root=PATH] [--format=text|json] [--sources] ' \
                  '(check also accepts --prompts and --boundaries) | ' \
                  'foundry setup --specs=spec-kit|openspec|none [--root=PATH] [--pretend] | ' \
                  'foundry audit|parity [--root=PATH] [--pks=PATH] [--verify=PATH] | ' \
                  'foundry doctor [--root=PATH] | foundry plan refactor --context=NAME [--profile=PROFILE] | ' \
                  'foundry contracts | foundry --version'
      1
    end

    private

    def information_command(arguments, stdout)
      require_relative 'contracts'
      stdout.puts(arguments == ['--version'] ? VERSION : JSON.pretty_generate(Contracts.inventory))
      0
    end

    def native_command(action)
      case action
      when 'audit', 'parity'
        require_relative 'conventions/audit_command'
        Conventions::AuditCommand.new
      when 'new'
        require_relative 'conventions/new_command'
        Conventions::NewCommand.new
      when 'adopt', 'check'
        require_relative 'conventions/assessment_command'
        Conventions::AssessmentCommand.new
      else
        require_relative 'workflows/command'
        Workflows::Command.new
      end
    end
  end
end
