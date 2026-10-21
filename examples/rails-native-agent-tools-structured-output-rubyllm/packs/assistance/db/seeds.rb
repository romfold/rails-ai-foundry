# frozen_string_literal: true

Assistance::User.find_or_create_by!(token: 'demo-reader') { |user| user.tenant = 'a' }
Assistance::User.find_or_create_by!(token: 'demo-editor') do |user|
  user.tenant = 'a'
  user.can_close = true
end
Assistance::Ticket.find_or_create_by!(tenant: 'a', subject: 'Delivery is delayed')
