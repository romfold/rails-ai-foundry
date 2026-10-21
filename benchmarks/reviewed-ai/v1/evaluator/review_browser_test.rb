# frozen_string_literal: true

require_relative 'test_helper'
require 'capybara/rails'
require 'selenium-webdriver'

class ReviewBrowserAcceptanceTest < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome do |options|
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-background-networking')
  end
  Capybara.server_host = '127.0.0.1'
  Capybara.default_max_wait_time = 10

  test 'reader sees plain proposal and status refresh preserves a draft' do
    reader = SupportDesk::User.create!(tenant: 'north', token: 'demo-reader')
    ticket = SupportDesk::Ticket.create!(tenant: 'north', subject: 'Browser proof')
    work = SupportDesk::RequestResolution.call(actor_id: reader.id, ticket_id: ticket.id,
                                               question: 'Browser request', key: 'browser-1')
    visit '/demo/login'
    select 'Reader', from: 'Identity'
    click_button 'Sign in'
    assert_text 'Signed in as Reader'
    visit "/resolutions/#{work.id}"
    fill_in 'Unsaved notes (kept while status refreshes)', with: 'Keep this unsaved draft'
    provider = Object.new
    provider.define_singleton_method(:provenance) { 'offline-browser' }
    provider.define_singleton_method(:call) { |**| '<script>window.injected = true</script>Safe' }
    SupportDesk::GenerateResolution.call(work.id, provider: provider)
    assert_text 'awaiting_review', wait: 10
    assert_text '<script>window.injected = true</script>Safe'
    assert_nil page.evaluate_script('window.injected')
    assert_field 'Unsaved notes (kept while status refreshes)', with: 'Keep this unsaved draft'
    assert_no_button 'Approve resolution'
  end
end
