# frozen_string_literal: true

require_relative 'test_helper'
require 'minitest/mock'

class ResolutionsTest < ActiveSupport::TestCase
  setup do
    @reader = Assistance::User.create!(tenant: 'a', token: SecureRandom.hex)
    @editor = Assistance::User.create!(tenant: 'a', token: SecureRandom.hex, can_close: true)
    @ticket = Assistance::Ticket.create!(tenant: 'a', subject: 'Broken delivery')
  end

  def request(actor = @reader, key: SecureRandom.uuid)
    Assistance::RequestResolution.call(actor_id: actor.id, ticket_id: @ticket.id, question: 'Refund locally', key: key)
  end

  def generate(work)
    Assistance::GenerateResolution.call(work.id)
    work.reload
  end

  def approve(work, actor = @editor)
    Assistance::ReviewResolution.call(id: work.id, actor_id: actor.id, decision: 'approve',
                                      digest: work.proposal_digest, revision: work.source_revision)
  end

  test 'reader requests editor approves and duplicate execution has exactly one local effect' do
    work = generate(request)
    assert_equal 'awaiting_review', work.state
    assert_equal 'open', @ticket.reload.status
    approve(work)
    assert_equal 'approved', work.reload.state
    2.times { Assistance::ExecuteResolution.call(work.id) }
    assert_equal 'completed', work.reload.state
    assert_equal work.proposal, @ticket.reload.approved_resolution
    assert_equal 1, @ticket.lock_version
    assert_equal 1, Assistance::ResolutionAudit.where(resolution_request_id: work.id, event: 'completed').count
  end

  test 'authorized requester may approve own proposal but reader cannot' do
    work = generate(request(@editor))
    assert_raises(Assistance::ResolutionAccess::Forbidden) { approve(work, @reader) }
    approve(work)
    assert_equal @editor.id, work.reload.approver_id
  end

  test 'idempotency returns exact request and conflicts on changed content or competing work' do
    work = request(key: 'repeat')
    assert_equal work.id, request(key: 'repeat').id
    assert_raises(Assistance::ResolutionAccess::Conflict) do
      Assistance::RequestResolution.call(actor_id: @reader.id, ticket_id: @ticket.id, question: 'Changed',
                                         key: 'repeat')
    end
    assert_raises(Assistance::ResolutionAccess::Conflict) { request }
  end

  test 'execution cannot bypass approval' do
    work = generate(request)
    Assistance::ExecuteResolution.call(work.id)
    assert_equal 'open', @ticket.reload.status
    assert_equal 'awaiting_review', work.reload.state
    assert_equal 0, Assistance::ResolutionAudit.where(event: 'completed').count
  end

  test 'changed source invalidates approved work' do
    work = generate(request)
    approve(work)
    @ticket.update!(subject: 'Changed')
    Assistance::ExecuteResolution.call(work.id)
    assert_equal 'stale', work.reload.state
    assert_equal 'open', @ticket.reload.status
  end

  test 'wrong digest conflicts and changed ticket persists stale at approval' do
    work = generate(request)
    assert_raises(Assistance::ResolutionAccess::Conflict) do
      Assistance::ReviewResolution.call(id: work.id, actor_id: @editor.id, decision: 'approve', digest: 'wrong',
                                        revision: 0)
    end
    @ticket.update!(subject: 'Changed')
    assert_raises(Assistance::ResolutionAccess::Conflict) { approve(work) }
    assert_equal 'stale', work.reload.state
  end

  test 'revoked requester and approver cannot execute approved work' do
    work = generate(request)
    approve(work)
    @editor.update!(active: false)
    Assistance::ExecuteResolution.call(work.id)
    assert_equal 'stale', work.reload.state
    assert_equal 'open', @ticket.reload.status
  end

  test 'foreign identities cannot view or decide and reader cannot reject' do
    work = generate(request)
    foreign = Assistance::User.create!(tenant: 'b', token: SecureRandom.hex, can_close: true)
    assert_raises(ActiveRecord::RecordNotFound) { approve(work, foreign) }
    removed = Assistance::User.new(id: -1, tenant: 'a', can_close: true)
    assert_raises(ActiveRecord::RecordNotFound) { approve(work, removed) }
    assert_raises(Assistance::ResolutionAccess::Forbidden) do
      Assistance::ReviewResolution.call(id: work.id, actor_id: @reader.id, decision: 'reject')
    end
  end

  test 'cancelled generation cannot be restored' do
    work = request
    token = Assistance::GenerateResolution.claim(work.id, 'offline_v1')
    Assistance::ReviewResolution.call(id: work.id, actor_id: @reader.id, decision: 'cancel')
    Assistance::GenerateResolution.finish(work.id, token, proposal: 'Too late')
    assert_equal 'cancelled', work.reload.state
    assert_nil work.proposal
  end

  test 'lease expiry fences old result and replacement result succeeds' do
    work = request
    old = Assistance::GenerateResolution.claim(work.id, 'offline_v1')
    travel 91.seconds do
      fresh = Assistance::GenerateResolution.claim(work.id, 'offline_v1')
      Assistance::GenerateResolution.finish(work.id, old, proposal: 'Old')
      assert_nil work.reload.proposal
      Assistance::GenerateResolution.finish(work.id, fresh, proposal: 'Fresh')
    end
    assert_equal 'Fresh', work.reload.proposal
    assert_equal %w[expired succeeded], Assistance::GenerationAttempt.order(:number).pluck(:state)
  end

  test 'provider failures are bounded and retry preserves exhausted request' do
    work = request
    3.times do
      token = Assistance::GenerateResolution.claim(work.id, 'offline_v1')
      Assistance::GenerateResolution.finish(work.id, token, failure: 'provider_timeout')
      travel 31.seconds
    end
    assert_equal 'failed', work.reload.state
    assert_equal 3, work.attempt_count
    assert_nil Assistance::GenerateResolution.claim(work.id, 'offline_v1')
    retry_work = Assistance::RequestResolution.call(actor_id: @reader.id, ticket_id: @ticket.id,
                                                    question: work.question, key: 'retry', previous_id: work.id)
    assert_equal work.id, retry_work.previous_request_id
    assert_equal 0, retry_work.attempt_count
    assert_nil retry_work.approver_id
    assert_equal 3, Assistance::GenerationAttempt.where(resolution_request_id: work.id).count
  end

  test 'revocation during generation discards output' do
    work = request
    token = Assistance::GenerateResolution.claim(work.id, 'offline_v1')
    @reader.update!(active: false)
    Assistance::GenerateResolution.finish(work.id, token, proposal: 'Unauthorized')
    assert_equal 'stale', work.reload.state
    assert_nil work.proposal
  end

  test 'cancel before execution wins and cancel after completion conflicts' do
    work = generate(request)
    approve(work)
    Assistance::ReviewResolution.call(id: work.id, actor_id: @reader.id, decision: 'cancel')
    Assistance::ExecuteResolution.call(work.id)
    assert_equal 'open', @ticket.reload.status
    replacement = generate(request)
    approve(replacement)
    Assistance::ExecuteResolution.call(replacement.id)
    assert_raises(Assistance::ResolutionAccess::Conflict) do
      Assistance::ReviewResolution.call(id: replacement.id, actor_id: @reader.id, decision: 'cancel')
    end
  end

  test 'proposal is immutable and audit records cannot be edited' do
    work = generate(request)
    assert_raises(ActiveRecord::RecordInvalid) { work.update!(proposal: 'Edited') }
    audit = Assistance::ResolutionAudit.find_by!(resolution_request_id: work.id)
    assert_raises(ActiveRecord::ReadOnlyRecord) { audit.update!(event: 'changed') }
  end

  test 'partial unique index and rollback protect work identity' do
    work = request
    assert_raises(ActiveRecord::RecordNotUnique) do
      Assistance::ResolutionRequest.transaction(requires_new: true) do
        work.dup.tap { |copy| copy.idempotency_key = 'other' }.save!
      end
    end
    assert_equal 1, Assistance::ResolutionRequest.count
  end
end
