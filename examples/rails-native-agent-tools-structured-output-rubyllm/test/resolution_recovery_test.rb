# frozen_string_literal: true

require_relative 'test_helper'
require 'open3'
require 'timeout'

class ResolutionRecoveryTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    clear_database
    @reader = Assistance::User.create!(tenant: 'a', token: SecureRandom.hex)
    @editor = Assistance::User.create!(tenant: 'a', token: SecureRandom.hex, can_close: true)
    @ticket = Assistance::Ticket.create!(tenant: 'a', subject: 'Recover')
    @work = Assistance::RequestResolution.call(actor_id: @reader.id, ticket_id: @ticket.id, question: 'Resolve',
                                               key: 'a')
  end
  teardown { clear_database }

  def clear_database
    ActiveRecord::Base.connection.execute('TRUNCATE resolution_audits, generation_attempts, resolution_requests, ' \
                                          'assistance_tickets, assistance_users, solid_queue_jobs ' \
                                          'RESTART IDENTITY CASCADE')
  end

  def approve
    Assistance::GenerateResolution.call(@work.id)
    @work.reload
    Assistance::ReviewResolution.call(id: @work.id, actor_id: @editor.id, decision: 'approve',
                                      digest: @work.proposal_digest, revision: @work.source_revision)
  end

  def kill_at(point)
    env = { 'RAILS_ENV' => 'test', 'WORK_ID' => @work.id.to_s, 'CRASH_POINT' => point.to_s }
    Open3.popen2e(env, RbConfig.ruby, 'bin/rails', 'runner', 'test/recovery_child.rb',
                  chdir: Rails.root) do |input, output, child|
      Timeout.timeout(30) do
        loop do
          line = output.gets
          raise 'Child exited before checkpoint' unless line
          break if line.include?('CHECKPOINT')
        end
      end
      Process.kill('KILL', child.pid)
      assert child.value.signaled?
      input.close
    ensure
      Process.kill('KILL', child.pid) if child.alive?
    end
  end

  test 'crash after provider requires lease recovery and preserves attempt history' do
    kill_at(:after_provider)
    assert_nil @work.reload.proposal
    @work.update!(lease_expires_at: 1.second.ago)
    Assistance::GenerateResolution.call(@work.id)
    assert_equal 'awaiting_review', @work.reload.state
    assert_equal %w[expired succeeded], Assistance::GenerationAttempt.order(:number).pluck(:state)
  end

  test 'crash before commit rolls back closure and replay completes once' do
    approve
    kill_at(:before_commit)
    assert_equal 'open', @ticket.reload.status
    assert_equal 'approved', @work.reload.state
    Assistance::ExecuteResolution.call(@work.id)
    assert_equal 'completed', @work.reload.state
    assert_equal 1, Assistance::ResolutionAudit.where(event: 'completed').count
  end

  test 'crash after commit before acknowledgement cannot duplicate closure' do
    approve
    kill_at(:after_commit)
    Assistance::ExecuteResolution.call(@work.id)
    assert_equal 'closed', @ticket.reload.status
    assert_equal 1, @ticket.lock_version
    assert_equal 1, Assistance::ResolutionAudit.where(event: 'completed').count
  end

  test 'lost enqueue is rediscovered in real Solid Queue' do
    SolidQueue::Job.delete_all
    Assistance::DiscoverResolutionsJob.perform_now
    job = SolidQueue::Job.find_by!(class_name: 'Assistance::GenerateResolutionJob')
    ActiveJob::Base.execute(job.arguments)
    assert_equal 'awaiting_review', @work.reload.state
    assert_equal 1, Assistance::GenerationAttempt.count
  end

  test 'competing approvals and cancellation execution serialize' do
    approve
    results = Queue.new
    threads = [
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection { Assistance::ExecuteResolution.call(@work.id) }
        results << :executed
      end,
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          Assistance::ReviewResolution.call(id: @work.id, actor_id: @reader.id, decision: 'cancel')
        end
        results << :cancelled
      rescue Assistance::ResolutionAccess::Conflict
        results << :conflict
      end
    ]
    threads.each(&:value)
    assert_includes %w[completed cancelled], @work.reload.state
    assert_equal(@work.state == 'completed' ? 'closed' : 'open', @ticket.reload.status)
    assert_equal(@work.state == 'completed' ? 1 : 0, Assistance::ResolutionAudit.where(event: 'completed').count)
    assert_equal 2, results.size
  end
  test 'native queue worker resumes persisted pending generation after lost scheduling' do
    SolidQueue::Job.delete_all
    Assistance::DiscoverResolutionsJob.perform_now
    Open3.popen2e({ 'RAILS_ENV' => 'test' }, RbConfig.ruby, 'bin/jobs', 'start', '--mode=async',
                  '--skip-recurring', chdir: Rails.root) do |input, output, child|
      reader = Thread.new { output.read }
      Timeout.timeout(30) do
        sleep 0.05 until @work.reload.state == 'awaiting_review'
      end
      assert_equal 1, @work.attempt_count
      assert_equal 1, Assistance::GenerationAttempt.where(state: 'succeeded').count
      Process.kill('TERM', child.pid)
      Timeout.timeout(15) { child.join }
      assert child.value.success?, reader.value
      input.close
    ensure
      Process.kill('KILL', child.pid) if child.alive?
    end
  end

  test 'only one competing editor approval is accepted' do
    Assistance::GenerateResolution.call(@work.id)
    @work.reload
    other = Assistance::User.create!(tenant: 'a', token: SecureRandom.hex, can_close: true)
    ready = Queue.new
    start = Queue.new
    results = [@editor, other].map do |actor|
      Thread.new do
        ready << true
        start.pop
        ActiveRecord::Base.connection_pool.with_connection do
          Assistance::ReviewResolution.call(id: @work.id, actor_id: actor.id, decision: 'approve',
                                            digest: @work.proposal_digest, revision: @work.source_revision)
        end
        :approved
      rescue Assistance::ResolutionAccess::Conflict
        :conflict
      end
    end
    2.times { ready.pop }
    2.times { start << true }
    assert_equal %i[approved conflict], results.map(&:value).sort
    assert_equal 1, Assistance::ResolutionAudit.where(event: 'approved').count
  end
end
