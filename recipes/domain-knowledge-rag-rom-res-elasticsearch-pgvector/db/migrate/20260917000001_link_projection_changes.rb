# frozen_string_literal: true

class LinkProjectionChanges < ActiveRecord::Migration[8.1]
  def up
    add_column :knowledge_projection_changes, :previous_id, :bigint, null: false, default: 0
    execute <<~SQL
      UPDATE knowledge_projection_changes AS changes
      SET previous_id = ordered.previous_id
      FROM (SELECT id, lag(id, 1, 0::bigint) OVER (ORDER BY id) AS previous_id
            FROM knowledge_projection_changes) AS ordered
      WHERE changes.id = ordered.id
    SQL
  end

  def down
    remove_column :knowledge_projection_changes, :previous_id
  end
end
