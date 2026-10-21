# frozen_string_literal: true

# Run only against the seeded disposable review database, via Rails runner.
raise 'Unexpected database' unless Account.first&.name == 'Synthetic Search Review'

case ARGV.fetch(0)
when 'create'
  Room.find_by!(name: 'Shared Review').messages.create!(
    creator: User.find_by!(email_address: 'one@example.test'),
    client_message_id: 'fresh', body: 'freshword created during review'
  )
when 'update'
  Message.find_by!(client_message_id: 'lifecycle').update!(body: 'afterword updated during review')
  Membership.find_by!(user: User.find_by!(email_address: 'one@example.test'),
                      room: Room.find_by!(name: 'Revocable Review')).destroy!
when 'delete'
  Message.find_by!(client_message_id: 'lifecycle').destroy!
  Message.find_by!(client_message_id: 'fresh').destroy!
else
  raise 'Unknown mutation'
end

puts({ mutation: ARGV.first, messages: Message.count,
       indexed: Message.connection.select_value('SELECT COUNT(*) FROM message_search_index') }.to_json)
