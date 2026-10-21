# frozen_string_literal: true

require_relative 'test_helper'

class ExistingTicketTest < ActiveSupport::TestCase
  test 'existing tickets preserve tenant and open state' do
    ticket = SupportDesk::Ticket.create!(tenant: 'existing', subject: 'Keep my existing behavior')
    assert_equal 'open', ticket.reload.status
    assert_equal 'existing', ticket.tenant
  end
end
