# frozen_string_literal: true

require 'json'
require 'fileutils'
require 'open3'
require 'shellwords'

# Independent verifier material: uploaded only after the candidate is frozen.
module ReviewedVerification
  module_function

  def check(command)
    puts Shellwords.join(command)
    output, status = Open3.capture2e(*command)
    puts output
    [status.success? && valid_summary?(output) ? 'pass' : 'fail', output]
  end

  def valid_summary?(output)
    summary = output.scan(/(\d+) runs, (\d+) assertions, (\d+) failures, (\d+) errors, (\d+) skips/).last
    summary && summary[0].to_i.positive? && summary[1].to_i.positive? &&
      summary.drop(2).all? { |value| value.to_i.zero? }
  end

  def call
    FileUtils.cp_r(Dir['/tests/test/*'], 'test')
    checks, outputs = behavior_checks
    architecture_checks(checks)
    persist(checks, outputs)
    exit(checks.values.all? { |status| status == 'pass' } ? 0 : 1)
  end

  def behavior_checks
    checks = {}
    outputs = {}
    { 'behavior' => ['bin/rails', 'test'],
      'http' => ['bin/rails', 'test', 'test/acceptance_test.rb'],
      'durability' => ['bin/rails', 'test', 'test/recovery_test.rb'],
      'browser' => ['bin/rails', 'test', 'test/review_browser_test.rb'] }.each do |name, args|
      checks[name], outputs[name] = check(['bundle', 'exec', 'ruby', *args])
    end
    [checks, outputs]
  end

  def architecture_checks(checks)
    %w[validate check].each do |verb|
      checks["packages_#{verb}"] =
        system('bundle', 'exec', 'ruby', '-rstringio', '-S', 'packwerk', verb) ? 'pass' : 'fail'
    end
    return unless File.read('/tests/group.txt') == 'foundry'

    checks['foundry'] = system('bundle', 'exec', 'foundry', 'check', '--sources', '--prompts') ? 'pass' : 'fail'
  end

  def persist(checks, outputs)
    logs = ENV.fetch('LOGS')
    File.write(File.join(logs, 'checks.json'), JSON.pretty_generate('checks' => checks))
    File.write(File.join(logs, 'reviewed.json'), JSON.pretty_generate('checks' => checks, 'outputs' => outputs))
  end
end

ReviewedVerification.call
