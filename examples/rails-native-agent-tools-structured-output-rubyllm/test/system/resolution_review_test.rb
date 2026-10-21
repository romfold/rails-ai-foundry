# frozen_string_literal: true

require_relative '../application_system_test_case'

class ResolutionReviewTest < ApplicationSystemTestCase
  setup do
    @reader = Assistance::User.create!(tenant: 'a', token: 'demo-reader')
    @editor = Assistance::User.create!(tenant: 'a', token: 'demo-editor', can_close: true)
    @ticket = Assistance::Ticket.create!(tenant: 'a', subject: 'Review delivery')
    @work = Assistance::RequestResolution.call(actor_id: @reader.id, ticket_id: @ticket.id, question: 'Resolve',
                                               key: 'ui')
    @previous_csrf = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
  end
  teardown { ActionController::Base.allow_forgery_protection = @previous_csrf }

  def login(role)
    visit '/demo/login'
    select role, from: 'Identity'
    click_button 'Sign in'
    assert_text "Signed in as #{role}"
    visit "/resolutions/#{@work.id}"
  end

  test 'reader sees escaped proposal while polling preserves unsaved notes and stops on cancellation' do
    login('Reader')
    assert_selector '#state', text: 'queued'
    fill_in 'Unsaved notes (kept while status refreshes)', with: 'Keep this draft'
    token = Assistance::GenerateResolution.claim(@work.id, 'controlled')
    Assistance::GenerateResolution.finish(@work.id, token,
                                          proposal: '<script>window.injected=true</script>Safe proposal')
    assert_selector '#state', text: 'awaiting_review', wait: 10
    assert_text '<script>window.injected=true</script>Safe proposal'
    assert_nil page.evaluate_script('window.injected')
    assert_field 'Unsaved notes (kept while status refreshes)', with: 'Keep this draft'
    assert_no_button 'Approve resolution'
    assert_no_button 'Reject proposal'
    Assistance::ReviewResolution.call(id: @work.id, actor_id: @reader.id, decision: 'cancel')
    assert_selector '#state', text: 'cancelled', wait: 10
    assert_selector '#state[data-terminal="true"]'
    assert_field 'Unsaved notes (kept while status refreshes)', with: 'Keep this draft'
  end

  test 'editor approves through CSRF protected form and sees completion separately' do
    Assistance::GenerateResolution.call(@work.id)
    login('Editor')
    click_button 'Approve resolution'
    assert_selector '#state', text: 'approved'
    assert_text 'Approval is not completion.'
    assert_equal 'open', @ticket.reload.status
    Assistance::ExecuteResolution.call(@work.id)
    assert_selector '#state', text: 'completed', wait: 10
    assert_text 'Ticket closed. Approved resolution stored locally.'
    assert_no_button 'Cancel request'
    assert_equal 'closed', @ticket.reload.status
  end
  test 'revoked browser identity receives a clear terminal status' do
    login('Reader')
    @reader.update!(active: false)
    assert_selector '#state', text: 'Identity unavailable or revoked', wait: 10
    assert_selector '#state[data-terminal="true"]'
    assert_no_button 'Approve resolution'
  end
end
