# frozen_string_literal: true

module Voice
  class Session < ApplicationRecord
    self.table_name = 'voice_sessions'
  end
end
