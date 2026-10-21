# frozen_string_literal: true

RubyLLM.configure { |config| config.use_new_acts_as = true }
Rails.application.reloader.to_prepare do
  previous = Rails.configuration.x.knowledge
  previous.disconnect if previous.respond_to?(:disconnect)
  previous_search = Rails.configuration.x.search
  previous_search.disconnect if previous_search.respond_to?(:disconnect)
  config = ActiveRecord::Base.connection_db_config.configuration_hash
  url = "postgres://#{config.fetch(:username)}:#{config.fetch(:password)}@#{config.fetch(:host)}:" \
        "#{config.fetch(:port)}/#{config.fetch(:database)}"
  catalog = Knowledge::Catalog.new(url: url)
  Rails.configuration.x.knowledge = catalog
  Rails.configuration.x.search = Search::Service.new(
    catalog: catalog, url: url, elasticsearch_url: ENV.fetch('ELASTICSEARCH_URL', 'http://127.0.0.1:59210'),
    index_name: "foundry_knowledge_#{Rails.env}"
  )
  Rails.configuration.x.event_store = RailsEventStore::JSONClient.new
end
