# frozen_string_literal: true

module Knowledge
  class DeliveryQueue
    LEASE_SECONDS = 30
    MAX_ATTEMPTS = 5

    def initialize(connection:, clock: -> { Time.now.utc })
      @db = connection
      @rows = @db[:knowledge_deliveries]
      @clock = clock
    end

    def enqueue(event_id:, target:, payload:)
      now = @clock.call
      @rows.insert_conflict(target: %i[event_id target]).insert(
        id: SecureRandom.uuid, event_id: event_id, target: target, payload: JSON.generate(payload),
        state: 'pending', available_at: now, created_at: now, updated_at: now
      )
    end

    def claim(target)
      @db.transaction do
        now = @clock.call
        row = eligible(target, now).order(:created_at, :id).for_update.skip_locked.first
        next unless row

        row.merge!(state: 'working', lease_token: SecureRandom.uuid, lease_until: now + LEASE_SECONDS,
                   attempts: row[:attempts] + 1, updated_at: now)
        @rows.where(id: row[:id]).update(row.except(:id))
        row
      end
    end

    def acknowledge(row, fanout: [])
      @db.transaction do
        owned = owned(row)
        next false unless owned.for_update.first

        fanout.each { |target| enqueue(event_id: row[:event_id], target: target, payload: JSON.parse(row[:payload])) }
        completed = owned.update(state: 'done', lease_token: nil, lease_until: nil, updated_at: @clock.call) == 1
        record_delivery(row) if completed
        completed
      end
    end

    def fail(row, code:, permanent: false)
      poison = permanent || row[:attempts] >= MAX_ATTEMPTS
      count = owned(row).update(state: poison ? 'poison' : 'pending', error_code: code,
                                available_at: @clock.call + [2**row[:attempts], 60].min,
                                lease_token: nil, lease_until: nil, updated_at: @clock.call)
      if count == 1
        ActiveSupport::Notifications.instrument('retry.knowledge', target: row[:target], attempts: row[:attempts],
                                                                   poison: poison)
      end
      count
    end

    def repair(id)
      @rows.where(id: id, state: 'poison').update(state: 'pending', attempts: 0, error_code: nil,
                                                  available_at: @clock.call, updated_at: @clock.call)
    end

    def status(event_id: nil)
      rows = event_id ? @rows.where(event_id: event_id) : @rows
      rows.order(:created_at, :id).all
    end

    def document_status(ids)
      return {} if ids.empty?

      document_id = Sequel.lit("payload::jsonb ->> 'document_id'")
      # Aggregate retained history in SQL; old poison rows must remain visible.
      @rows.where(document_id => ids).group(document_id, :target, :state)
           .order(document_id, :target, :state)
           .select(document_id.as(:document_id), :target, :state, Sequel.function(:max, :attempts).as(:attempts),
                   Sequel.function(:count, :id).as(:count))
           .all.group_by { |row| row.delete(:document_id) }
    end

    private

    def record_delivery(row)
      ActiveSupport::Notifications.instrument('delivered.knowledge', target: row[:target], attempts: row[:attempts],
                                                                     lag_seconds: @clock.call - row[:created_at])
    end

    def eligible(target, now)
      states = Sequel.|({ state: 'pending' }, Sequel.&({ state: 'working' }, Sequel[:lease_until] <= now))
      @rows.where(target: target).where(states).where { available_at <= now }
    end

    def owned(row)
      now = @clock.call
      @rows.where(id: row[:id], state: 'working', lease_token: row[:lease_token])
           .where { lease_until > now }
    end
  end
end
