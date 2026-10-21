# frozen_string_literal: true

class DocumentsController < ActionController::Base
  def index
    tenant = { 'tenant-a-token' => 'a', 'tenant-b-token' => 'b' }[request.headers['Authorization']]
    return head :unauthorized unless tenant

    render json: Knowledge::Document.where(tenant_id: tenant, published: true).order(:id).map { |row| row.attributes.slice('id', 'tenant_id', 'body', 'revision') }
  end
end
