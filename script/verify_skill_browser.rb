# frozen_string_literal: true

require 'open3'
require 'shellwords'
require 'json'

image = ARGV.fetch(0) { abort 'Usage: ruby script/verify_skill_browser.rb PREPARED_FIZZY_IMAGE' }
root = File.expand_path('..', __dir__)
setup = <<~SH
  set -eu
  mkdir -p test/verification_fixture
  cp /fixtures/page.rb test/verification_fixture/page.rb
  cp /fixtures/caller.rb test/verification_fixture/caller_test.rb
  cp /fixtures/browser.rb test/verification_fixture/browser_test.rb
  exec ruby /verification/scripts/verify.rb --app /app \
    --baseline test/verification_fixture/caller_test.rb \
    --caller test/verification_fixture/caller_test.rb \
    --realtime --browser test/verification_fixture/browser_test.rb --timeout 120
SH
results = %w[valid caller browser].to_h do |control|
  command = ['docker', 'run', '--rm', '--init', '--network', 'none', '--cap-drop', 'ALL',
             '--security-opt', 'no-new-privileges', '--pids-limit', '1024', '--memory', '2g', '--cpus', '2',
             '--env', "FOUNDRY_FIXTURE_FAULT=#{control}", '--env', 'PARALLEL_WORKERS=1',
             '--env', 'SE_OFFLINE=true', '--env', 'SE_AVOID_STATS=true',
             '--mount', "type=bind,source=#{root}/skills/foundry-verify,target=/verification,readonly",
             '--mount', "type=bind,source=#{root}/test_packaging/fixtures/verification,target=/fixtures,readonly",
             '--entrypoint', 'sh', image, '-c', setup]
  puts command.shelljoin
  $stdout.flush
  stdout, stderr, status = Open3.capture3(*command)
  puts stdout
  warn stderr unless stderr.empty?
  expected = if control == 'valid'
               status.success? && stdout.include?('Verified browser: 1 tests')
             else
               phase = control == 'caller' ? 'baseline' : 'browser'
               !status.success? && stderr.include?("#{phase}: command failed") && stdout.match?(/(?:Failure|Error):/)
             end
  abort "Unexpected #{control} control outcome" unless expected

  [control, { 'exit_status' => status.exitstatus, 'expected_outcome' => true }]
end
puts JSON.pretty_generate('image' => image, 'controls' => results, 'provider_calls' => 0)
