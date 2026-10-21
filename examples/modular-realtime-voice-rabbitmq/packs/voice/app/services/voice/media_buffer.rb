# frozen_string_literal: true

module Voice
  # Separate bounded PCM transport. Broker messages never carry audio bytes.
  class MediaBuffer
    MAX_FRAMES = 32
    MAX_BYTES = 4096

    def push(tenant_id:, session_id:, epoch:, sequence:, data:)
      raise ArgumentError, 'Oversized or empty media frame' unless data.bytesize.between?(1, MAX_BYTES)

      session = Session.find_by!(id: session_id, tenant_id: tenant_id)
      session.with_lock do
        return :stale unless session.epoch == epoch && session.state == 'active'
        return :duplicate if sequence <= session.last_sequence
        return :full if Frame.where(session_id: session.id).count >= MAX_FRAMES

        Frame.create!(session_id: session.id, epoch: epoch, sequence: sequence, data: data)
        session.update!(last_sequence: sequence)
        :accepted
      end
    end

    def shift(tenant_id:, session_id:, epoch:)
      session = Session.find_by!(id: session_id, tenant_id: tenant_id)
      session.with_lock do
        return unless session.epoch == epoch && session.state == 'active'

        frame = Frame.where(session_id: session.id, epoch: epoch).order(:sequence).first
        frame&.destroy!
        frame&.data
      end
    end
  end
end
