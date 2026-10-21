# frozen_string_literal: true

module Conversations
  class Chat < ApplicationRecord
    self.table_name = 'conversations_chats'
    has_many :messages, class_name: 'Conversations::Message', dependent: :destroy
    validates :tenant, presence: true
  end
end
