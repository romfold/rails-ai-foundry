# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  Rails.configuration.x.knowledge = Knowledge::Catalog.with_tenant_migration
end
