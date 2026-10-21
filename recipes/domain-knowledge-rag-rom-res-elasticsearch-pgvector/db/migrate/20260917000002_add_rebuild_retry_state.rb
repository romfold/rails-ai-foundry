# frozen_string_literal: true

class AddRebuildRetryState < ActiveRecord::Migration[8.1]
  def change
    add_column :search_rebuild_runs, :validated, :boolean, null: false, default: false
    add_column :search_rebuild_runs, :failure_count, :integer, null: false, default: 0
    add_column :search_rebuild_runs, :poisoned, :boolean, null: false, default: false
    add_column :search_rebuild_runs, :retry_at, :datetime
  end
end
