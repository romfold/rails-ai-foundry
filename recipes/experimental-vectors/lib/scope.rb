# frozen_string_literal: true

require 'digest'
require 'json'

module Knowledge
  class Scope
    attr_reader :tenant, :version, :generation

    def initialize(tenant:, version:, generation:)
      unless [tenant, version, generation].all? do |value|
        value.is_a?(String) && value.match?(/\A[a-zA-Z0-9_-]{1,64}\z/)
      end
        raise ArgumentError, 'Trusted tenant, embedding version and generation are required'
      end

      @tenant = tenant
      @version = version
      @generation = generation
    end

    def namespace
      Digest::SHA256.hexdigest(JSON.generate([tenant, version, generation]))
    end

    def vector!(vector)
      return vector if vector.is_a?(Array) && vector.size == 3 &&
                       vector.all? { |value| value.is_a?(Numeric) && value.finite? }

      raise ArgumentError, 'Recipe requires a finite three-dimensional embedding'
    end

    def revision!(revision)
      return revision if revision.is_a?(Integer) && revision.positive?

      raise ArgumentError, 'Positive document revision required'
    end

    def id!(id)
      return id if id.is_a?(String) && id.match?(/\A[0-9a-f]{8}-(?:[0-9a-f]{4}-){3}[0-9a-f]{12}\z/)

      raise ArgumentError, 'Document UUID required'
    end
  end
end
