# frozen_string_literal: true

class DeliveryPollJob < ApplicationJob
  def perform
    deliver
    Rails.configuration.x.search.poll_rebuilds
  end

  private

  def deliver
    catalog = Rails.configuration.x.knowledge
    store = Rails.configuration.x.event_store
    publisher = Knowledge::PublishIntent.new(catalog: catalog, event_store: store)
    worker = Search::DeliverProjection.new(catalog: catalog, service: Rails.configuration.x.search, event_store: store)
    drain('res') { publisher.call }
    %w[search vectors].each { |target| drain(target) { worker.call(target: target) } }
  end

  def drain(target)
    100.times { break unless yield }
  rescue StandardError => e
    # Persisted retry state survives this wake-up; other destinations still progress.
    ActiveSupport::Notifications.instrument('delivery_failure.knowledge', target: target, error: e.class.name)
  end
end
