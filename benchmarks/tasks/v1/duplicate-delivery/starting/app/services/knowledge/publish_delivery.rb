# frozen_string_literal: true

module Knowledge
  class PublishDelivery
    def call(delivery_id:, store:)
      delivery = Delivery.find(delivery_id)
      payload = JSON.parse(delivery.payload)

      store.publish(id: delivery.event_id, type: 'DocumentPublished', data: payload)

      delivery.update!(delivered: true)
      :delivered
    end
  end
end
