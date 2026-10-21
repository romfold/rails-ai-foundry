# frozen_string_literal: true

Rails.application.reloader.to_prepare { Rails.configuration.x.knowledge = Knowledge::Catalog.new }
