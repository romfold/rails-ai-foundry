# frozen_string_literal: true

require_relative 'verification_test'
require_relative 'authorization_test'
require_relative 'transaction_test'

class VerifierTest
  test 'deletion reaches another viewer without replacing their draft' do
    react 'live-delete'
    wait_for_cable_subscriptions
    Capybara.using_session(:david) do
      sign_in_as users(:david)
      visit card_url(@card)
      wait_for_cable_subscriptions
      assert_text 'live-delete'
      reaction('live-delete').click
      assert_no_selector '.reaction__delete'
      within comment do
        find('.reactions__trigger').click
        find('.reaction__input').set 'draft'
      end
    end
    reaction('live-delete').click
    comment.find('.reaction__delete').click
    assert_no_text 'live-delete'
    Capybara.using_session(:david) do
      assert_no_text 'live-delete'
      assert_equal 'draft', comment.find('.reaction__input').value
    end
  end

  test 'an explicit refresh preserves a composing viewer' do
    wait_for_cable_subscriptions
    within comment do
      find('.reactions__trigger').click
      find('.reaction__input').set 'unsaved'
    end
    page.execute_script(<<~JS)
      addEventListener('turbo:morph', () => document.body.dataset.repairMorph = 'yes', { once: true })
    JS
    Turbo::StreamsChannel.broadcast_refresh_to(@card)
    assert_selector 'body[data-repair-morph="yes"]', wait: 5
    assert_equal 'unsaved', comment.find('.reaction__input').value
  end

  test 'cancel resets only the local composer without persisting a reaction' do
    before = Reaction.count
    within comment do
      find('.reactions__trigger').click
      find('.reaction__input').set 'cancelled'
      find('.reaction__cancel-btn').click
      assert_no_selector '.reaction__input'
      find('.reactions__trigger').click
      assert_equal '', find('.reaction__input').value
    end
    assert_equal before, Reaction.count
  end
end
