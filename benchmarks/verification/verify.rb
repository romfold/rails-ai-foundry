# frozen_string_literal: true

require 'json'
require 'open3'
require 'yaml'

# Shipped only as verifier material, never in the candidate image.
module FoundryVerification
  module_function

  def run(*argv, env: {})
    puts argv.join(' ')
    output, status = Open3.capture2e(env, *argv)
    puts output
    { 'exit_code' => status.exitstatus, 'output' => output }
  end

  def behavior(result, minimum)
    summary = result['output'].scan(/(\d+) runs, (\d+) assertions, (\d+) failures, (\d+) errors, (\d+) skips/).last
    return 'infrastructure_error' unless summary
    return 'failed' unless result['exit_code'].zero?

    valid_summary?(summary.map(&:to_i), minimum) ? 'passed' : 'failed'
  end

  def valid_summary?(summary, minimum)
    tests, assertions, *failures = summary
    tests >= minimum && assertions.positive? && failures.all?(&:zero?)
  end

  def package_errors(path)
    config = YAML.safe_load_file(path)
    errors = []
    errors << "Dependency enforcement missing: #{path}" unless config['enforce_dependencies'] == true
    errors << "Privacy enforcement missing: #{path}" if path != 'package.yml' && config['enforce_privacy'] != true
    errors
  end

  def policy(group)
    errors = Dir['**/package.yml'].flat_map { |path| package_errors(path) }
    errors << 'Knowledge package missing' unless File.directory?('packs/knowledge')
    errors << 'New debt prohibited' unless Dir['**/package_todo.yml'].empty?
    expected = { 'require' => ['packwerk-extensions'], 'exclude' => %w[test/**/* tmp/**/* log/**/*] }
    errors << 'Packwerk policy changed' unless YAML.safe_load_file('packwerk.yml') == expected
    errors.concat(foundry_errors) if group == 'foundry'
    errors
  end

  def foundry_errors
    path = 'packs/knowledge/foundry.yml'
    return ['Modular Knowledge missing'] unless File.file?(path)
    return [] if YAML.safe_load_file(path)['profile'] == 'modular'

    ['Modular Knowledge missing']
  end

  def architecture_commands(group)
    commands = %w[validate check].map { |verb| ['bundle', 'exec', 'ruby', '-rstringio', '-S', 'packwerk', verb] }
    commands << ['bundle', 'exec', 'foundry', 'check', '--sources'] if group == 'foundry'
    commands
  end

  def architecture(group)
    return { 'status' => 'not_applicable' } if group == 'rails'

    errors = policy(group)
    checks = architecture_commands(group).map { |command| run(*command) }
    passed = errors.empty? && checks.all? { |row| row['exit_code'].zero? }
    { 'status' => passed ? 'passed' : 'failed', 'policy_errors' => errors, 'checks' => checks }
  end

  def results(task)
    visible = run('bundle', 'exec', 'ruby', 'test/visible_test.rb')
    hidden = run('bundle', 'exec', 'ruby', '-I/tests', '-report-lemans', '/tests/acceptance_test.rb',
                 env: { 'BENCHMARK_TASK' => task.fetch('task') })
    { 'visible' => behavior(visible, 2), 'behavioral' => behavior(hidden, 3),
      'architecture' => architecture(task.fetch('group')) }
  end

  def call
    result = results(JSON.parse(File.read('/tests/task.json')))
    File.write(File.join(ENV.fetch('LOGS'), 'foundry.json'), JSON.pretty_generate(result))
    passed = result.values_at('visible', 'behavioral').all? { |value| value == 'passed' } &&
             %w[passed not_applicable].include?(result['architecture']['status'])
    exit(passed ? 0 : 1)
  end
end

FoundryVerification.call
