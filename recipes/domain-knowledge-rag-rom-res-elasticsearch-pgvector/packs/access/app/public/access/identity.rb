# frozen_string_literal: true

module Access
  module Identity
    class Denied < StandardError; end
    Principal = Data.define(:tenant_id, :role, :token_digest)

    def self.authenticate(token)
      tokens = JSON.parse(ENV.fetch('DEMO_TOKENS', '{"demo-a":"tenant-a","demo-b":"tenant-b"}'))
      tenant = tokens[token.to_s.delete_prefix('Bearer ')]
      raise Denied, 'Authentication required' unless tenant

      Principal.new(tenant_id: tenant, role: 'editor',
                    token_digest: Digest::SHA256.hexdigest(token.to_s.delete_prefix('Bearer ')))
    end

    def self.authorize!(principal, tenant_id)
      tokens = JSON.parse(ENV.fetch('DEMO_TOKENS', '{"demo-a":"tenant-a","demo-b":"tenant-b"}'))
      active = principal.is_a?(Principal) && tokens.any? do |token, tenant|
        tenant == principal.tenant_id && Digest::SHA256.hexdigest(token) == principal.token_digest
      end
      raise Denied, 'Tenant access denied' unless active && principal.tenant_id == tenant_id
    end
  end
end
