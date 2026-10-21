# frozen_string_literal: true

module PromptFixtures
  def prompt(directory, owner:, agent: 'Other::AnswerAgent')
    data = { 'schema' => 1, 'owner' => owner, 'agent' => agent, 'templates' => ['instructions.txt'],
             'inputs' => { 'question' => 'untrusted' }, 'output_schema' => nil, 'tools' => [],
             'evaluations' => ['evaluation.yml'] }
    write("#{directory}/contract.yml", YAML.dump(data))
    write("#{directory}/instructions.txt", '<%= raise "Do not evaluate" %>')
    write("#{directory}/evaluation.yml", '!ruby/object:NeverExecute {}')
  end
end
