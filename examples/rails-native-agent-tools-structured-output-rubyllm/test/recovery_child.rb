# frozen_string_literal: true

# Invoked only by process acceptance in the disposable test environment.
abort 'Test only' unless Rails.env.test?
checkpoint = lambda do |point|
  next unless point.to_s == ENV.fetch('CRASH_POINT')

  $stdout.puts 'CHECKPOINT'
  $stdout.flush
  $stdin.read
end
id = Integer(ENV.fetch('WORK_ID'))
if ENV.fetch('CRASH_POINT') == 'after_provider'
  Assistance::GenerateResolution.call(id, checkpoint: checkpoint)
else
  Assistance::ExecuteResolution.call(id, checkpoint: checkpoint)
end
