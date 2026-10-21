# frozen_string_literal: true

module Knowledge
  class PublishDelivery
    def call(delivery_id:, store:)
      delivery = Delivery.find(delivery_id)
      payload = JSON.parse(delivery.payload)
      begin
        store.publish(id: delivery.event_id, type: 'DocumentPublished', data: payload)
      rescue store.duplicate_error
        existing = store.read(delivery.event_id)
        raise 'conflicting event' unless existing == { type: 'DocumentPublished', data: payload }
      end
      delivery.update!(delivered: true)
      :delivered
    end
  end
end
