# frozen_string_literal: true

require_relative 'test_helper'
require 'open3'
require 'timeout'

class ReviewedRecoveryAcceptanceTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    clean_records
    @actor = SupportDesk::User.create!(tenant: 'recovery', token: SecureRandom.hex, can_close: true)
    @ticket = SupportDesk::Ticket.create!(tenant: 'recovery', subject: 'Restart proof')
    @work = SupportDesk::RequestResolution.call(actor_id: @actor.id, ticket_id: @ticket.id,
                                                question: 'Complete after restart', key: 'restart')
  end
  teardown { clean_records }

  def clean_records
    ActiveRecord::Base.connection.execute('TRUNCATE resolution_audits, generation_attempts, resolution_requests, ' \
                                          'support_desk_tickets, support_desk_users, solid_queue_jobs CASCADE')
  end

  def approve
    SupportDesk::GenerateResolution.call(@work.id)
    @work.reload
    SupportDesk::ReviewResolution.call(id: @work.id, actor_id: @actor.id, decision: 'approve',
                                       digest: @work.proposal_digest, revision: @work.source_revision)
  end

  def terminate_at(script)
    Open3.popen2e(RbConfig.ruby, 'bin/rails', 'runner', script) do |input, output, process|
      Timeout.timeout(30) do
        loop do
          line = output.gets
          raise 'Recovery child exited before synchronization' unless line
          break if line.strip == 'READY'
        end
      end
      Process.kill('KILL', process.pid)
      assert process.value.signaled?
      input.close
    ensure
      Process.kill('KILL', process.pid) if process.alive?
    end
  end

  test 'process death during local transaction preserves approved work for replay' do
    approve
    terminate_at(<<~RUBY_CODE)
      SupportDesk::Ticket.after_update { puts 'READY'; STDOUT.flush; sleep 60 }
      SupportDesk::ExecuteResolution.call(#{@work.id})
    RUBY_CODE
    assert_equal 'open', @ticket.reload.status
    assert_equal 'approved', @work.reload.state
    SupportDesk::ExecuteResolution.call(@work.id)
    assert_equal 'completed', @work.reload.state
  end

  test 'committed execution survives process death and duplicate queue acknowledgment' do
    approve
    terminate_at(<<~RUBY_CODE)
      SupportDesk::ExecuteResolution.call(#{@work.id})
      puts 'READY'; STDOUT.flush; sleep 60
    RUBY_CODE
    2.times { SupportDesk::ExecuteResolutionJob.perform_now(@work.id) }
    assert_equal 1, @ticket.reload.lock_version
    assert_equal 1, SupportDesk::ResolutionAudit.where(resolution_request_id: @work.id, event: 'completed').count
  end

  test 'lost scheduling is rediscovered and executed through persisted queue work' do
    SolidQueue::Job.delete_all
    SupportDesk::DiscoverResolutionsJob.perform_now
    job = SolidQueue::Job.find_by!(class_name: 'SupportDesk::GenerateResolutionJob')
    ActiveJob::Base.execute(job.arguments)
    assert_equal 'awaiting_review', @work.reload.state
    assert_equal 1, @work.attempt_count
    assert_equal 1, SupportDesk::GenerationAttempt.where(resolution_request_id: @work.id, state: 'succeeded').count
  end
end
