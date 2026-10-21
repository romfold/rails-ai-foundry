# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
require_relative '../config/environment'
require 'minitest/autorun'
require 'rack/test'
ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do
  create_table :documents, force: true do |table|
    table.string :tenant_id, null: false
    table.text :body, null: false
    table.integer :revision, null: false, default: 1
    table.boolean :published, null: false, default: false
  end
  create_table :embeddings, force: true do |table|
    table.integer :document_id, null: false
    table.string :tenant_id, null: false
    table.integer :revision, null: false
    table.string :version, null: false
    table.text :vector, null: false
  end
  add_index :embeddings, %i[document_id version], unique: true
  create_table :deliveries, force: true do |table|
    table.string :event_id, null: false
    table.text :payload, null: false
    table.boolean :delivered, null: false, default: false
  end
end

class BenchmarkTest < Minitest::Test
  def setup
    Knowledge::Embedding.delete_all
    Knowledge::Document.delete_all
    Knowledge::Delivery.delete_all
  end

  def document(tenant: 'a', body: 'refund policy', revision: 1, published: true)
    Knowledge::Document.create!(tenant_id: tenant, body: body, revision: revision, published: published)
  end
end
