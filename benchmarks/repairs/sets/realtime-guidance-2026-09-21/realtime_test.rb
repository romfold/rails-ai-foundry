# frozen_string_literal: true

require_relative 'verification_test'
require_relative 'authorization_test'
require_relative 'transaction_test'

class VerifierTest
  test 'the rendered deletion control submits DELETE to the requested record' do
    comment.scroll_to(:center)
    react 'form-check'
    reaction('form-check').click
    record = @comment.reactions.find_by!(content: 'form-check')
    assert_selector 'button.reaction__delete'
    button = comment.find('button.reaction__delete')
    form = button.ancestor('form')
    assert_equal card_comment_reaction_path(@card, @comment, record), URI.parse(form[:action]).path
    assert_equal 'post', form[:method].downcase
    assert_equal 'delete', form.find('input[name="_method"]', visible: :all).value
    assert_includes button.text, 'Remove reaction'
    button.click
    assert_no_text 'form-check'
    refute Reaction.exists?(record.id)
  end

  test 'broadcast controls belong to the viewer rather than the sender' do
    wait_for_cable_subscriptions
    Capybara.using_session(:david) do
      sign_in_as users(:david)
      visit card_url(@card)
      wait_for_cable_subscriptions
    end
    comment.scroll_to(:center)
    react 'viewer-control'
    perform_enqueued_jobs
    Capybara.using_session(:david) do
      assert_text 'viewer-control', wait: 5
      reaction('viewer-control').click
      assert_no_selector '.reaction__delete'
    end
    reaction('viewer-control').click
    assert_selector 'button.reaction__delete'
  end

  test 'a rejected submission preserves its draft and can be corrected' do
    wait_for_cable_subscriptions
    comment.scroll_to(:center)
    within comment do
      find('.reactions__trigger').click
      page.execute_script("arguments[0].removeAttribute('maxlength')", find('.reaction__input'))
      find('.reaction__input').set 'x' * 17
      find('.reaction__submit-btn').click
      assert_selector '[role="alert"]', text: 'Content'
      assert_equal 'x' * 17, find('.reaction__input').value
      refute find('.reaction__input').disabled?
      find('.reaction__input').set 'corrected'
      find('.reaction__submit-btn').click
      assert_text 'corrected'
      assert_no_selector '.reaction__input'
    end
    assert_equal 1, @comment.reactions.where(content: 'corrected').count
  end

  test 'deletion reaches another viewer without replacing their draft' do
    comment.scroll_to(:center)
    react 'live-delete'
    wait_for_cable_subscriptions
    Capybara.using_session(:david) do
      sign_in_as users(:david)
      visit card_url(@card)
      wait_for_cable_subscriptions
      comment.scroll_to(:center)
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
    comment.scroll_to(:center)
    within comment do
      find('.reactions__trigger').click
      find('.reaction__input').set 'unsaved'
    end
    page.execute_script(<<~JS)
      addEventListener('turbo:morph', () => document.body.dataset.repairMorph = 'yes', { once: true })
    JS
    Turbo::StreamsChannel.broadcast_refresh_to(@card)
    assert_selector 'body[data-repair-morph="yes"]', wait: 5
    assert comment.has_selector?('.reaction__input'), 'Refresh removed the open composer'
    assert_equal 'unsaved', comment.find('.reaction__input').value
  end

  test 'cancel resets only the local composer without persisting a reaction' do
    before = Reaction.count
    comment.scroll_to(:center)
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
