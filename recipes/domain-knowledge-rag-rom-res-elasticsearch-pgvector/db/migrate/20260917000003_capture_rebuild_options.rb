# frozen_string_literal: true

class CaptureRebuildOptions < ActiveRecord::Migration[8.1]
  def change
    add_column :search_rebuild_runs, :options, :text, null: false, default: '{}'
  end
end
