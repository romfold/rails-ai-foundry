# frozen_string_literal: true

module ContractReportHelpers
  private

  def consumer
    write('Gemfile', "raise 'must not evaluate application Gemfile'")
    write('config/application.rb', "raise 'must not boot application'")
  end

  def cli(*arguments, status: 0)
    arguments += ["--root=#{@root}"] unless arguments == ['contracts']
    stdout = StringIO.new
    stderr = StringIO.new
    assert_equal status, RailsAIFoundry::CLI.new.call(arguments, stdout: stdout, stderr: stderr), stderr.string
    JSON.parse(stdout.string)
  end

  def report!(schema, report)
    assert_equal 1, report['report_schema']
    assert_equal RailsAIFoundry::VERSION, report['foundry_version']
    sample!("#{schema}-#{report['report_kind']}-#{report['success']}",
            { 'schema' => schema, 'valid' => true, 'data' => report })
  end

  def sample!(name, data)
    return unless ENV['FOUNDRY_CONTRACT_SAMPLES']

    File.write(File.join(ENV.fetch('FOUNDRY_CONTRACT_SAMPLES'), "#{self.name}-#{name}.json"), JSON.generate(data))
  end
end
