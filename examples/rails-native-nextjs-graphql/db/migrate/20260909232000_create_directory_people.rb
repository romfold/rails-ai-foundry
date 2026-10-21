# frozen_string_literal: true

class CreateDirectoryPeople < ActiveRecord::Migration[8.1]
  def change
    create_table :directory_people do |t|
      t.string :tenant, null: false
      t.string :name, null: false
      t.bigint :manager_id
    end
    add_index :directory_people, :tenant
  end
end
