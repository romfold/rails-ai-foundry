# frozen_string_literal: true

# Run only against the original candidate; these assertions demonstrate its defects.
require '/tests/verification_test'

class VerifierTest
  test 'diagnostic original callback and deletion form' do
    requests = []
    broadcasts = []
    subscriptions = diagnostic_subscriptions(requests, broadcasts)
    wait_for_cable_subscriptions
    react 'diagnostic'
    perform_enqueued_jobs
    reaction('diagnostic').ancestor('.reaction').click
    result = diagnostic_result(requests, broadcasts)
    puts "CAUSAL_DIAGNOSTIC=#{JSON.generate(result)}"
    assert_equal({ create: 0, destroy: 1 }, result[:applicable])
    assert_empty(broadcasts.select { |message| message[:broadcasting] == @card.to_gid_param })
    assert_equal 0, result[:delete_controls]
    assert_equal 0, result[:delete_overrides]
  ensure
    subscriptions&.each { |subscription| ActiveSupport::Notifications.unsubscribe(subscription) }
  end

  private

  def diagnostic_subscriptions(requests, broadcasts)
    [ActiveSupport::Notifications.subscribe('process_action.action_controller') do |*arguments|
      payload = arguments.last
      requests << payload.slice(:controller, :action, :status) if payload[:controller].include?('Reaction')
    end, ActiveSupport::Notifications.subscribe('broadcast.action_cable') do |*arguments|
      broadcasts << arguments.last.slice(:broadcasting, :message)
    end]
  end

  def diagnostic_result(requests, broadcasts)
    dom = diagnostic_dom
    callbacks = Reaction._commit_callbacks.select { |item| item.filter == :broadcast_reactions }
    { requests: requests, persisted_content: @comment.reactions.find_by!(content: 'diagnostic').content,
      callback_count: callbacks.size, applicable: diagnostic_actions(callbacks),
      expected_stream: @card.to_gid_param, broadcasts: broadcasts,
      connected: page.has_selector?('turbo-cable-stream-source[connected]', visible: :all),
      form_html: dom.fetch('form_html'), delete_controls: dom.fetch('delete_controls'),
      delete_overrides: dom.fetch('delete_overrides') }
  end

  def diagnostic_actions(callbacks)
    %i[create destroy].to_h do |action|
      probe = Reaction.allocate
      probe.define_singleton_method(:transaction_include_any_action?) { |wanted| wanted.include?(action) }
      [action, callbacks.count do |item|
        item.instance_variable_get(:@if).all? { |condition| probe.instance_exec(&condition) }
      end]
    end
  end

  def diagnostic_dom
    page.evaluate_script(<<~JS)
      (() => {
        const entry = [...document.querySelectorAll('.reaction')].find(node => node.textContent.includes('diagnostic'))
        const form = entry.querySelector('form')
        return { form_html: form.outerHTML, delete_controls: entry.querySelectorAll('.reaction__delete').length,
                 delete_overrides: form.querySelectorAll('input[name="_method"][value="delete"]').length }
      })()
    JS
  end
end
