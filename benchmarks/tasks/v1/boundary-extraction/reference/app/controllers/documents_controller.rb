# frozen_string_literal: true

class DocumentsController < ActionController::Base
  def index
    tenant = { 'tenant-a-token' => 'a', 'tenant-b-token' => 'b' }[request.headers['Authorization']]
    return head :unauthorized unless tenant

    render json: Knowledge::Catalog.list(tenant_id: tenant)
  end
end
