# frozen_string_literal: true

module Access
  module Identity
    TOKENS = { 'demo-a' => 'tenant-a', 'demo-b' => 'tenant-b', 'demo-c' => 'tenant-c' }.freeze

    def self.tenant(token)
      TOKENS.fetch(token.to_s.delete_prefix('Bearer ')) { raise ActiveRecord::RecordNotFound }
    end
  end
end
