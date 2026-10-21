# frozen_string_literal: true

module Pipeline
  class BrokerApp < Karafka::App
    setup do |config|
      config.kafka = { 'bootstrap.servers': ENV.fetch('KAFKA_BROKERS', '127.0.0.1:59092'),
                       'allow.auto.create.topics': true }
      config.client_id = 'foundry_pipeline'
      config.concurrency = 2
      config.pause_timeout = 100
      config.shutdown_timeout = 5000
      config.consumer_persistence = !Rails.env.development?
    end

    routes.draw do
      consumer_group ENV.fetch('KAFKA_GROUP', 'foundry_pipeline') do
        topic ENV.fetch('KAFKA_TOPIC', 'foundry_events') do
          consumer EventsConsumer
        end
      end
    end
  end
end
