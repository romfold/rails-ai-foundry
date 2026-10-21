# frozen_string_literal: true

module TenantRolloutHelpers
  private

  def started_worker
    worker = Knowledge::TenantBackfill.new
    worker.start(old_writers_stopped: true)
    worker
  end

  def finish_backfill
    worker = started_worker
    loop { break if worker.batch.zero? }
    Knowledge::Collection.find(4).update!(tenant_id: 'tenant-c')
    worker.repair(document_id: 1201, collection_id: 4)
  end

  def crash_worker(stage)
    reader, writer = IO.pipe
    ActiveRecord::Base.connection_pool.disconnect!
    pid = fork do
      reader.close
      synchronize = lambda {
        writer.puts('persisted')
        writer.flush
        sleep 30
      }
      worker = Knowledge::TenantBackfill.new
      worker.define_singleton_method(:before_commit, &synchronize) if stage == :before
      worker.batch
      synchronize.call
      exit! 0
    end
    writer.close
    assert_equal "persisted\n", Timeout.timeout(10) { reader.gets }
    stop_child(pid)
    pid = nil
  ensure
    stop_child(pid)
    reader&.close
  end

  def stop_child(pid)
    return unless pid

    Process.kill('KILL', pid)
    Process.wait(pid)
    ActiveRecord::Base.connection.clear_query_cache
  rescue Errno::ESRCH, Errno::ECHILD
    nil
  end
end
