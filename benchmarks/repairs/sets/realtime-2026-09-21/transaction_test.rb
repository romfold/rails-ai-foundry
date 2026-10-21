# frozen_string_literal: true

class ReactionRepairTransactionTest < ActiveSupport::TestCase
  test 'rolled back creation and deletion do not broadcast' do
    comment = comments(:logo_agreement_jz)
    original = comment.reactions.create!(user: users(:kevin), body: 'keep')
    messages = []
    subscriber = ActiveSupport::Notifications.subscribe('broadcast.action_cable') do |*arguments|
      event = ActiveSupport::Notifications::Event.new(*arguments)
      messages << event.payload[:message] if event.payload[:broadcasting] == comment.card.to_gid_param
    end
    Reaction.transaction(requires_new: true) do
      comment.reactions.create!(user: users(:david), body: 'rollback')
      original.destroy!
      raise ActiveRecord::Rollback
    end
    assert_empty messages
    assert Reaction.exists?(original.id)
    refute comment.reactions.exists?(body: 'rollback')
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end
end
