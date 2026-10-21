# frozen_string_literal: true

ActiveSupport::Notifications.subscribe(/\.knowledge\z/) do |name, _start, _finish, _id, payload|
  Rails.logger.info(JSON.generate(event: name, **payload))
end
