# frozen_string_literal: true

class ReactionRepairTransactionTest < ActiveSupport::TestCase
  test 'committed creation and deletion publish on the subscribed card stream' do
    comment = comments(:logo_agreement_jz)
    messages = []
    subscriber = ActiveSupport::Notifications.subscribe('broadcast.action_cable') do |*arguments|
      payload = arguments.last
      messages << payload[:message] if payload[:broadcasting] == comment.card.to_gid_param
    end
    reaction = comment.reactions.create!(creator: users(:kevin), content: 'committed')
    assert messages.any? { |message| message.include?('committed') }, 'Committed creation was not published'
    messages.clear
    reaction.destroy!
    assert messages.any? { |message| message.include?(ActionView::RecordIdentifier.dom_id(reaction)) },
           'Committed deletion was not published'
    refute Reaction.exists?(reaction.id)
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  test 'rolled back creation and deletion do not broadcast' do
    comment = comments(:logo_agreement_jz)
    original = comment.reactions.create!(creator: users(:kevin), content: 'keep')
    messages = []
    subscriber = ActiveSupport::Notifications.subscribe('broadcast.action_cable') do |*arguments|
      event = ActiveSupport::Notifications::Event.new(*arguments)
      messages << event.payload[:message] if event.payload[:broadcasting] == comment.card.to_gid_param
    end
    Reaction.transaction(requires_new: true) do
      comment.reactions.create!(creator: users(:david), content: 'rollback')
      original.destroy!
      raise ActiveRecord::Rollback
    end
    assert_empty messages
    assert Reaction.exists?(original.id)
    refute comment.reactions.exists?(content: 'rollback')
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end
end
