# frozen_string_literal: true

module Voice
  class ChangeTurn
    ACTIONS = %w[turn interrupt reconnect].freeze

    def call(tenant_id:, session_id:, action:)
      raise ArgumentError, 'Unknown control action' unless ACTIONS.include?(action)

      session = Session.find_by!(id: session_id, tenant_id: tenant_id)
      session.with_lock do
        session.update!(epoch: session.epoch + 1, state: action == 'turn' ? 'active' : 'idle', last_sequence: -1)
        Frame.where(session_id: session.id).delete_all
        event_id = SecureRandom.uuid
        Control.create!(event_id: event_id, payload: { 'event_id' => event_id, 'session_id' => session.id,
                                                       'epoch' => session.epoch, 'action' => action })
      end
      session
    end
  end
end
