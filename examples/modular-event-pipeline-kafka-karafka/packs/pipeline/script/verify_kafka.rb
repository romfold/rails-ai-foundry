# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
require 'securerandom'
require 'tmpdir'
require 'timeout'
ENV['KAFKA_TOPIC'] = "foundry_test_#{SecureRandom.hex(6)}"
ENV['KAFKA_GROUP'] = ENV.fetch('KAFKA_TOPIC')
abort 'Loopback Kafka required' unless ENV.fetch('KAFKA_BROKERS', '127.0.0.1:59092') == '127.0.0.1:59092'
require_relative '../../../test/network_guard'
require_relative '../../../config/environment'

module KafkaAcceptance
  module_function

  def publish(sequence, version: 1)
    data = { event_id: "#{ENV.fetch('KAFKA_TOPIC')}-#{sequence}", tenant: 'a',
             stream_key: ENV.fetch('KAFKA_TOPIC'), sequence: sequence, version: version,
             (version == 1 ? :amount : :delta) => 10 }
    Karafka.producer.produce_sync(topic: ENV.fetch('KAFKA_TOPIC'), key: 'a:orders', payload: JSON.generate(data))
  end

  def consume_until(position, marker)
    command = ['bundle', 'exec', 'ruby', 'test/karafka_worker.rb']
    puts "Running: #{command.join(' ')}"
    pid = Process.spawn({ 'FAIL_ONCE_MARKER' => marker }, *command, pgroup: true)
    begin
      Timeout.timeout(45) do
        loop do
          cursor = Pipeline::Cursor.find_by(tenant: 'a', stream_key: ENV.fetch('KAFKA_TOPIC'))
          break if cursor&.position == position

          sleep 0.1
        end
      end
    ensure
      Process.kill('TERM', -pid)
      _, status = Timeout.timeout(15) { Process.wait2(pid) }
      raise "Karafka exited unsuccessfully: #{status}" unless status.success?
    end
  end
end

config = ApplicationRecord.connection_db_config.configuration_hash
abort 'Disposable test database required' unless config[:database].end_with?('_test')
admin = Rdkafka::Config.new('bootstrap.servers': ENV.fetch('KAFKA_BROKERS', '127.0.0.1:59092')).admin
admin.create_topic(ENV.fetch('KAFKA_TOPIC'), 1, 1).wait
Dir.mktmpdir('foundry-kafka-') do |directory|
  marker = File.join(directory, 'failure')
  KafkaAcceptance.publish(1)
  KafkaAcceptance.publish(1)
  KafkaAcceptance.publish(2, version: 2)
  KafkaAcceptance.consume_until(2, marker)
  raise 'Transient retry was not exercised' unless File.exist?(marker)

  KafkaAcceptance.publish(3)
  KafkaAcceptance.consume_until(3, marker)
  cursor = Pipeline::Cursor.find_by!(tenant: 'a', stream_key: ENV.fetch('KAFKA_TOPIC'))
  raise 'Duplicate effects or lost ordering' unless cursor.total == 30

  puts 'Real Kafka/Karafka verified ordering, duplicate delivery, v1/v2 schemas, transient retry and consumer restart.'
end
admin.delete_topic(ENV.fetch('KAFKA_TOPIC')).wait
admin.close
Karafka.producer.close
