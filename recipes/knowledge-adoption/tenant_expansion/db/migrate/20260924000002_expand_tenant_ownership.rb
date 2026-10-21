# frozen_string_literal: true

class ExpandTenantOwnership < ActiveRecord::Migration[8.1]
  def change
    add_column :knowledge_documents, :tenant_id, :string
    add_index :knowledge_documents, %i[tenant_id id]
    create_table :knowledge_tenant_migrations do |t|
      t.string :phase, null: false, default: 'expanded'
      t.bigint :cursor, null: false, default: 0
      t.bigint :scan_bound, null: false, default: 0
      t.boolean :active, null: false, default: false
      t.datetime :writers_confirmed_at
    end
    add_check_constraint :knowledge_tenant_migrations, 'id = 1', name: 'one_tenant_migration'
    create_table :knowledge_tenant_issues, id: false do |t|
      t.bigint :document_id, null: false, primary_key: true
      t.string :reason, null: false
    end
    reversible do |direction|
      direction.up do
        execute 'INSERT INTO knowledge_tenant_migrations (id) VALUES (1)'
      end
    end
  end
end
