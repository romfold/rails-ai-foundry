# frozen_string_literal: true

module Answering
  class RetrievalTool
    def initialize(tenant_id:, authorize:)
      @tenant_id = tenant_id
      @authorize = authorize
    end

    def call(query:, tenant_id: nil)
      raise SecurityError, 'unauthorized retrieval' unless @authorize.call(@tenant_id)
      raise SecurityError, 'tenant override' if tenant_id && tenant_id != @tenant_id

      Knowledge::Document.where(tenant_id: @tenant_id, published: true).order(:id).map(&:attributes).select { |row| row.fetch('body').include?(query) }
    end
  end
end
