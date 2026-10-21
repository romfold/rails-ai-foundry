# frozen_string_literal: true

module Knowledge
  class TenantRollout
    GATE = 73_401
    BUDGET = 10
    class Blocked < StandardError; end

    def active?
      TenantMigration.find_by(id: 1)&.active || false
    end

    def write
      Document.transaction do
        connection.execute("SET LOCAL lock_timeout = '5s'")
        connection.execute("SET LOCAL statement_timeout = '10s'")
        connection.execute("SELECT pg_advisory_xact_lock_shared(#{GATE})")
        yield
      end
    end

    def cutover
      gate do
        state = TenantMigration.lock.find(1)
        raise Blocked, 'Validate ownership before cutover' unless state.phase == 'validated'
        raise Blocked, 'Ownership constraints are not validated' unless TenantConstraints.new.validated?

        state.update!(active: true)
      end
    end

    def rollback
      gate { TenantMigration.lock.find(1).update!(active: false) }
    end

    def status
      TenantMigration.find(1).attributes.merge('unresolved' => TenantIssue.count,
                                               'issues' => TenantIssue.order(:document_id).limit(50).as_json)
    end

    private

    def gate
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      Document.transaction do
        connection.execute("SET LOCAL lock_timeout = '5s'")
        connection.execute("SET LOCAL statement_timeout = '10s'")
        connection.execute("SELECT pg_advisory_xact_lock(#{GATE})")
        bound_remaining(started)
        yield
        bound_remaining(started)
      end
    end

    def bound_remaining(started)
      remaining = BUDGET - (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started)
      raise Blocked, 'Cutover budget exceeded' unless remaining.positive?

      connection.execute("SET LOCAL statement_timeout = '#{[(remaining * 1000).floor, 1].max}ms'")
    end

    def connection
      Document.connection
    end
  end
end
