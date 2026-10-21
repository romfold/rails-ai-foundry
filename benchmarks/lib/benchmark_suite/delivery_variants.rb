# frozen_string_literal: true

require_relative 'support'

module BenchmarkSuite
  module DeliveryVariants
    NAMES = %w[delegated_reference relocated_reference ignored_catalog].freeze

    module_function

    def apply(root, group, variant)
      controller = root.join('app/controllers/documents_controller.rb')
      text = controller.read
      case variant
      when 'delegated_reference'
        controller.write(text.sub('Knowledge::Catalog', 'Delivery::PublishedDocuments'))
        service = root.join('app/services/delivery/published_documents.rb')
        service.dirname.mkpath
        service.write("module Delivery\n  class PublishedDocuments\n    def self.list(tenant_id:)\n      " \
                      "Knowledge::Catalog.list(tenant_id: tenant_id)\n    end\n  end\nend\n")
      when 'relocated_reference'
        relocate(root, controller, text, group)
      when 'ignored_catalog'
        controller.write(text.sub('render json: Knowledge::Catalog.list(tenant_id: tenant)',
                                  "Knowledge::Catalog.list(tenant_id: tenant)\n    " \
                                  'render json: Knowledge::Document.where(tenant_id: tenant, published: true)' \
                                  '.order(:id).map { |row| ' \
                                  "row.attributes.slice('id', 'tenant_id', 'body', 'revision') }"))
      else
        raise Failure, 'Unknown delivery control'
      end
    end

    def relocate(root, controller, text, group)
      if group == 'rails'
        target = root.join('app/controllers/delivery/documents_controller.rb')
        text = text.sub('class DocumentsController', 'class Delivery::DocumentsController')
        routes = root.join('config/routes.rb')
        routes.write(routes.read.sub('documents#index', 'delivery/documents#index'))
      else
        target = root.join('packs/knowledge/app/controllers/documents_controller.rb')
      end
      target.dirname.mkpath
      target.write(text)
      controller.delete
    end
  end
end
