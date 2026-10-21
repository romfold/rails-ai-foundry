# frozen_string_literal: true

require_relative 'test_helper'
require 'minitest/mock'

class ResolutionLimitsTest < ActiveSupport::TestCase
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

  test 'outer rollback removes work and its audit without scheduling' do
    before = Assistance::ResolutionAudit.count
    Assistance::ResolutionRequest.transaction(requires_new: true) do
      request
      raise ActiveRecord::Rollback
    end
    assert_equal 0, Assistance::ResolutionRequest.count
    assert_equal before, Assistance::ResolutionAudit.count
  end

  test 'question limits and native job delegation preserve contracts' do
    assert_raises(ArgumentError) do
      Assistance::RequestResolution.call(actor_id: @reader.id, ticket_id: @ticket.id, question: 'x' * 2001,
                                         key: 'limit')
    end
    work = request
    Assistance::GenerateResolutionJob.perform_now(work.id)
    work.reload
    approve(work)
    2.times { Assistance::ExecuteResolutionJob.perform_now(work.id) }
    assert_equal 'completed', work.reload.state
    assert_equal 1, Assistance::ResolutionAudit.where(event: 'completed').count
  end
  test 'rejection preserves proposal and cannot be retried as failed generation' do
    work = generate(request)
    Assistance::ReviewResolution.call(id: work.id, actor_id: @editor.id, decision: 'reject')
    assert_equal 'rejected', work.reload.state
    assert work.proposal.present?
    assert_equal 1, Assistance::ResolutionAudit.where(event: 'rejected').count
    assert_raises(Assistance::ResolutionAccess::Conflict) do
      Assistance::RequestResolution.call(actor_id: @reader.id, ticket_id: @ticket.id,
                                         question: work.question, key: 'retry', previous_id: work.id)
    end
  end

  test 'discovery bounds each batch and excludes future backoff' do
    51.times do |index|
      ticket = Assistance::Ticket.create!(tenant: 'a', subject: "Ticket #{index}")
      Assistance::RequestResolution.call(actor_id: @reader.id, ticket_id: ticket.id, question: 'Resolve',
                                         key: index.to_s)
    end
    deferred = Assistance::ResolutionRequest.first
    deferred.update!(next_attempt_at: 1.hour.from_now)
    selected = []
    Assistance::ResolutionWakeup.stub(:call, ->(work) { selected << work.id }) do
      Assistance::DiscoverResolutionsJob.perform_now
    end
    assert_equal 50, selected.size
    refute_includes selected, deferred.id
  end
end
