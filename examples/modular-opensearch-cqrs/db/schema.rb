# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_09_020000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "catalog_outbox_entries", force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "available_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "created_at", null: false
    t.datetime "delivered_at"
    t.string "last_error"
    t.jsonb "payload", null: false
    t.datetime "poisoned_at"
    t.datetime "updated_at", null: false
    t.index ["available_at"], name: "index_catalog_outbox_entries_on_available_at", where: "((delivered_at IS NULL) AND (poisoned_at IS NULL))"
  end

  create_table "catalog_products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "deleted", default: false, null: false
    t.string "name", null: false
    t.integer "revision", default: 1, null: false
    t.datetime "updated_at", null: false
  end

  create_table "catalog_rebuild_gates", force: :cascade do |t|
    t.string "name", null: false
    t.index ["name"], name: "index_catalog_rebuild_gates_on_name", unique: true
  end
end
