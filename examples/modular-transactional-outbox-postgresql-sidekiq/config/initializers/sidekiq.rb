# frozen_string_literal: true

redis = { url: ENV.fetch('REDIS_URL', 'redis://127.0.0.1:56379/11'), network_timeout: 2, pool_timeout: 2 }
Sidekiq.configure_client { |config| config.redis = redis }
Sidekiq.configure_server { |config| config.redis = redis }
