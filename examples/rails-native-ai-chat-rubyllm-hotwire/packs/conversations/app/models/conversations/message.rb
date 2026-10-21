# frozen_string_literal: true

module Conversations
  class Message < ApplicationRecord
    self.table_name = 'conversations_messages'
    belongs_to :chat, class_name: 'Conversations::Chat'
    validates :question, length: { minimum: 1, maximum: 4000 }
  end
end
