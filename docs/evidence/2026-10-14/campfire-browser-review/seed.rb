# frozen_string_literal: true

# Run with Rails runner only in a fresh disposable Campfire archive.
raise 'Review requires an empty database' if User.exists? || Account.exists?

Account.create!(name: 'Synthetic Search Review')
reviewer = User.create!(name: 'Review One', email_address: 'one@example.test', password: ENV.fetch('REVIEW_PASSWORD'))
other = User.create!(name: 'Review Two', email_address: 'two@example.test', password: ENV.fetch('REVIEW_PASSWORD'))
shared = Rooms::Closed.create_for({ name: 'Shared Review', creator: reviewer }, users: [reviewer, other])
private_room = Rooms::Closed.create_for({ name: 'Private Review', creator: other }, users: [other])
revocable = Rooms::Closed.create_for({ name: 'Revocable Review', creator: other }, users: [reviewer, other])

def review_message(room, user, key, body, timestamp)
  room.messages.create!(creator: user, client_message_id: key, body: body, created_at: timestamp, updated_at: timestamp)
end

start = Time.utc(2026, 1, 1)
101.times do |index|
  review_message(shared, reviewer, "window#{index}", "windowword #{index}", start + index)
end
review_message(shared, reviewer, 'ordinary', 'hello review Salt and pepper', start + 200)
review_message(private_room, other, 'secret', 'privateword hidden content', start + 201)
review_message(revocable, other, 'revocable', 'revocableword shared until revoked', start + 202)
review_message(shared, reviewer, 'lifecycle', 'beforeword lifecycle', start + 203)
other.searches.create!(query: 'privatehistory')

puts({ users: User.count, rooms: Room.count, messages: Message.count,
       indexed: Message.connection.select_value('SELECT COUNT(*) FROM message_search_index') }.to_json)
