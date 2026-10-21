# frozen_string_literal: true

namespace :foundry do
  desc 'Check native configuration without booting the application; boundaries require an explicit task'
  task check: 'architecture:check'

  namespace :architecture do
    desc 'Check native context configuration without booting the application'
    task :check do
      require 'rails_ai_foundry/conventions/assessment_command'
      status = RailsAIFoundry::Conventions::AssessmentCommand.new.call(['check', "--root=#{Rails.root}"])
      exit status unless status.zero?
    end

    desc 'Check native context configuration without booting the application'
    task conventions: :check

    desc 'Find explicit Foundry dependencies in native Ruby sources without booting the application'
    task :sources do
      require 'rails_ai_foundry/conventions/assessment_command'
      status = RailsAIFoundry::Conventions::AssessmentCommand.new.call(['check', "--root=#{Rails.root}", '--sources'])
      exit status unless status.zero?
    end

    desc 'Run upstream Packwerk in test; this may boot the application'
    task :boundaries do
      require 'rails_ai_foundry/conventions/assessment_command'
      arguments = ['check', "--root=#{Rails.root}", '--boundaries']
      status = RailsAIFoundry::Conventions::AssessmentCommand.new.call(arguments)
      exit status unless status.zero?
    end
  end
end
