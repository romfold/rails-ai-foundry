# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
require_relative '../../../test/network_guard'
require_relative '../../../config/environment'
require 'sidekiq/api'
require 'timeout'

config = ApplicationRecord.connection_db_config.configuration_hash
abort 'Disposable loopback test database required' unless config[:database].end_with?('_test') &&
                                                          %w[127.0.0.1 localhost].include?(config[:host])
redis = URI(ENV.fetch('REDIS_URL', 'redis://127.0.0.1:56379/11'))
abort 'Loopback Redis database 11 required' unless %w[127.0.0.1 localhost].include?(redis.host) && redis.path == '/11'
Sidekiq::Queue.new('foundry_orders').clear
order = Orders::Place.new.call(tenant: 'worker-acceptance', cents: 123).value!
100.times { break unless Orders::Dispatch.new.call }
command = ['bundle', 'exec', 'sidekiq', '-r', './config/environment.rb', '-q', 'foundry_orders', '-c', '2', '-t', '2']
puts "Running: #{command.join(' ')}"
pid = Process.spawn(*command, pgroup: true)
begin
  Timeout.timeout(30) { sleep 0.1 until order.reload.state == 'fulfilled' }
  entry = Orders::OutboxEntry.find_by!("payload ->> 'order_id' = ?", order.id.to_s)
  raise 'Missing atomic acknowledgment' unless entry.completed_at && Orders::Receipt.exists?(outbox_entry_id: entry.id)

  puts 'Real Sidekiq worker consumed Redis job and committed fulfillment plus acknowledgment.'
ensure
  Process.kill('TERM', -pid)
  _, status = Timeout.timeout(10) { Process.wait2(pid) }
  raise "Sidekiq exited unsuccessfully: #{status}" unless status.success?
end
